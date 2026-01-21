import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
///
/// SECURITY NOTES (matching web monorepo patterns):
/// - Supabase anon keys are PUBLIC (safe in client code, protected by RLS)
/// - Stripe PUBLISHABLE keys are PUBLIC (safe in client code, for payment intents only)
/// - Stripe SECRET keys are SERVER-ONLY (never in client code)
/// - Uber Direct credentials are SERVER-ONLY (never in client code)
/// - All sensitive operations go through Edge Functions (market-server)
///
/// Uses kDebugMode to automatically switch between test and production:
/// - Debug mode (kDebugMode = true) → Test Supabase branch + Test Stripe
/// - Release mode (kDebugMode = false) → Production Supabase + Live Stripe
class EnvConfig {
  EnvConfig._();

  /// Whether the app is running in production mode
  /// In debug mode, uses test environment; in release mode, uses production
  static bool get isProduction => !kDebugMode;

  /// Current environment name for logging/debugging
  static String get environmentName => isProduction ? 'production' : 'test';

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

  /// Supabase URL - automatically switches based on build mode
  static String get supabaseUrl =>
      isProduction ? _prodSupabaseUrl : _testSupabaseUrl;

  /// Supabase Anonymous Key - automatically switches based on build mode
  /// NOTE: Anon keys are PUBLIC and safe to include in client code.
  /// They are protected by Row Level Security (RLS) policies.
  static String get supabaseAnonKey =>
      isProduction ? _prodSupabaseAnonKey : _testSupabaseAnonKey;

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

  /// Stripe Publishable Key - automatically switches based on build mode
  /// NOTE: Publishable keys are PUBLIC and safe to include in client code.
  /// They can only be used to create payment intents, not charge cards directly.
  static String get stripePublishableKey =>
      isProduction ? _prodStripePublishableKey : _testStripePublishableKey;

  /// Stripe Connect Account ID - for destination charges
  static String get stripeConnectAccountId =>
      isProduction ? _prodStripeConnectAccountId : _testStripeConnectAccountId;

  // ==========================================================================
  // UBER DIRECT - SERVER-SIDE ONLY
  // ==========================================================================
  // NOTE: Uber Direct credentials are SECRET and handled server-side only.
  // The mobile app calls Edge Functions which make Uber API calls.
  // All delivery quotes and orders go through: POST /market-server/delivery/quote
  // The client NEVER directly calls Uber APIs.

  // ==========================================================================
  // TENANT CONFIGURATION
  // ==========================================================================

  /// Shahirizada Fresh Market tenant UUID
  static const String tenantId = '807a5c76-c690-4f78-b721-0cf9ba763f5d';

  // ==========================================================================
  // API CONFIGURATION
  // ==========================================================================

  /// Environment header to send with API requests (matches web monorepo pattern)
  /// This tells the Edge Functions which Stripe/Uber keys to use
  static String get tabsyEnvHeader => isProduction ? 'prod' : 'test';

  /// Base URL for Edge Functions
  static String get edgeFunctionsUrl => '$supabaseUrl/functions/v1';

  /// Market Server API base URL
  static String get marketServerUrl => '$edgeFunctionsUrl/market-server';

  // ==========================================================================
  // GOOGLE MAPS CONFIGURATION
  // ==========================================================================

  /// Google Maps API Key for Places Autocomplete
  /// - Debug mode: loaded from .env file (for local development), fallback to --dart-define
  /// - Release mode: loaded from `--dart-define=GOOGLE_MAPS_API_KEY=yourkey` (for CI/CD builds)
  /// Enabled for Places API, Geocoding API, Maps SDK
  static String get googleMapsApiKey {
    // Always check --dart-define first (works in both debug and release)
    const dartDefineKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (dartDefineKey.isNotEmpty) {
      return dartDefineKey;
    }

    // Fallback to .env file in debug mode only
    if (kDebugMode) {
      if (!dotenv.isInitialized) {
        return '';
      }
      return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    }

    return '';
  }

  // ==========================================================================
  // FEATURE FLAGS
  // ==========================================================================

  /// Enable verbose logging in debug mode only
  static bool get enableLogging => kDebugMode;

  /// Enable analytics in production only
  static bool get enableAnalytics => isProduction;
}
