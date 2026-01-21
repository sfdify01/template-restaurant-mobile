import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../core/utils/us_phone_input_formatter.dart';
import '../../../../core/validators/app_validators.dart';
import '../../providers/auth_provider.dart';

/// Register method options
enum RegisterMethod { emailOtp, phoneOtp, password }

/// Register phases
enum RegisterPhase { select, otpVerify, passwordForm }

@RoutePage()
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  PhoneNumber? _phoneNumber;

  RegisterMethod _method = RegisterMethod.emailOtp;
  RegisterPhase _phase = RegisterPhase.select;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _agreedToTerms = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
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

  Future<void> _handleSendOtp() async {
    if (_method == RegisterMethod.emailOtp) {
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

    if (!_agreedToTerms) {
      setState(
        () => _errorMessage = 'Please agree to the terms and conditions',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .startOtpSignIn(
            email: _method == RegisterMethod.emailOtp ? _identifier : null,
            phone: _method == RegisterMethod.phoneOtp ? _identifier : null,
          );

      if (success && mounted) {
        setState(() {
          _phase = RegisterPhase.otpVerify;
          _isLoading = false;
        });
        _startResendCountdown();
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
        // Update user profile with name if provided
        final name = _nameController.text.trim();
        if (name.isNotEmpty) {
          await ref
              .read(authProvider.notifier)
              .ensureCustomer(
                name: name,
                email: _method == RegisterMethod.emailOtp ? _identifier : '',
                phone: _method == RegisterMethod.phoneOtp ? _identifier : null,
              );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

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

  Future<void> _handlePasswordRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneNumber?.completeNumber.isNotEmpty == true
                ? _phoneNumber!.completeNumber
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Please check your email to verify.',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.router.replace(const MainShellRoute());
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = UserErrorMessage.from(
          e,
          fallback: 'Unable to create account. Please try again.',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = UserErrorMessage.from(
          e,
          fallback: 'Unable to create account. Please try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetToSelect() {
    ref.read(authProvider.notifier).cancelOtpFlow();
    setState(() {
      _phase = RegisterPhase.select;
      _errorMessage = null;
      _otpError = null;
      _clearOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.router.maybePop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentPhase(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case RegisterPhase.otpVerify:
        return _buildOtpVerifyPhase();
      case RegisterPhase.passwordForm:
        return _buildPasswordPhase();
      case RegisterPhase.select:
        return _buildSelectPhase();
    }
  }

  Widget _buildSelectPhase() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join Shahirizada Fresh Market and start earning rewards',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

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
                    isSelected: _method == RegisterMethod.emailOtp,
                    onTap: () =>
                        setState(() => _method = RegisterMethod.emailOtp),
                  ),
                ),
                Expanded(
                  child: _buildMethodButton(
                    label: 'Phone',
                    icon: LucideIcons.phone,
                    isSelected: _method == RegisterMethod.phoneOtp,
                    onTap: () =>
                        setState(() => _method = RegisterMethod.phoneOtp),
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

          // Name field (optional for OTP signup)
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Full Name (Optional)',
              prefixIcon: Icon(LucideIcons.user),
            ),
          ),
          const SizedBox(height: 16),

          // Input field based on method
          if (_method == RegisterMethod.emailOtp) ...[
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
              "We'll send you a one-time code to create your account",
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
              "We'll text you a one-time code to create your account",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 24),

          // Terms and conditions
          _buildTermsCheckbox(),
          const SizedBox(height: 24),

          // Create Account Button
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
                      'Create Account',
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

          // Password Signup Option
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _phase = RegisterPhase.passwordForm),
              icon: const Icon(LucideIcons.keyRound),
              label: const Text(
                'Sign up with password',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => context.router.maybePop(),
                child: const Text('Sign In'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rewards info
          _buildRewardsInfo(),
        ],
      ),
    );
  }

  Widget _buildOtpVerifyPhase() {
    final isPhone = _method == RegisterMethod.phoneOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _resetToSelect,
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
            label: const Text('Back'),
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
                maxLength: 1,
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
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
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  }
                  if (index == 5 && value.isNotEmpty) {
                    _handleVerifyOtp();
                  }
                  setState(() {});
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
                    'Verify & Create Account',
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
              label: const Text('Back to signup options'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up with email and password',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          // Name field
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(LucideIcons.user),
            ),
            validator: AppValidators.name(label: 'name'),
          ),
          const SizedBox(height: 16),

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

          // Phone field
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '(555) 555-5555',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            initialCountryCode: 'US',
            disableLengthCheck: true,
            enabled: !_isLoading,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            dropdownIcon: const Icon(
              LucideIcons.chevronDown,
              color: AppTheme.primaryColor,
            ),
            flagsButtonPadding: const EdgeInsets.only(left: 12),
            showDropdownIcon: true,
            dropdownIconPosition: IconPosition.trailing,
            onChanged: (phone) => _phoneNumber = phone,
            validator: AppValidators.usPhoneIntl(required: false),
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
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
          const SizedBox(height: 16),

          // Confirm Password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(LucideIcons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? LucideIcons.eye
                      : LucideIcons.eyeOff,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
            validator: AppValidators.confirmPassword(_passwordController),
          ),
          const SizedBox(height: 16),

          // Referral code field
          TextFormField(
            controller: _referralCodeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Referral Code (Optional)',
              prefixIcon: Icon(LucideIcons.gift),
              hintText: "Enter friend's code for bonus stars",
            ),
          ),
          const SizedBox(height: 24),

          // Terms and conditions
          _buildTermsCheckbox(),
          const SizedBox(height: 24),

          // Create account button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePasswordRegister,
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
                      'Create Account',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => context.router.maybePop(),
                child: const Text('Sign In'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rewards info
          _buildRewardsInfo(),
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
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: _isLoading
                ? null
                : (value) => setState(() => _agreedToTerms = value ?? false),
            activeColor: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () => context.router.push(PrivacyPolicyRoute()),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.star, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earn Stars with Every Order',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get 1 star per \$1 spent. Redeem for discounts!',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
