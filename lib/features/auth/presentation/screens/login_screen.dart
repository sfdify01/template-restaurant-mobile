import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../core/utils/us_phone_input_formatter.dart';
import '../../../../core/validators/app_validators.dart';
import '../../providers/auth_provider.dart';

/// Auth method options (matches web LoginForm)
enum AuthMethod { emailOtp, phoneOtp, password }

/// Login phases (matches web LoginForm)
enum LoginPhase { select, otpVerify, passwordForm }

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthMethod _method = AuthMethod.emailOtp;
  LoginPhase _phase = LoginPhase.select;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // OTP verification state
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String? _otpError;
  bool _canResend = false;
  int _resendCountdown = 30;
  String _identifier = '';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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

  void _handleOtpPaste(String pastedValue) {
    // Extract only digits from pasted value
    final digits = pastedValue.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return;

    // Distribute digits across OTP fields
    for (var i = 0; i < 6; i++) {
      if (i < digits.length) {
        _otpControllers[i].text = digits[i];
      } else {
        _otpControllers[i].clear();
      }
    }

    // Move focus to appropriate field
    if (digits.length >= 6) {
      // Full code pasted - focus last field and auto-verify
      _otpFocusNodes[5].requestFocus();
      setState(() {});
      _handleVerifyOtp();
    } else {
      // Partial paste - focus next empty field
      _otpFocusNodes[digits.length.clamp(0, 5)].requestFocus();
      setState(() {});
    }
  }

  Future<void> _handleSendOtp() async {
    if (_method == AuthMethod.emailOtp) {
      final email = _emailController.text.trim();
      final error = AppValidators.email()(email);
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
      _identifier = email;
    } else {
      final phone = _phoneController.text.trim();
      final error = AppValidators.usPhone()(phone);
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
      _identifier = phone;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .startOtpSignIn(
            email: _method == AuthMethod.emailOtp ? _identifier : null,
            phone: _method == AuthMethod.phoneOtp ? _identifier : null,
          );

      if (success && mounted) {
        setState(() {
          _phase = LoginPhase.otpVerify;
          _isLoading = false;
        });
        _startResendCountdown();
        // Focus first OTP field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _otpFocusNodes[0].requestFocus();
        });
      } else {
        final authState = ref.read(authProvider);
        setState(() {
          _errorMessage = authState.otpError ?? 'Failed to send code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send code. Please try again.';
        _isLoading = false;
      });
    }
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

      if (success && mounted) {
        context.router.replace(const MainShellRoute());
      } else {
        final authState = ref.read(authProvider);
        setState(() {
          _otpError = UserErrorMessage.from(
            authState.otpError,
            fallback: 'Invalid code. Please try again.',
          );
          _isLoading = false;
        });
        _clearOtp();
      }
    } catch (e) {
      setState(() {
        _otpError = UserErrorMessage.from(
          e,
          fallback: 'Verification failed. Please try again.',
        );
        _isLoading = false;
      });
      _clearOtp();
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
          const SnackBar(
            content: Text('Code resent successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _otpError = 'Failed to resend code');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

      if (mounted) {
        context.router.replace(const MainShellRoute());
      }
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
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset email'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _resetToSelect() {
    ref.read(authProvider.notifier).cancelOtpFlow();
    setState(() {
      _phase = LoginPhase.select;
      _errorMessage = null;
      _otpError = null;
      _passwordController.clear();
      _clearOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentPhase(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(LucideIcons.store, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Shahirizada',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'Fresh Market',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case LoginPhase.otpVerify:
        return _buildOtpVerifyPhase();
      case LoginPhase.passwordForm:
        return _buildPasswordPhase();
      case LoginPhase.select:
        return _buildSelectPhase();
    }
  }

  Widget _buildSelectPhase() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue shopping',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Method Toggle (Email / Phone)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMethodButton(
                    label: 'Email',
                    icon: LucideIcons.mail,
                    isSelected: _method == AuthMethod.emailOtp,
                    onTap: () => setState(() => _method = AuthMethod.emailOtp),
                  ),
                ),
                Expanded(
                  child: _buildMethodButton(
                    label: 'Phone',
                    icon: LucideIcons.phone,
                    isSelected: _method == AuthMethod.phoneOtp,
                    onTap: () => setState(() => _method = AuthMethod.phoneOtp),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          // Input field based on method
          if (_method == AuthMethod.emailOtp) ...[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(LucideIcons.mail),
              ),
              validator: AppValidators.email(),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll send you a one-time code to sign in securely",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ] else ...[
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(LucideIcons.phone),
                hintText: '(555) 123-4567',
              ),
              inputFormatters: const [UsPhoneInputFormatter()],
              validator: AppValidators.usPhone(),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll text you a one-time code to sign in securely",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 24),

          // Send Code Button
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
                  : const Text(
                      'Send Sign-In Code',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: TextStyle(color: Colors.grey[500])),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 24),

          // Password Login Option
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _phase = LoginPhase.passwordForm),
              icon: const Icon(LucideIcons.keyRound),
              label: const Text(
                'Sign in with password',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => context.router.push(const RegisterRoute()),
                child: const Text('Sign Up'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Continue as guest
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => context.router.replace(const MainShellRoute()),
              child: Text(
                'Continue as Guest',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tagline
          Text(
            'Halal, never-frozen meats\nFreshly cut daily in Naperville',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Privacy Policy
          TextButton(
            onPressed: _isLoading
                ? null
                : () => context.router.push(PrivacyPolicyRoute()),
            child: const Text(
              'Privacy Policy & Terms of Use',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerifyPhase() {
    final isPhone = _method == AuthMethod.phoneOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _resetToSelect,
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
            label: const Text('Back to login'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
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
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 28,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Check your ${isPhone ? 'phone' : 'inbox'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                _identifier,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // OTP Input
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 48,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6, // Allow paste of full code
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _otpControllers[index].text.isNotEmpty
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _otpControllers[index].text.isNotEmpty
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: _otpControllers[index].text.isNotEmpty
                      ? AppTheme.primaryColor.withValues(alpha: 0.05)
                      : Colors.white,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  // Handle paste of full OTP code (6 digits)
                  if (value.length > 1) {
                    _handleOtpPaste(value);
                    return;
                  }
                  // Single digit entry - move to next field
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  }
                  if (index == 5 && value.isNotEmpty) {
                    // Auto-verify when last digit entered
                    _handleVerifyOtp();
                  }
                  setState(() {}); // Refresh UI for border colors
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // OTP Error
        if (_otpError != null) ...[
          _buildErrorBanner(_otpError!),
          const SizedBox(height: 16),
        ],

        // Actions row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _resetToSelect,
              child: Text(
                'Wrong ${isPhone ? 'number' : 'email'}?',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _canResend && !_isLoading ? _handleResendOtp : null,
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
        const SizedBox(height: 24),

        // Verify Button
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
                : const Text(
                    'Verify & Sign In',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordPhase() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _resetToSelect,
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              label: const Text('Back to login options'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          const Text(
            'Sign in with password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your email and password to continue',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
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
                  : const Text('Sign In', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => context.router.push(const RegisterRoute()),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
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
              color: isSelected ? AppTheme.textPrimary : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.textPrimary : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleAlert, color: AppTheme.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
