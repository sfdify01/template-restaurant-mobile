import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env_config.dart';
import '../../../core/services/onesignal_service.dart';
import '../../../core/services/push_token_sync_service.dart';
import '../../../core/utils/user_error_messages.dart';
import '../../../main.dart';
import '../../../data/models/models.dart';

part 'auth_provider.g.dart';

/// OTP auth flow tracking (matches web auth flow pattern)
class AuthFlow {
  final String id;
  final String method; // 'email' or 'sms'
  final String identifier; // email or phone
  final DateTime expiresAt;

  const AuthFlow({
    required this.id,
    required this.method,
    required this.identifier,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Auth state with user and customer data
class AuthState {
  final User? user;
  final Customer? customer;
  final bool isLoading;
  final AuthFlow? activeFlow;
  final String? otpError;

  const AuthState({
    this.user,
    this.customer,
    this.isLoading = false,
    this.activeFlow,
    this.otpError,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    Customer? customer,
    bool? isLoading,
    AuthFlow? activeFlow,
    String? otpError,
    bool clearFlow = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      customer: customer ?? this.customer,
      isLoading: isLoading ?? this.isLoading,
      activeFlow: clearFlow ? null : (activeFlow ?? this.activeFlow),
      otpError: clearError ? null : (otpError ?? this.otpError),
    );
  }
}

/// Auth notifier using latest Riverpod syntax
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  String? _onesignalUserId;

  @override
  AuthState build() {
    // Listen to auth state changes
    _listenToAuthChanges();

    // Get initial session
    final session = supabase.auth.currentSession;
    if (session != null) {
      _loadCustomer(session.user);
      unawaited(_loginToOneSignal(session.user));
      return AuthState(user: session.user);
    }

    return const AuthState();
  }

  void _listenToAuthChanges() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if ((event == AuthChangeEvent.signedIn ||
              event == AuthChangeEvent.initialSession) &&
          session != null) {
        state = AuthState(user: session.user);
        _loadCustomer(session.user);
        await _loginToOneSignal(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState();
        _onesignalUserId = null;
        PushTokenSyncService.instance.clearUser();
        await OneSignalService.instance.logout();
      }
    });
  }

  Future<void> _loginToOneSignal(User user) async {
    if (_onesignalUserId == user.id) {
      // Already logged in, but trigger a sync check anyway
      unawaited(PushTokenSyncService.instance.forceSync());
      return;
    }

    try {
      _onesignalUserId = user.id;

      // Set user ID in sync service - this triggers a sync attempt
      unawaited(PushTokenSyncService.instance.setUserId(user.id));

      await OneSignalService.instance.login(user.id);

      if (user.email != null) {
        await OneSignalService.instance.setEmail(user.email!);
      }

      if (user.phone != null) {
        await OneSignalService.instance.setPhoneNumber(user.phone!);
      }

      // Trigger another sync after OneSignal login completes
      unawaited(PushTokenSyncService.instance.forceSync());

      if (kDebugMode) {
        debugPrint('[Auth] OneSignal login complete for user: ${user.id}');
      }
    } catch (e) {
      _onesignalUserId = null;
      PushTokenSyncService.instance.clearUser();
      if (kDebugMode) {
        debugPrint('[Auth] OneSignal login error: $e');
      }
    }
  }

  Future<void> _loadCustomer(User user) async {
    try {
      final response = await supabase
          .from('customers')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (response != null) {
        final customer = CustomerMapper.fromMap(response);
        state = state.copyWith(customer: customer);
      }
    } catch (e) {
      // Customer might not exist yet
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (response.user != null) {
        // Update state with the new user immediately
        state = state.copyWith(user: response.user, isLoading: false);
        // Customer record is created via database trigger
        await _loadCustomer(response.user!);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await OneSignalService.instance.logout();
    await supabase.auth.signOut();
    state = const AuthState();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  /// Sign in anonymously (for guest checkout)
  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true);
    try {
      await supabase.auth.signInAnonymously();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Check if current user is anonymous
  bool get isAnonymous => state.user?.isAnonymous ?? false;

  /// Convert anonymous user to permanent account (password-based)
  Future<void> linkEmailToAnonymous({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    if (!isAnonymous) return;

    state = state.copyWith(isLoading: true);
    try {
      // Update anonymous user with email/password
      await supabase.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: {'name': name, 'phone': phone},
        ),
      );

      // Reload customer data
      if (state.user != null) {
        await _loadCustomer(state.user!);
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ==========================================================================
  // OTP-BASED AUTHENTICATION (matches web signInWithOtp pattern)
  // ==========================================================================

  /// Start OTP sign-in flow - sends code to email or phone
  /// Matches web: startAuth() in src/lib/auth/client.ts
  Future<bool> startOtpSignIn({String? email, String? phone}) async {
    if (email == null && phone == null) {
      state = state.copyWith(otpError: 'Email or phone is required');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final method = email != null ? 'email' : 'sms';
      final identifier = (email ?? phone)!.trim();

      if (method == 'email') {
        await supabase.auth.signInWithOtp(
          email: identifier,
          shouldCreateUser: true,
        );
      } else {
        // Normalize phone to E.164 format if needed
        String normalizedPhone = identifier;
        if (!identifier.startsWith('+')) {
          // Assume US number if no country code
          normalizedPhone = '+1${identifier.replaceAll(RegExp(r'[^\d]'), '')}';
        }

        await supabase.auth.signInWithOtp(
          phone: normalizedPhone,
          shouldCreateUser: true,
        );
      }

      // Create auth flow with 10-minute expiry (matches web)
      final flow = AuthFlow(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: method,
        identifier: identifier,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      state = state.copyWith(isLoading: false, activeFlow: flow);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        otpError: UserErrorMessage.from(
          e,
          fallback: 'Failed to send verification code. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Verify OTP code - completes sign-in
  /// Matches web: verifyAuth() in src/lib/auth/client.ts
  Future<bool> verifyOtp(String code) async {
    final flow = state.activeFlow;
    if (flow == null) {
      state = state.copyWith(
        otpError: 'No active verification. Please start again.',
      );
      return false;
    }

    if (flow.isExpired) {
      state = state.copyWith(
        otpError: 'Verification code expired. Please request a new one.',
        clearFlow: true,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final AuthResponse response;

      if (flow.method == 'email') {
        response = await supabase.auth.verifyOTP(
          type: OtpType.email,
          email: flow.identifier,
          token: code,
        );
      } else {
        // Phone verification
        String normalizedPhone = flow.identifier;
        if (!flow.identifier.startsWith('+')) {
          normalizedPhone =
              '+1${flow.identifier.replaceAll(RegExp(r'[^\d]'), '')}';
        }

        response = await supabase.auth.verifyOTP(
          type: OtpType.sms,
          phone: normalizedPhone,
          token: code,
        );
      }

      if (response.session == null || response.user == null) {
        throw Exception('Invalid or expired code');
      }

      // Success - auth state change listener will update state
      state = state.copyWith(
        isLoading: false,
        clearFlow: true,
        user: response.user,
      );

      // Load or create customer profile
      await _loadCustomer(response.user!);

      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        otpError: UserErrorMessage.from(
          e,
          fallback: 'Verification failed. Please try again.',
        ),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        otpError: UserErrorMessage.from(
          e,
          fallback: 'Verification failed. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Resend OTP code
  Future<bool> resendOtp() async {
    final flow = state.activeFlow;
    if (flow == null) return false;

    return startOtpSignIn(
      email: flow.method == 'email' ? flow.identifier : null,
      phone: flow.method == 'sms' ? flow.identifier : null,
    );
  }

  /// Cancel active OTP flow
  void cancelOtpFlow() {
    state = state.copyWith(clearFlow: true, clearError: true);
  }

  /// Link anonymous account with OTP (sign-up-on-the-air)
  /// This upgrades a guest checkout to a full account
  Future<bool> linkAnonymousWithOtp({String? email, String? phone}) async {
    if (!isAnonymous) {
      state = state.copyWith(otpError: 'Already signed in with an account');
      return false;
    }

    // For anonymous users, we update their email/phone first, then verify
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (email != null) {
        await supabase.auth.updateUser(UserAttributes(email: email));
      } else if (phone != null) {
        String normalizedPhone = phone;
        if (!phone.startsWith('+')) {
          normalizedPhone = '+1${phone.replaceAll(RegExp(r'[^\d]'), '')}';
        }
        await supabase.auth.updateUser(UserAttributes(phone: normalizedPhone));
      }

      // Now start OTP flow for verification
      state = state.copyWith(isLoading: false);
      return await startOtpSignIn(email: email, phone: phone);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        otpError: UserErrorMessage.from(
          e,
          fallback: 'Failed to update account. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Delete the current user's account and all associated data
  /// Returns true on success, throws on failure
  Future<bool> deleteAccount() async {
    if (state.user == null) {
      throw Exception('Not authenticated');
    }

    state = state.copyWith(isLoading: true);

    try {
      // Get the current session token
      final session = supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session');
      }

      // Call the delete account endpoint
      final response = await supabase.functions.invoke(
        'market-server/account/delete',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.status != 200) {
        final error = response.data?['error'] ?? 'Failed to delete account';
        throw Exception(error);
      }

      // Clear local state
      state = const AuthState();

      // Sign out locally (the server already deleted the auth user)
      try {
        await supabase.auth.signOut();
      } catch (_) {
        // Ignore sign out errors since user is already deleted
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Create or update customer record for current user
  Future<Customer?> ensureCustomer({
    required String name,
    required String email,
    String? phone,
  }) async {
    if (state.user == null) return null;

    // Parse name into first/last
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : null;

    try {
      // HANDLE ORPHAN EMAIL CLAIMING:
      // If the email being set matches the current authenticated user's email,
      // we check if there's an "orphan" customer record (no auth_user_id) with this email.
      // If so, we claim it (link it to our auth_user_id) to avoid unique constraint errors.
      if (email.isNotEmpty &&
          email.toLowerCase() == state.user?.email?.toLowerCase()) {
        try {
          await supabase.rpc('claim_orphan_email', params: {'p_email': email});
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to claim orphan email via RPC: $e');
          }
        }
      }
      // HANDLE PHONE STEALING:
      // If phone is provided, check if another user has it. If so, remove it from them.
      // We use a database function (RPC) to bypass RLS policies.
      if (phone != null && phone.isNotEmpty) {
        try {
          await supabase.rpc('claim_phone_number', params: {'p_phone': phone});
        } catch (e) {
          // If the RPC is missing or fails, we log it but don't block the flow.
          // The unique constraint will still catch duplicates if this failed.
          if (kDebugMode) {
            debugPrint('⚠️ Failed to claim phone number via RPC: $e');
          }
        }
      }

      // Check if customer exists
      final existing = await supabase
          .from('customers')
          .select()
          .eq('auth_user_id', state.user!.id)
          .maybeSingle();

      if (existing != null) {
        // Update existing customer
        final response = await supabase
            .from('customers')
            .update({
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'phone': phone,
            })
            .eq('auth_user_id', state.user!.id)
            .select()
            .single();
        final customer = CustomerMapper.fromMap(response);
        state = state.copyWith(customer: customer);
        await _updateOneSignalCustomerInfo(customer);

        return customer;
      } else {
        final response = await supabase
            .from('customers')
            .insert({
              'tenant_id': EnvConfig.tenantId,
              'auth_user_id': state.user!.id,
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'phone': phone,
            })
            .select()
            .single();
        final customer = CustomerMapper.fromMap(response);
        state = state.copyWith(customer: customer);
        await _updateOneSignalCustomerInfo(customer);

        return customer;
      }
    } on PostgrestException catch (e) {
      // Handle unique constraint violations
      if (e.code == '23505') {
        if (e.message.contains('email') ||
            e.details.toString().contains('email')) {
          throw 'This email is already associated with another account.';
        }
        if (e.message.contains('phone') ||
            e.details.toString().contains('phone')) {
          // Should be handled by "stealing" logic above, but just in case
          throw 'This phone number is already in use.';
        }
        throw 'This information is already in use by another account.';
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ensureCustomer error: $e');
      }
      rethrow; // Rethrow so UI can show the error
    }
  }

  Future<void> _updateOneSignalCustomerInfo(Customer customer) async {
    try {
      if (customer.email != null && customer.email!.isNotEmpty) {
        await OneSignalService.instance.setEmail(customer.email!);
      }

      if (customer.phone != null && customer.phone!.isNotEmpty) {
        await OneSignalService.instance.setPhoneNumber(customer.phone!);
      }

      final tags = <String, String>{};
      if (customer.firstName != null) tags['first_name'] = customer.firstName!;
      if (customer.lastName != null) tags['last_name'] = customer.lastName!;
      tags['customer_id'] = customer.id;

      if (tags.isNotEmpty) {
        await OneSignalService.instance.setTags(tags);
      }

      if (kDebugMode) {
        debugPrint('[Auth] OneSignal customer info updated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] OneSignal update error: $e');
      }
    }
  }
}
