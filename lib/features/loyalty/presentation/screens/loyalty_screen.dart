import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../data/models/models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/loyalty_provider.dart';

@RoutePage()
class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rewards')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.star,
                size: 80,
                color: AppTheme.goldStar.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign in to earn rewards',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Earn stars on every purchase and unlock exclusive rewards',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.router.push(const LoginRoute()),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final loyaltyAsync = ref.watch(loyaltyProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: loyaltyAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No loyalty profile found'));
          }
          return _LoyaltyContent(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circleAlert, size: 48),
              const SizedBox(height: 16),
              Text(
                UserErrorMessage.from(
                  e,
                  fallback: 'Unable to load rewards. Please try again.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(loyaltyProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoyaltyContent extends ConsumerWidget {
  final LoyaltyProfile profile;

  const _LoyaltyContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(loyaltyEventsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(loyaltyProfileProvider);
        ref.invalidate(loyaltyEventsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Stars Card
            _StarsCard(profile: profile),

            // Tier Progress
            _TierProgressCard(profile: profile),

            // Referral Section
            _ReferralCard(profile: profile),

            // How to Earn Section
            _HowToEarnCard(),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  eventsAsync.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'No activity yet. Start shopping to earn stars!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: events.take(10).map((event) {
                          return _ActivityItem(event: event);
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Text('Could not load activity'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsCard extends StatelessWidget {
  final LoyaltyProfile profile;

  const _StarsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTierColor(profile.tier),
            _getTierColor(profile.tier).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getTierColor(profile.tier).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.tier.name.toUpperCase()} MEMBER',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your Stars',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTierIcon(profile.tier),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(LucideIcons.star, color: Colors.white, size: 36),
              const SizedBox(width: 8),
              Text(
                '${profile.stars}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'stars',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Worth \$${(profile.stars / 100).toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Redeem',
                  style: TextStyle(
                    color: _getTierColor(profile.tier),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFF6B7280);
      case LoyaltyTier.gold:
        return const Color(0xFFD4AF37);
      case LoyaltyTier.platinum:
        return const Color(0xFF1F2937);
    }
  }

  IconData _getTierIcon(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return LucideIcons.star;
      case LoyaltyTier.silver:
        return LucideIcons.star;
      case LoyaltyTier.gold:
        return LucideIcons.star;
      case LoyaltyTier.platinum:
        return LucideIcons.sparkles;
    }
  }
}

class _TierProgressCard extends StatelessWidget {
  final LoyaltyProfile profile;

  const _TierProgressCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextTier = _getNextTier(profile.tier);
    final starsNeeded = _getStarsForNextTier(profile.tier) - profile.stars;
    final progress = _getProgress(profile);

    if (profile.tier == LoyaltyTier.platinum) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.goldStar.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.trophy, color: AppTheme.goldStar),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "You've reached the highest tier! Enjoy exclusive Platinum benefits.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to ${nextTier!.name.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${starsNeeded > 0 ? starsNeeded : 0} points to go',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${profile.stars} / ${_getStarsForNextTier(profile.tier)} lifetime points',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  LoyaltyTier? _getNextTier(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null;
    }
  }

  int _getStarsForNextTier(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 500;
      case LoyaltyTier.silver:
        return 1500;
      case LoyaltyTier.gold:
        return 5000;
      case LoyaltyTier.platinum:
        return 5000;
    }
  }

  double _getProgress(LoyaltyProfile profile) {
    switch (profile.tier) {
      case LoyaltyTier.bronze:
        return profile.stars / 500;
      case LoyaltyTier.silver:
        return (profile.stars - 500) / 1000;
      case LoyaltyTier.gold:
        return (profile.stars - 1500) / 3500;
      case LoyaltyTier.platinum:
        return 1.0;
    }
  }
}

class _ReferralCard extends StatelessWidget {
  final LoyaltyProfile profile;

  const _ReferralCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.gift,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Refer Friends',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Give 100 stars, get 100 stars',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your referral code',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.referralCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: profile.referralCode),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(LucideIcons.share2),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToEarnCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Earn Stars',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _EarnItem(
            icon: LucideIcons.shoppingCart,
            title: 'Shop',
            description: 'Earn 1 star for every \$1 spent',
          ),
          const SizedBox(height: 12),
          _EarnItem(
            icon: LucideIcons.userPlus,
            title: 'Refer Friends',
            description: 'Get 100 bonus stars per referral',
          ),
          const SizedBox(height: 12),
          _EarnItem(
            icon: LucideIcons.partyPopper,
            title: 'Special Promotions',
            description: 'Watch for double star days',
          ),
        ],
      ),
    );
  }
}

class _EarnItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EarnItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                description,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final LoyaltyEvent event;

  const _ActivityItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event.isPositive
                  ? colors.success.withValues(alpha: 0.1)
                  : colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              event.isPositive ? LucideIcons.plus : LucideIcons.minus,
              color: event.isPositive ? colors.success : colors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description ?? _getEventTitle(event.eventType),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  dateFormat.format(event.createdAt),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            event.formattedDelta,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: event.isPositive ? colors.success : colors.error,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            LucideIcons.star,
            size: 16,
            color: event.isPositive ? colors.success : colors.error,
          ),
        ],
      ),
    );
  }

  String _getEventTitle(String eventType) {
    switch (eventType) {
      case 'purchase':
        return 'Earned from purchase';
      case 'redemption':
        return 'Redeemed';
      case 'referral_inviter':
        return 'Referral bonus (inviter)';
      case 'referral_friend':
        return 'Referral bonus (friend)';
      case 'bonus':
        return 'Bonus stars';
      default:
        return 'Stars activity';
    }
  }
}
