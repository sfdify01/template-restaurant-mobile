import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_error_messages.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../auth/providers/auth_provider.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  PhoneNumber? _phoneNumber;
  String? _initialPhoneNumber;
  bool _isSaving = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFields();
    });
  }

  void _prefillFields() {
    if (_hasInitialized) return;

    final authState = ref.read(authProvider);
    final customer = authState.customer;
    final user = authState.user;

    // Try to get data from customer first, then from user metadata
    if (customer != null) {
      _firstNameController.text = customer.firstName ?? '';
      _lastNameController.text = customer.lastName ?? '';
      _emailController.text = customer.email ?? user?.email ?? '';
      _initialPhoneNumber = customer.phone;
      _hasInitialized = true;
    } else if (user != null) {
      // Fallback to user metadata for new users without customer record
      final metadata = user.userMetadata;
      final name = metadata?['name'] as String? ?? '';
      final nameParts = name.split(' ');

      _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      _lastNameController.text = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';
      _emailController.text = user.email ?? '';
      _initialPhoneNumber = metadata?['phone'] as String? ?? user.phone;
      _hasInitialized = true;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for auth state changes to update fields
    ref.listen(authProvider, (prev, next) {
      if (!_hasInitialized && next.customer != null) {
        _prefillFields();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor,
                      child: IconButton(
                        icon: const Icon(LucideIcons.camera, size: 18),
                        color: Colors.white,
                        onPressed: () {
                          // TODO: Pick image
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                prefixIcon: Icon(LucideIcons.user),
              ),
              textCapitalization: TextCapitalization.words,
              validator: AppValidators.name(label: 'first name'),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(LucideIcons.user),
              ),
              textCapitalization: TextCapitalization.words,
              validator: AppValidators.name(label: 'last name', required: false),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(LucideIcons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.email(),
            ),
            const SizedBox(height: 16),

            // Phone with country code
            // Key forces rebuild when initial data loads so initialValue takes effect
            IntlPhoneField(
              key: ValueKey('phone_field_$_hasInitialized'),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '(555) 123-4567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialCountryCode: 'US',
              initialValue: _extractPhoneNumber(_initialPhoneNumber),
              disableLengthCheck: true,
              keyboardType: TextInputType.phone,
              dropdownIcon: const Icon(
                LucideIcons.chevronDown,
                color: AppTheme.primaryColor,
              ),
              flagsButtonPadding: const EdgeInsets.only(left: 12),
              showDropdownIcon: true,
              dropdownIconPosition: IconPosition.trailing,
              onChanged: (phone) {
                _phoneNumber = phone;
              },
              validator: AppValidators.usPhoneIntl(),
            ),
          ],
        ),
      ),
    );
  }

  /// Extract just the number part from E.164 format for display
  String? _extractPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    // Remove the +1 country code if present
    if (phone.startsWith('+1')) {
      return phone.substring(2);
    }
    if (phone.startsWith('+')) {
      // For other country codes, just return as-is
      return phone.substring(1);
    }
    return phone;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      // Get phone number in E.164 format
      String? phoneNumber;
      if (_phoneNumber != null && _phoneNumber!.number.isNotEmpty) {
        phoneNumber = _phoneNumber!.completeNumber;
      }

      final customer = await ref
          .read(authProvider.notifier)
          .ensureCustomer(
            name: fullName,
            email: _emailController.text.trim(),
            phone: phoneNumber,
          );

      if (!mounted) return;

      if (customer != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.router.maybePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserErrorMessage.from(
              e,
              fallback: 'Failed to update profile. Please try again.',
            ),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
