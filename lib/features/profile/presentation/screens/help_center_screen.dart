import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';

@RoutePage()
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedCategoryIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(title: const Text('Help Center'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Search
            _buildHeroSection(context),

            // Quick Actions
            _buildQuickActions(context),

            // FAQ Categories
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Frequently Asked Questions',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ),

            // FAQ List
            ..._buildFilteredFAQs(context),

            // Contact Support Section
            _buildContactSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.messageCircleQuestion,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search our FAQ or browse categories below',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(LucideIcons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: LucideIcons.phone,
              label: 'Call Us',
              color: const Color(0xFF10B981),
              onTap: () => _launchUrl('tel:+13472060218'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: LucideIcons.mail,
              label: 'Email',
              color: const Color(0xFF3B82F6),
              onTap: () => _launchUrl('mailto:shahirzadafreshmarket@gmail.com'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredFAQs(BuildContext context) {
    final categories = _faqCategories;

    if (_searchQuery.isEmpty) {
      return categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return _FAQCategoryCard(
          category: category,
          isExpanded: _expandedCategoryIndex == index,
          onToggle: () {
            setState(() {
              _expandedCategoryIndex = _expandedCategoryIndex == index
                  ? null
                  : index;
            });
          },
        );
      }).toList();
    }

    // Filter FAQs by search query
    final filteredItems = <_FAQItem>[];
    for (final category in categories) {
      for (final item in category.items) {
        if (item.question.toLowerCase().contains(_searchQuery) ||
            item.answer.toLowerCase().contains(_searchQuery)) {
          filteredItems.add(item);
        }
      }
    }

    if (filteredItems.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  LucideIcons.searchX,
                  size: 48,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords or browse categories',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          '${filteredItems.length} result${filteredItems.length > 1 ? 's' : ''} found',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
        ),
      ),
      ...filteredItems.map((item) => _SearchResultItem(item: item)),
    ];
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.headset,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Still need help?",
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Our support team is available Mon-Sat, 9AM-8PM",
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl('tel:+17727737680'),
              icon: const Icon(LucideIcons.phone, size: 18),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  List<_FAQCategory> get _faqCategories => [
    _FAQCategory(
      icon: LucideIcons.shoppingBag,
      title: 'Orders & Delivery',
      color: const Color(0xFFEC4899),
      items: [
        _FAQItem(
          question: 'How do I place an order?',
          answer:
              'Browse our products, add items to your cart, and proceed to checkout. You can pay securely using credit/debit card or other available payment methods. Once your order is confirmed, you\'ll receive a confirmation email with your order details.',
        ),
        _FAQItem(
          question: 'What are your delivery hours?',
          answer:
              'We deliver Monday through Saturday, from 10AM to 7PM. Sunday deliveries are available in select areas. You can choose your preferred delivery window during checkout.',
        ),
        _FAQItem(
          question: 'How much does delivery cost?',
          answer:
              'Delivery is FREE for orders over \$50. For orders under \$50, a flat delivery fee of \$5.99 applies. Express delivery (within 2 hours) is available for an additional \$4.99.',
        ),
        _FAQItem(
          question: 'Can I track my order?',
          answer:
              'Yes! Once your order is out for delivery, you\'ll receive real-time tracking updates via the app and SMS. You can also view your order status anytime in the "Orders" section.',
        ),
        _FAQItem(
          question: 'What if I\'m not home during delivery?',
          answer:
              'You can add delivery instructions during checkout. If no one is available, our driver will contact you. For safety, we cannot leave perishable items unattended. You may reschedule the delivery within the app.',
        ),
      ],
    ),
    _FAQCategory(
      icon: LucideIcons.creditCard,
      title: 'Payment & Pricing',
      color: const Color(0xFF10B981),
      items: [
        _FAQItem(
          question: 'What payment methods do you accept?',
          answer:
              'We accept Visa, Mastercard, American Express, Apple Pay, and Google Pay. All transactions are processed securely through Stripe. We do not store your card details on our servers.',
        ),
        _FAQItem(
          question: 'How are meat products priced?',
          answer:
              'Our meats are priced per pound (lb) or kilogram (kg) based on your preference settings. The final price is calculated based on the actual weight of your cut. You\'ll see the estimated price at checkout and the final charge once your order is packed.',
        ),
        _FAQItem(
          question: 'Can I use promo codes?',
          answer:
              'Yes! Enter your promo code at checkout to apply the discount. Only one promo code can be used per order. Some codes may have minimum order requirements or expiration dates.',
        ),
        _FAQItem(
          question: 'How do refunds work?',
          answer:
              'If you\'re not satisfied with any product, contact us within 24 hours of delivery. We\'ll arrange a refund or replacement. Refunds are processed to your original payment method within 5-7 business days.',
        ),
      ],
    ),
    _FAQCategory(
      icon: LucideIcons.star,
      title: 'Rewards & Loyalty',
      color: const Color(0xFFF59E0B),
      items: [
        _FAQItem(
          question: 'How does the rewards program work?',
          answer:
              'Earn 1 star for every \$1 spent. Stars can be redeemed for discounts on future orders (100 stars = \$1). As you earn more stars, you\'ll unlock higher tiers with better rewards and exclusive benefits.',
        ),
        _FAQItem(
          question: 'What are the membership tiers?',
          answer:
              'Bronze (0-499 stars): Earn 1 star/\$1\nSilver (500-1,499 stars): Earn 1.5 stars/\$1 + free delivery\nGold (1,500-4,999 stars): Earn 2 stars/\$1 + priority support\nPlatinum (5,000+ stars): Earn 2.5 stars/\$1 + exclusive access',
        ),
        _FAQItem(
          question: 'Do stars expire?',
          answer:
              'Stars expire 12 months after they\'re earned if there\'s no account activity. Keep your account active by making at least one purchase per year to maintain your star balance.',
        ),
        _FAQItem(
          question: 'How do I refer friends?',
          answer:
              'Share your unique referral code from the Rewards section. When a friend places their first order using your code, you both receive 100 bonus stars! There\'s no limit to how many friends you can refer.',
        ),
      ],
    ),
    _FAQCategory(
      icon: LucideIcons.user,
      title: 'Account & Profile',
      color: const Color(0xFF6366F1),
      items: [
        _FAQItem(
          question: 'How do I create an account?',
          answer:
              'Tap "Sign Up" on the login screen and enter your email, phone number, and create a password. You can also sign up using your Apple or Google account for faster registration.',
        ),
        _FAQItem(
          question: 'How do I reset my password?',
          answer:
              'On the login screen, tap "Forgot Password" and enter your email. We\'ll send you a secure link to reset your password. The link expires after 1 hour for security.',
        ),
        _FAQItem(
          question: 'Can I save multiple delivery addresses?',
          answer:
              'Yes! Go to Profile > Addresses to add, edit, or remove delivery addresses. You can save as many addresses as you need and set a default address for quick checkout.',
        ),
        _FAQItem(
          question: 'How do I delete my account?',
          answer:
              'Contact our support team to request account deletion. We\'ll process your request within 48 hours. Note that this action is irreversible and you\'ll lose all your stars and order history.',
        ),
      ],
    ),
    _FAQCategory(
      icon: LucideIcons.beef,
      title: 'Products & Quality',
      color: AppTheme.primaryColor,
      items: [
        _FAQItem(
          question: 'Where does your meat come from?',
          answer:
              'We source our premium meats from trusted local farms and certified halal suppliers. All our products meet strict quality standards and are inspected for freshness before delivery.',
        ),
        _FAQItem(
          question: 'Are your products halal certified?',
          answer:
              'Yes, 100% of our meat products are halal certified. We work exclusively with certified halal suppliers and maintain proper handling throughout our supply chain.',
        ),
        _FAQItem(
          question: 'How should I store my meat products?',
          answer:
              'Refrigerate products immediately upon delivery. Fresh cuts should be used within 2-3 days or frozen for longer storage. Frozen products can be stored for up to 6 months. Always check the best-by date on packaging.',
        ),
        _FAQItem(
          question: 'Can I request custom cuts?',
          answer:
              'Absolutely! Add special instructions to any meat product during checkout. Our skilled butchers will prepare your cuts exactly as requested. Custom cuts may require additional preparation time.',
        ),
      ],
    ),
  ];
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQCategory {
  final IconData icon;
  final String title;
  final Color color;
  final List<_FAQItem> items;

  _FAQCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });
}

class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({required this.question, required this.answer});
}

class _FAQCategoryCard extends StatefulWidget {
  final _FAQCategory category;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FAQCategoryCard({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_FAQCategoryCard> createState() => _FAQCategoryCardState();
}

class _FAQCategoryCardState extends State<_FAQCategoryCard> {
  int? _expandedItemIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Category Header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: widget.category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.category.items.length} questions',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Items
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: context.colors.borderLight, height: 1),
                ...widget.category.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _ExpandableFAQItem(
                    item: item,
                    isExpanded: _expandedItemIndex == index,
                    onToggle: () {
                      setState(() {
                        _expandedItemIndex = _expandedItemIndex == index
                            ? null
                            : index;
                      });
                    },
                    isLast: index == widget.category.items.length - 1,
                  );
                }),
              ],
            ),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _ExpandableFAQItem extends StatelessWidget {
  final _FAQItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isLast;

  const _ExpandableFAQItem({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isExpanded
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isExpanded
                          ? context.colors.primary
                          : context.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: isExpanded
                        ? context.colors.primary
                        : context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (!isLast)
          Divider(
            color: context.colors.borderLight,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

class _SearchResultItem extends StatefulWidget {
  final _FAQItem item;

  const _SearchResultItem({required this.item});

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isExpanded
                            ? context.colors.primary
                            : context.colors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: _isExpanded
                          ? context.colors.primary
                          : context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
