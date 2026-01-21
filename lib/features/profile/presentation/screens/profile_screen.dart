import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/env_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../core/utils/us_phone_input_formatter.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../loyalty/providers/loyalty_provider.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  PackageInfo? _packageInfo;
  bool _devModeUnlocked = false;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  void _handleVersionTap() {
    final now = DateTime.now();

    // Reset if more than 1 second between taps
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds > 1000) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    if (_tapCount >= 8) {
      setState(() {
        _devModeUnlocked = !_devModeUnlocked;
        _tapCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _devModeUnlocked
                ? 'Developer mode enabled'
                : 'Developer mode disabled',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: _devModeUnlocked
              ? context.colors.warning
              : context.colors.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final isSignedIn =
        auth.isAuthenticated && !(auth.user?.isAnonymous ?? false);
    final customer = auth.customer;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    child: Icon(
                      isSignedIn ? LucideIcons.user : LucideIcons.circleUser,
                      size: 32,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSignedIn
                              ? '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'
                                        .trim()
                                        .isEmpty
                                    ? 'User'
                                    : '${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'
                                          .trim()
                              : 'Guest',
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        if (isSignedIn)
                          Text(
                            customer?.email ??
                                auth.user?.email ??
                                customer?.phone ??
                                auth.user?.phone ??
                                'Account',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          )
                        else
                          Text(
                            'Sign in for rewards & order history',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSignedIn)
                    IconButton(
                      onPressed: () {
                        context.router.push(const EditProfileRoute());
                      },
                      icon: const Icon(LucideIcons.pencil),
                    ),
                ],
              ),
            ),
          ),

          // Sign In Button for guests
          if (!isSignedIn) ...[
            const SizedBox(height: 16),
            _buildSignInCard(context, ref),
          ],

          const SizedBox(height: 24),

          // Menu Items
          _buildMenuSection(
            context,
            title: 'Account',
            items: [
              _MenuItem(
                icon: LucideIcons.receipt,
                title: 'Order History',
                onTap: () => context.tabsRouter.setActiveIndex(2), // Orders tab
              ),
              _MenuItem(
                icon: LucideIcons.mapPin,
                title: 'My Addresses',
                onTap: () => context.router.push(const AddressesRoute()),
              ),
              _MenuItem(
                icon: LucideIcons.star,
                title: 'Loyalty Stars',
                subtitle: _getLoyaltySubtitle(ref),
                onTap: () => context.router.push(const LoyaltyRoute()),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildPreferencesSection(context, ref),
          const SizedBox(height: 16),

          _buildMenuSection(
            context,
            title: 'Support',
            items: [
              _MenuItem(
                icon: LucideIcons.circleHelp,
                title: 'Help Center',
                onTap: () => context.router.push(const HelpCenterRoute()),
              ),
              _MenuItem(
                icon: LucideIcons.info,
                title: 'About',
                onTap: () => context.router.push(const AboutRoute()),
              ),
              _MenuItem(
                icon: LucideIcons.fileText,
                title: 'Privacy Policy & Terms',
                onTap: () => context.router.push(const PrivacyPolicyRoute()),
              ),
              _MenuItem(
                icon: LucideIcons.map,
                title: 'Get Directions',
                subtitle: 'Find us on Google or Apple Maps',
                onTap: () => _showDirectionsPicker(context),
              ),
            ],
          ),

          // Environment switch (hidden by default, activate with 8 taps on version)
          if (_devModeUnlocked) ...[
            const SizedBox(height: 16),
            _buildEnvironmentSwitch(context, ref),
          ],

          if (isSignedIn) ...[
            const SizedBox(height: 24),
            // Sign Out Button
            OutlinedButton.icon(
              onPressed: () async {
                await authNotifier.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              },
              icon: const Icon(LucideIcons.logOut),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.error,
                side: BorderSide(color: context.colors.error),
              ),
            ),
            const SizedBox(height: 12),
            // Delete Account Button
            TextButton.icon(
              onPressed: () => _showDeleteAccountDialog(context, ref),
              icon: Icon(
                LucideIcons.trash2,
                size: 18,
                color: context.colors.error.withOpacity(0.7),
              ),
              label: Text(
                'Delete Account',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error.withOpacity(0.7),
                ),
              ),
            ),
          ],

          // Branded Footer with App Version
          const SizedBox(height: 32),
          _buildBrandedFooter(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      // Already granted - show confirmation with option to manage in settings
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifications are enabled'),
            backgroundColor: context.colors.success,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else if (status.isDenied) {
      // Request permission
      final granted = await OneSignalService.instance.requestPermission();
      final updatedStatus = await Permission.notification.status;
      if (context.mounted) {
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifications enabled!'),
              backgroundColor: context.colors.success,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        } else if (updatedStatus.isPermanentlyDenied) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Notifications Disabled'),
              content: const Text(
                'Notifications are permanently disabled. Please enable them in your device settings to receive order updates.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification permission denied'),
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Notifications Disabled'),
            content: const Text(
              'Notifications are permanently disabled. Please enable them in your device settings to receive order updates.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildSignInCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: context.colors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.star, color: context.colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earn Loyalty Stars',
                        style: context.textTheme.titleMedium,
                      ),
                      Text(
                        'Sign in to track rewards & orders',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSignInSheet(context, ref);
                },
                child: const Text('Sign In / Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SignInSheet(),
    );
  }

  String _getLoyaltySubtitle(WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProfileProvider);
    return loyaltyAsync.when(
      data: (profile) => '${profile?.stars ?? 0} stars',
      loading: () => 'Loading...',
      error: (_, __) => '0 stars',
    );
  }

  Widget _buildEnvironmentSwitch(BuildContext context, WidgetRef ref) {
    final env = ref.watch(environmentProvider);
    final isTest = env == AppEnvironment.test;

    // Environment-specific colors
    final envColor = isTest ? context.colors.warning : context.colors.success;
    final envBgColor = isTest
        ? context.colors.warningBackground
        : context.colors.successBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Text(
                'Developer',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.warningBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEBUG',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.cloud, color: envColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Environment',
                            style: context.textTheme.titleSmall,
                          ),
                          Text(
                            env.domain,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Environment toggle
                    SegmentedButton<AppEnvironment>(
                      segments: const [
                        ButtonSegment(
                          value: AppEnvironment.test,
                          label: Text('Test'),
                          icon: Icon(LucideIcons.bug, size: 16),
                        ),
                        ButtonSegment(
                          value: AppEnvironment.production,
                          label: Text('Prod'),
                          icon: Icon(LucideIcons.rocket, size: 16),
                        ),
                      ],
                      selected: {env},
                      onSelectionChanged: (value) async {
                        final newEnv = value.first;
                        final saved = await ref
                            .read(environmentProvider.notifier)
                            .setEnvironment(newEnv);

                        if (context.mounted) {
                          if (saved) {
                            _showRestartDialog(context, newEnv);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Failed to save environment. Please try again.',
                                ),
                                backgroundColor: context.colors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: envBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, size: 16, color: envColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTest
                              ? 'Using test Supabase branch with test data'
                              : 'Using production Supabase with live data',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: envColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Preferences',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              // Theme switcher
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(LucideIcons.palette, color: context.colors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme', style: context.textTheme.bodyLarge),
                          Text(
                            currentTheme.label,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SegmentedButton<AppThemeMode>(
                      segments: AppThemeMode.values.map((mode) {
                        return ButtonSegment(
                          value: mode,
                          icon: Icon(mode.icon, size: 18),
                          tooltip: mode.label,
                        );
                      }).toList(),
                      selected: {currentTheme},
                      onSelectionChanged: (value) {
                        ref
                            .read(appThemeProvider.notifier)
                            .setTheme(value.first);
                      },
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications
              ListTile(
                leading: Icon(LucideIcons.bell, color: context.colors.primary),
                title: const Text('Notifications'),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  color: context.colors.textTertiary,
                ),
                onTap: () => _handleNotificationPermission(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRestartDialog(BuildContext context, AppEnvironment newEnv) {
    final isTest = newEnv == AppEnvironment.test;
    final envColor = isTest ? context.colors.warning : context.colors.success;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          isTest ? LucideIcons.bug : LucideIcons.rocket,
          color: envColor,
          size: 32,
        ),
        title: Text('Switch to ${newEnv.label}'),
        content: Text(
          'Environment changed to ${newEnv.label}. The app needs to restart to apply changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              // Small delay to ensure SharedPreferences flush to disk completes
              // before terminating the app (important for Android's apply() behavior)
              await Future.delayed(const Duration(milliseconds: 500));
              await TerminateRestart.instance.restartApp(
                options: const TerminateRestartOptions(terminate: true),
              );
            },
            icon: const Icon(LucideIcons.rotateCcw, size: 18),
            label: const Text('Restart Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDirectionsPicker(BuildContext context) async {
    try {
      final coords = Coords(41.7508, -88.1535);
      const title = "Shahirizada Fresh Market";
      final availableMaps = await MapLauncher.installedMaps;

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select Maps App',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableMaps.length,
                    itemBuilder: (context, index) {
                      final map = availableMaps[index];
                      return ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps: $e')),
        );
      }
    }
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: context.colors.primary),
                    title: Text(item.title),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!)
                        : null,
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      color: context.colors.textTertiary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteAccountDialog(
        onDeleted: () {
          // Navigate to splash screen after deletion
          if (context.mounted) {
            context.router.replaceAll([const SplashRoute()]);
          }
        },
      ),
    );
  }

  Widget _buildBrandedFooter(BuildContext context) {
    final version = _packageInfo != null
        ? 'v${_packageInfo!.version} (${_packageInfo!.buildNumber})'
        : 'Loading...';

    final primaryColor = context.colors.primary;

    return GestureDetector(
      onTap: _handleVersionTap,
      child: Column(
        children: [
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Divider(
              color: context.colors.borderLight.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(LucideIcons.store, size: 28, color: primaryColor),
          ),
          const SizedBox(height: 12),

          // Brand name
          Text(
            'Shahirizada',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Fresh Market',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Address
          Text(
            'Shahirizada Fresh Market, 3124 Illinois Rte 59 Suite 154, Naperville, IL 60564',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.borderLight.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              version,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tagline
          Text(
            'Halal, never-frozen meats',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// Sign-in bottom sheet with OTP flow (matches web LoginForm)
class _SignInSheet extends ConsumerStatefulWidget {
  const _SignInSheet();

  @override
  ConsumerState<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<_SignInSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isPhone = false;
  String _phase = 'input'; // 'input', 'verify'
  bool _canResend = false;
  int _resendCountdown = 30;

  @override
  void dispose() {
    _contactController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
        }
      });
      return _resendCountdown > 0;
    });
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final contact = _contactController.text.trim();

    final success = await authNotifier.startOtpSignIn(
      email: _isPhone ? null : contact,
      phone: _isPhone ? contact : null,
    );

    if (success && mounted) {
      setState(() {
        _phase = 'verify';
      });
      _startResendCountdown();
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOtp(code);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in successfully!'),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.resendOtp();
    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  _phase == 'input' ? 'Sign In' : 'Enter Code',
                  style: context.textTheme.headlineMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).cancelOtpFlow();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _phase == 'input'
                  ? 'Enter your email or phone to receive a verification code'
                  : 'A 6-digit code was sent to ${_contactController.text}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (auth.otpError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.circleAlert, color: context.colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.otpError!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_phase == 'input') ...[
              // Toggle email/phone
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Email')),
                  ButtonSegment(value: true, label: Text('Phone')),
                ],
                selected: {_isPhone},
                onSelectionChanged: (value) {
                  setState(() {
                    _isPhone = value.first;
                    _contactController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Contact input
              TextFormField(
                controller: _contactController,
                keyboardType: _isPhone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                inputFormatters: _isPhone
                    ? const [UsPhoneInputFormatter()]
                    : null,
                decoration: InputDecoration(
                  labelText: _isPhone ? 'Phone Number' : 'Email Address',
                  hintText: _isPhone ? '(555) 123-4567' : 'you@example.com',
                  prefixIcon: Icon(
                    _isPhone ? LucideIcons.phone : LucideIcons.mail,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  return _isPhone
                      ? AppValidators.usPhone()(value)
                      : AppValidators.email()(value);
                },
              ),
              const SizedBox(height: 24),

              // Send code button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _sendCode,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Code'),
                ),
              ),
            ] else ...[
              // Code input
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '000000',
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _canResend && !auth.isLoading
                        ? _resendCode
                        : null,
                    child: Text(
                      _canResend
                          ? 'Resend Code'
                          : 'Resend in ${_resendCountdown}s',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _verifyCode,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 8),

              // Back button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).cancelOtpFlow();
                    setState(() {
                      _phase = 'input';
                      _codeController.clear();
                    });
                  },
                  child: const Text('Use a different email or phone'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Delete Account Confirmation Dialog
/// Requires user to type "DELETE" to confirm the destructive action
class _DeleteAccountDialog extends ConsumerStatefulWidget {
  final VoidCallback onDeleted;

  const _DeleteAccountDialog({required this.onDeleted});

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      _confirmController.text.toUpperCase().trim() == 'DELETE';

  Future<void> _handleDelete() async {
    if (!_canDelete || _isDeleting) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).deleteAccount();

      if (mounted) {
        Navigator.of(context).pop();
        widget.onDeleted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _error = UserErrorMessage.from(
            e,
            fallback: 'Unable to delete your account. Please try again.',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final customer = auth.customer;
    final user = auth.user;

    // Get user identifier for display
    final userIdentifier = customer?.email ??
        user?.email ??
        customer?.phone ??
        user?.phone ??
        'your account';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.errorBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.triangleAlert,
              color: context.colors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Delete Account',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will permanently remove:',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // What will be deleted list
            _buildDeleteItem(context, LucideIcons.user, 'Your profile information'),
            _buildDeleteItem(context, LucideIcons.mapPin, 'Saved addresses'),
            _buildDeleteItem(context, LucideIcons.star, 'Loyalty stars & rewards'),
            _buildDeleteItem(
              context,
              LucideIcons.receipt,
              'Order history link (orders are anonymized)',
            ),
            const SizedBox(height: 20),
            // Account identifier
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleUser,
                    size: 18,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userIdentifier,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Confirmation input
            Text(
              'Type DELETE to confirm:',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              enabled: !_isDeleting,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            // Error message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circleAlert,
                      size: 16,
                      color: context.colors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: _canDelete && !_isDeleting ? _handleDelete : null,
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            disabledBackgroundColor: context.colors.error.withOpacity(0.3),
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete Account'),
        ),
      ],
    );
  }

  Widget _buildDeleteItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.colors.error.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
