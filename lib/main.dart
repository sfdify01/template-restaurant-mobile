import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:toastification/toastification.dart';

import 'core/config/env_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/live_activity_service.dart';
import 'core/services/onesignal_service.dart';
import 'core/services/push_token_sync_service.dart';
import 'core/theme/app_theme.dart' as theme;
import 'core/widgets/notification_handler.dart';

/// Current environment (loaded at startup)
late AppEnvironment currentEnvironment;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TerminateRestart.instance.initialize();

  // Load environment variables from .env file (debug mode only)
  // In release mode, env vars come from --dart-define=GOOGLE_MAPS_API_KEY=xxx
  if (kDebugMode) {
    try {
      // If the file is missing, don't crash and don't leave dotenv uninitialized
      // (dotenv.env would throw NotInitializedError).
      await dotenv.load(fileName: '.env', isOptional: true);
    } catch (e) {
      debugPrint('Warning: Failed to load .env. Using --dart-define values.');
    }
  }

  // Load saved environment preference (works in all build modes)
  currentEnvironment = await _loadEnvironment();

  // Initialize Supabase with selected environment
  final supabaseUrl = RuntimeEnvConfig.supabaseUrl(currentEnvironment);
  final supabaseAnonKey = RuntimeEnvConfig.supabaseAnonKey(currentEnvironment);

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Initialize Stripe with selected environment
  Stripe.publishableKey = RuntimeEnvConfig.stripePublishableKey(
    currentEnvironment,
  );
  await Stripe.instance.applySettings();

  // Initialize OneSignal first
  await OneSignalService.instance.initialize();

  // Initialize push token sync service (listens to token changes)
  PushTokenSyncService.instance.initialize();

  await LiveActivityService.instance.initialize();

  if (kDebugMode) {
    debugPrint('===========================================');
    debugPrint('Environment: ${currentEnvironment.label}');
    debugPrint('Domain: ${currentEnvironment.domain}');
    debugPrint('Supabase: $supabaseUrl');
    debugPrint('===========================================');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(ProviderScope(child: ShahirizadaApp()));
}

/// Supabase client accessor
SupabaseClient get supabase => Supabase.instance.client;

/// Load saved environment preference
Future<AppEnvironment> _loadEnvironment() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_environment');
    if (kDebugMode) {
      debugPrint('[ENV] Loaded from SharedPreferences: "$saved"');
    }
    if (saved != null) {
      final env = AppEnvironment.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppEnvironment.production,
      );
      if (kDebugMode) {
        debugPrint('[ENV] Using environment: ${env.name}');
      }
      return env;
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[ENV] Error loading: $e');
    }
  }

  // Default to production
  if (kDebugMode) {
    debugPrint('[ENV] No saved preference - defaulting to production');
  }
  return AppEnvironment.production;
}

class ShahirizadaApp extends ConsumerWidget {
  ShahirizadaApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Shahirizada Fresh Market',
        debugShowCheckedModeBanner: false,
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        theme: theme.AppTheme.light,
        darkTheme: theme.AppTheme.dark,
        themeMode: currentThemeMode,
        builder: (context, child) => NotificationHandler(
          child: GestureDetector(
            // Dismiss keyboard when tapping anywhere outside a focused field.
            behavior: HitTestBehavior.translucent,
            onTap: () {
              final focusScope = FocusScope.of(context);
              if (!focusScope.hasPrimaryFocus &&
                  focusScope.focusedChild != null) {
                focusScope.unfocus();
              }
            },
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
