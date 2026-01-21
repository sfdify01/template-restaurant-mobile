import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../core/utils/us_phone_input_formatter.dart';
import '../../../../core/validators/app_validators.dart';
import '../../providers/auth_provider.dart';

/// Routes for the auth sheet navigation
enum AuthSheetRoute { methodSelect, otpVerify, passwordForm }

/// Shows the auth sheet modal
Future<bool?> showAuthSheet(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<bool>(
    ModalSheetRoute(
      builder: (context) => const AuthSheet(),
      swipeDismissible: true,
    ),
  );
}

/// Auth sheet with inner navigation between OTP and password login
class AuthSheet extends ConsumerStatefulWidget {
  const AuthSheet({super.key});

  @override
  ConsumerState<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<AuthSheet> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (prev, next) {
      // If user becomes authenticated, close the sheet with success
      if (next.isAuthenticated && !(prev?.isAuthenticated ?? false)) {
        Navigator.of(context).pop(true);
      }
    });

    return NavigationSheet(
      transitionObserver: NavigationSheetTransitionObserver(),
      child: Material(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Navigator(
          key: _navigator,
          initialRoute: AuthSheetRoute.methodSelect.name,
          onGenerateRoute: (settings) {
            final route = AuthSheetRoute.values.firstWhere(
              (r) => r.name == settings.name,
              orElse: () => AuthSheetRoute.methodSelect,
            );

            return _buildRoute(route, settings);
          },
        ),
      ),
    );
  }

  PageRoute<dynamic> _buildRoute(AuthSheetRoute route, RouteSettings settings) {
    Widget page;
    switch (route) {
      case AuthSheetRoute.methodSelect:
        page = _MethodSelectPage(
          onOtpSelected: (identifier, isPhone) {
            _navigator.currentState?.pushNamed(
              AuthSheetRoute.otpVerify.name,
              arguments: {'identifier': identifier, 'isPhone': isPhone},
            );
          },
          onPasswordSelected: () {
            _navigator.currentState?.pushNamed(
              AuthSheetRoute.passwordForm.name,
            );
          },
        );
        break;
      case AuthSheetRoute.otpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        page = _OtpVerifyPage(
          identifier: args?['identifier'] as String? ?? '',
          isPhone: args?['isPhone'] as bool? ?? false,
          onBack: () => _navigator.currentState?.pop(),
        );
        break;
      case AuthSheetRoute.passwordForm:
        page = _PasswordFormPage(onBack: () => _navigator.currentState?.pop());
        break;
    }

    return ScrollableNavigationSheetRoute(
      builder: (context) => SheetContentScaffold(body: page),
    );
  }
}

/// Method selection page - choose between OTP (email/phone) or password
class _MethodSelectPage extends ConsumerStatefulWidget {
  final void Function(String identifier, bool isPhone) onOtpSelected;
  final VoidCallback onPasswordSelected;

  const _MethodSelectPage({
    required this.onOtpSelected,
    required this.onPasswordSelected,
  });

  @override
  ConsumerState<_MethodSelectPage> createState() => _MethodSelectPageState();
}

class _MethodSelectPageState extends ConsumerState<_MethodSelectPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _usePhone = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _usePhone
        ? _phoneController.text.trim()
        : _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .startOtpSignIn(
            email: _usePhone ? null : identifier,
            phone: _usePhone ? identifier : null,
          );

      if (success && mounted) {
        widget.onOtpSelected(identifier, _usePhone);
      } else {
        final authState = ref.read(authProvider);
        setState(() {
          _errorMessage = authState.otpError ?? 'Failed to send code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send code. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.logIn,
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sign In', style: context.textTheme.titleLarge),
                        Text(
                          'Access your account',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Method toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _MethodButton(
                        label: 'Email',
                        icon: LucideIcons.mail,
                        isSelected: !_usePhone,
                        onTap: () => setState(() => _usePhone = false),
                      ),
                    ),
                    Expanded(
                      child: _MethodButton(
                        label: 'Phone',
                        icon: LucideIcons.phone,
                        isSelected: _usePhone,
                        onTap: () => setState(() => _usePhone = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Error message
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],

              // Input field
              if (_usePhone)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: const Icon(LucideIcons.phone),
                    hintText: '(555) 123-4567',
                  ),
                  inputFormatters: const [UsPhoneInputFormatter()],
                  validator: AppValidators.usPhone(),
                )
              else
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: const Icon(LucideIcons.mail),
                  ),
                  validator: AppValidators.email(),
                ),
              const SizedBox(height: 8),

              Text(
                _usePhone
                    ? "We'll text you a one-time code"
                    : "We'll send you a one-time code",
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              const SizedBox(height: 20),

              // Send OTP button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send Sign-In Code'),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.borderLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.borderLight)),
                ],
              ),
              const SizedBox(height: 16),

              // Password login option
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : widget.onPasswordSelected,
                  icon: const Icon(LucideIcons.keyRound),
                  label: const Text('Sign in with password'),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OTP verification page
class _OtpVerifyPage extends ConsumerStatefulWidget {
  final String identifier;
  final bool isPhone;
  final VoidCallback onBack;

  const _OtpVerifyPage({
    required this.identifier,
    required this.isPhone,
    required this.onBack,
  });

  @override
  ConsumerState<_OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends ConsumerState<_OtpVerifyPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _otpError;
  bool _canResend = false;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    // Focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
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
      return _resendCountdown > 0 && mounted;
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpCode;
    if (code.length != 6) {
      setState(() => _otpError = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final success = await ref.read(authProvider.notifier).verifyOtp(code);

      if (!success && mounted) {
        final authState = ref.read(authProvider);
        setState(() {
          _otpError = authState.otpError ?? 'Invalid code';
        });
        _clearOtp();
      }
      // If success, the auth state listener in AuthSheet will close the sheet
    } catch (e) {
      setState(() {
        _otpError = 'Verification failed. Please try again.';
      });
      _clearOtp();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).resendOtp();
      if (success && mounted) {
        _startResendCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code resent successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _otpError = 'Failed to resend code');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).cancelOtpFlow();
                  widget.onBack();
                },
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      LucideIcons.sparkles,
                      size: 28,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Check your ${widget.isPhone ? 'phone' : 'inbox'}',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.identifier,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 44,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    enabled: !_isLoading,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _otpControllers[index].text.isNotEmpty
                              ? context.colors.primary
                              : context.colors.borderLight,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _otpControllers[index].text.isNotEmpty
                              ? context.colors.primary
                              : context.colors.borderLight,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.colors.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: _otpControllers[index].text.isNotEmpty
                          ? context.colors.primary.withValues(alpha: 0.05)
                          : context.colors.surface,
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      }
                      if (index == 5 && value.isNotEmpty) {
                        _handleVerifyOtp();
                      }
                      setState(() {}); // Refresh UI for border colors
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Error
            if (_otpError != null) ...[
              _ErrorBanner(message: _otpError!),
              const SizedBox(height: 16),
            ],

            // Resend row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).cancelOtpFlow();
                    widget.onBack();
                  },
                  child: Text(
                    'Wrong ${widget.isPhone ? 'number' : 'email'}?',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _canResend && !_isLoading
                      ? _handleResendOtp
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_canResend) ...[
                        const Icon(LucideIcons.refreshCcw, size: 14),
                        const SizedBox(width: 4),
                        const Text('Resend code'),
                      ] else
                        Text('Resend in ${_resendCountdown}s'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Verify button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading || _otpCode.length != 6
                    ? null
                    : _handleVerifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify & Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Password form page
class _PasswordFormPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const _PasswordFormPage({required this.onBack});

  @override
  ConsumerState<_PasswordFormPage> createState() => _PasswordFormPageState();
}

class _PasswordFormPageState extends ConsumerState<_PasswordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // If successful, the auth state listener in AuthSheet will close the sheet
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = UserErrorMessage.from(
          e,
          fallback: 'Unable to sign in. Please try again.',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = UserErrorMessage.from(
          e,
          fallback: 'Unable to sign in. Please try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send reset email'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.keyRound,
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Sign In',
                          style: context.textTheme.titleLarge,
                        ),
                        Text(
                          'Enter your credentials',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(LucideIcons.mail),
                ),
                validator: AppValidators.email(),
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handlePasswordLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: AppValidators.password(),
              ),
              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),

              // Sign in button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePasswordLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable method button widget
class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable error banner widget
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, color: context.colors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
