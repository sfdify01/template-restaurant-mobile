import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../../data/models/models.dart';
import '../../auth/providers/auth_provider.dart';

part 'loyalty_provider.g.dart';

/// Fetch the current user's loyalty profile
/// Matches web implementation - looks up by email (primary) or phone
@riverpod
Future<LoyaltyProfile?> loyaltyProfile(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    return null;
  }

  // Get user email/phone from auth state
  final user = auth.user;
  final customer = auth.customer;

  final email = user?.email ?? customer?.email;
  final phone = customer?.phone;

  if (email == null && phone == null) {
    return null;
  }

  // Email is primary identity (matches web findLoyaltyProfile)
  Map<String, dynamic>? response;
  if (email != null) {
    final normalizedEmail = email.trim().toLowerCase();
    response = await supabase
        .from('loyalty_profiles')
        .select()
        .eq('email_normalized', normalizedEmail)
        .maybeSingle();
  }

  // Only search by phone if no email provided (matches web behavior)
  if (response == null && phone != null && email == null) {
    // Normalize phone to 10-digit format (strip +1 prefix)
    String normalizedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (normalizedPhone.length == 11 && normalizedPhone.startsWith('1')) {
      normalizedPhone = normalizedPhone.substring(1);
    }

    response = await supabase
        .from('loyalty_profiles')
        .select()
        .eq('phone_normalized', normalizedPhone)
        .maybeSingle();
  }

  if (response == null) return null;
  return LoyaltyProfileMapper.fromMap(response);
}

/// Fetch loyalty events/history for the current user
@riverpod
Future<List<LoyaltyEvent>> loyaltyEvents(Ref ref) async {
  final profile = await ref.watch(loyaltyProfileProvider.future);
  if (profile == null) return [];

  final response = await supabase
      .from('loyalty_events')
      .select()
      .eq('profile_id', profile.id)
      .order('created_at', ascending: false)
      .limit(50);

  return (response as List).map((e) => LoyaltyEventMapper.fromMap(e)).toList();
}

/// Calculate stars needed for next tier
@riverpod
int starsToNextTier(Ref ref, LoyaltyTier currentTier, int lifetimeStars) {
  switch (currentTier) {
    case LoyaltyTier.bronze:
      return 500 - lifetimeStars; // Need 500 for Silver
    case LoyaltyTier.silver:
      return 1500 - lifetimeStars; // Need 1500 for Gold
    case LoyaltyTier.gold:
      return 5000 - lifetimeStars; // Need 5000 for Platinum
    case LoyaltyTier.platinum:
      return 0; // Already at top tier
  }
}

/// Calculate tier progress percentage
@riverpod
double tierProgress(Ref ref, LoyaltyTier currentTier, int lifetimeStars) {
  switch (currentTier) {
    case LoyaltyTier.bronze:
      return lifetimeStars / 500;
    case LoyaltyTier.silver:
      return (lifetimeStars - 500) / 1000; // 500-1500 range
    case LoyaltyTier.gold:
      return (lifetimeStars - 1500) / 3500; // 1500-5000 range
    case LoyaltyTier.platinum:
      return 1.0; // Max tier
  }
}

/// Redeem stars for rewards
@riverpod
class RedeemStars extends _$RedeemStars {
  @override
  FutureOr<void> build() {}

  /// Redeem stars for a discount on next order
  /// Returns the discount amount in cents, or null if failed
  Future<int?> redeemForDiscount(int starsToRedeem) async {
    final profile = await ref.read(loyaltyProfileProvider.future);
    if (profile == null || profile.stars < starsToRedeem) {
      return null;
    }

    // Each star = $0.01 (100 stars = $1)
    final discountCents = starsToRedeem;

    try {
      // Deduct stars - matches web DB column name 'stars'
      await supabase
          .from('loyalty_profiles')
          .update({'stars': profile.stars - starsToRedeem})
          .eq('id', profile.id);

      // Log the redemption - matches web DB schema
      // Column names: type, stars, description (no balance_after)
      await supabase.from('loyalty_events').insert({
        'profile_id': profile.id,
        'tenant_id': profile.tenantId,
        'type': 'redemption',
        'stars': -starsToRedeem,
        'description':
            'Redeemed for \$${(discountCents / 100).toStringAsFixed(2)} discount',
      });

      // Invalidate cache
      ref.invalidate(loyaltyProfileProvider);
      ref.invalidate(loyaltyEventsProvider);

      return discountCents;
    } catch (e) {
      return null;
    }
  }
}
