import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'env_provider.g.dart';

/// Available environments
enum AppEnvironment {
  test('Test', 'test.shahirizadameatmarket.com'),
  production('Production', 'shahirizadameatmarket.com');

  final String label;
  final String domain;

  const AppEnvironment(this.label, this.domain);
}

/// Environment configuration that can be switched at runtime (all build modes)
/// Matches web pattern: test.shahirizadameatmarket.com vs shahirizadameatmarket.com
@Riverpod(keepAlive: true)
class Environment extends _$Environment {
  static const _storageKey = 'app_environment';
  static const _pushTokenSyncKey = 'push_token_sync_pending';

  bool _isExplicitlySet = false;
  bool get isExplicitlySet => _isExplicitlySet;

  @override
  AppEnvironment build() {
    // Load saved preference (async, will update state when ready)
    _loadSavedEnvironment();

    // Default to production (main branch) - use dev mode 8-tap trick to switch to test
    return AppEnvironment.production;
  }

  Future<void> _loadSavedEnvironment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final env = AppEnvironment.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppEnvironment.production,
        );
        state = env;
        _isExplicitlySet = true;
      }
    } catch (_) {
      // Ignore errors, use default
    }
  }

  /// Switch environment (works in all build modes)
  Future<bool> setEnvironment(AppEnvironment env) async {
    final previousEnv = state;
    state = env;
    _isExplicitlySet = true;

    // Persist preference
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_storageKey, env.name);
      if (previousEnv != env) {
        await prefs.setBool(_pushTokenSyncKey, true);
      }

      // Verify the save worked by reading back
      final saved = prefs.getString(_storageKey);
      final verified = saved == env.name;

      if (kDebugMode) {
        debugPrint(
          '[ENV] Saved environment: $saved (requested: ${env.name}, success: $success, verified: $verified)',
        );
      }

      return verified;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ENV] Error saving environment: $e');
      }
      return false;
    }
  }

  /// Toggle between test and production
  Future<void> toggle() async {
    final newEnv = state == AppEnvironment.test
        ? AppEnvironment.production
        : AppEnvironment.test;
    await setEnvironment(newEnv);
  }
}

/// Runtime environment configuration
/// This extends EnvConfig with runtime-switchable values
class RuntimeEnvConfig {
  RuntimeEnvConfig._();

  // ==========================================================================
  // SUPABASE CONFIGURATION
  // ==========================================================================

  // Production Supabase (main branch)
  static const String _prodSupabaseUrl =
      'https://cdfllxxtgguyveowmdis.supabase.co';
  static const String _prodSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkZmxseHh0Z2d1eXZlb3dtZGlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzODAzODksImV4cCI6MjA3Njk1NjM4OX0.B_Ea9AstbuhhQkI5c3mLIR1Puu386m5BykfOfb1hHhc';

  // Test Supabase (test branch)
  static const String _testSupabaseUrl =
      'https://pbzpqsdjaiynrpjpubai.supabase.co';
  static const String _testSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBienBxc2RqYWl5bnJwanB1YmFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MDY3MTcsImV4cCI6MjA3OTM4MjcxN30.-ZXPGMQp_PwTLaUa93l_qIYUpGbQlvN6Ti1mcBuKs4s';

  /// Get Supabase URL for environment
  static String supabaseUrl(AppEnvironment env) {
    return env == AppEnvironment.production
        ? _prodSupabaseUrl
        : _testSupabaseUrl;
  }

  /// Get Supabase anon key for environment
  static String supabaseAnonKey(AppEnvironment env) {
    return env == AppEnvironment.production
        ? _prodSupabaseAnonKey
        : _testSupabaseAnonKey;
  }

  // ==========================================================================
  // STRIPE CONFIGURATION (PUBLIC KEYS ONLY)
  // ==========================================================================
  // NOTE: Only PUBLISHABLE keys go in client code.
  // Secret keys are handled server-side in Edge Functions.

  // Production Stripe publishable key (pk_live_*)
  static const String _prodStripePublishableKey =
      'pk_live_51SRyW32SElPthEc0kVPp4Xf2PwgSdR8orXCkTUBgN10JiF0sWgAZVLfuhgPpFH6tP911IEk0DMbQkpokChtI418i004wCsl7Y9';

  // Test Stripe publishable key (pk_test_*)
  static const String _testStripePublishableKey =
      'pk_test_51SRzM4CkkCHpKqhbKKugUXY4Sknr0mgydwzKFZk7WDVH0gzMsLpg1VME5OBtSBoxssqiAzmoViv8R1pVtG9vNUcj00OP7e9WX5';

  // Stripe Connect Account IDs (destination for payments)
  static const String _prodStripeConnectAccountId = 'acct_1SSHUzEEwSkaHNOL';
  static const String _testStripeConnectAccountId = 'acct_1SSF91CkkC486fCc';

  /// Get Stripe publishable key for environment
  static String stripePublishableKey(AppEnvironment env) {
    return env == AppEnvironment.production
        ? _prodStripePublishableKey
        : _testStripePublishableKey;
  }

  /// Get Stripe Connect Account ID for environment
  static String stripeConnectAccountId(AppEnvironment env) {
    return env == AppEnvironment.production
        ? _prodStripeConnectAccountId
        : _testStripeConnectAccountId;
  }

  // ==========================================================================
  // API CONFIGURATION
  // ==========================================================================

  /// Environment header to send with API requests
  static String tabsyEnvHeader(AppEnvironment env) {
    return env == AppEnvironment.production ? 'prod' : 'test';
  }

  /// Base URL for Edge Functions
  static String edgeFunctionsUrl(AppEnvironment env) {
    return '${supabaseUrl(env)}/functions/v1';
  }

  /// Market Server API base URL
  static String marketServerUrl(AppEnvironment env) {
    return '${edgeFunctionsUrl(env)}/market-server';
  }
}
