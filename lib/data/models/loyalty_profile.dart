import 'package:dart_mappable/dart_mappable.dart';

part 'loyalty_profile.mapper.dart';

/// Loyalty event type enum - matches web types
@MappableEnum()
enum LoyaltyEventType {
  @MappableValue('purchase')
  purchase,
  @MappableValue('referral_inviter')
  referralInviter,
  @MappableValue('referral_friend')
  referralFriend,
  @MappableValue('bonus')
  bonus,
}

/// Loyalty tier - calculated client-side based on stars
/// Matches web implementation
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum;

  String get label {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
    }
  }

  /// Stars multiplier for this tier
  double get multiplier {
    switch (this) {
      case LoyaltyTier.bronze:
        return 1.0;
      case LoyaltyTier.silver:
        return 1.25;
      case LoyaltyTier.gold:
        return 1.5;
      case LoyaltyTier.platinum:
        return 2.0;
    }
  }

  /// Get tier from stars count
  static LoyaltyTier fromStars(int stars) {
    if (stars >= 5000) return LoyaltyTier.platinum;
    if (stars >= 1500) return LoyaltyTier.gold;
    if (stars >= 500) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }
}

/// Loyalty profile model matching Supabase loyalty_profiles table
/// Schema: id, tenant_id, email, phone, name, stars, referral_code, referred_by,
///         first_order_completed, metadata, created_at, updated_at
@MappableClass(caseStyle: CaseStyle.snakeCase)
class LoyaltyProfile with LoyaltyProfileMappable {
  final String id;
  final String tenantId;
  final String? email;
  final String? phone;
  final String? name;
  final int stars;
  final String referralCode;
  final String? referredBy;
  final bool firstOrderCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoyaltyProfile({
    required this.id,
    required this.tenantId,
    this.email,
    this.phone,
    this.name,
    this.stars = 0,
    required this.referralCode,
    this.referredBy,
    this.firstOrderCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Stars value in dollars (100 stars = $1)
  double get starsValueInDollars => stars / 100.0;

  /// Formatted stars value
  String get formattedStarsValue =>
      '\$${starsValueInDollars.toStringAsFixed(2)}';

  /// Display string for stars balance
  String get starsDisplay => '$stars stars';

  /// Get tier based on stars (calculated client-side like web)
  LoyaltyTier get tier => LoyaltyTier.fromStars(stars);
}

/// Loyalty event model matching Supabase loyalty_events table
/// Schema: id, tenant_id, profile_id, order_id, type, stars, description, metadata, created_at
@MappableClass(caseStyle: CaseStyle.snakeCase)
class LoyaltyEvent with LoyaltyEventMappable {
  final String id;
  final String profileId;
  final String tenantId;
  @MappableField(key: 'type')
  final String eventType;
  @MappableField(key: 'stars')
  final int starsAmount;
  final String? orderId;
  final String? description;
  final DateTime createdAt;

  const LoyaltyEvent({
    required this.id,
    required this.profileId,
    required this.tenantId,
    required this.eventType,
    required this.starsAmount,
    this.orderId,
    this.description,
    required this.createdAt,
  });

  /// Whether this event added stars
  bool get isPositive => starsAmount > 0;

  /// Formatted stars delta (e.g., "+100" or "-50")
  String get formattedDelta =>
      starsAmount >= 0 ? '+$starsAmount' : '$starsAmount';

  /// Get typed event type
  LoyaltyEventType? get typedEventType {
    switch (eventType) {
      case 'purchase':
        return LoyaltyEventType.purchase;
      case 'referral_inviter':
        return LoyaltyEventType.referralInviter;
      case 'referral_friend':
        return LoyaltyEventType.referralFriend;
      case 'bonus':
        return LoyaltyEventType.bonus;
      default:
        return null;
    }
  }
}
