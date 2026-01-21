import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../main.dart';

/// Simple service that syncs push tokens to Supabase.
///
/// Triggers:
/// 1. Token changes (from OneSignal) → try sync
/// 2. User changes (from auth) → try sync
/// 3. Permission changes → try sync
/// 4. App resumes from background → try sync
///
/// All call the same idempotent upsert. Simple.
class PushTokenSyncService with WidgetsBindingObserver {
  PushTokenSyncService._();
  static final PushTokenSyncService instance = PushTokenSyncService._();

  bool _initialized = false;
  String? _userId;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Listen to push token changes
    OneSignal.User.pushSubscription.addObserver(_onTokenChanged);

    // Listen to permission changes
    OneSignal.Notifications.addPermissionObserver(_onPermissionChanged);

    // Listen to app lifecycle
    WidgetsBinding.instance.addObserver(this);

    if (kDebugMode) {
      debugPrint('[PushTokenSync] ✅ Initialized');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] 📱 App resumed');
      }
      unawaited(forceSync());
    }
  }

  /// Called when notification permission changes
  void _onPermissionChanged(bool granted) {
    if (kDebugMode) {
      debugPrint('[PushTokenSync] 🔐 Permission changed: $granted');
    }
    unawaited(forceSync());
  }

  /// Called when push token changes
  void _onTokenChanged(OSPushSubscriptionChangedState state) {
    final token = state.current.token;
    final subscriptionId = state.current.id;

    if (kDebugMode) {
      debugPrint('[PushTokenSync] 🔔 Token changed: ${token != null && token.isNotEmpty ? "${token.substring(0, 20)}..." : "empty/null"}');
    }

    // Try to sync (fire and forget)
    unawaited(_syncToSupabase(subscriptionId, token));
  }

  /// Called when user logs in/out
  Future<void> setUserId(String? userId) async {
    _userId = userId;

    if (kDebugMode) {
      debugPrint('[PushTokenSync] 👤 User changed: $userId');
    }

    if (userId != null) {
      // User logged in - get current token and sync
      final token = OneSignal.User.pushSubscription.token;
      final subscriptionId = OneSignal.User.pushSubscription.id;
      await _syncToSupabase(subscriptionId, token);
    }
  }

  /// Called on logout
  void clearUser() {
    _userId = null;
    if (kDebugMode) {
      debugPrint('[PushTokenSync] 👤 User cleared');
    }
  }

  /// Force sync (e.g., on app resume)
  Future<void> forceSync() async {
    final token = OneSignal.User.pushSubscription.token;
    final subscriptionId = OneSignal.User.pushSubscription.id;

    if (kDebugMode) {
      debugPrint('[PushTokenSync] 🔄 Force sync requested');
    }

    await _syncToSupabase(subscriptionId, token);
  }

  /// The actual sync - idempotent upsert to Supabase
  Future<void> _syncToSupabase(String? subscriptionId, String? token) async {
    // Need all three: userId, subscriptionId, and non-empty token
    final userId = _userId;

    if (kDebugMode) {
      debugPrint('[PushTokenSync] _syncToSupabase called:');
      debugPrint('[PushTokenSync]   userId: $userId');
      debugPrint('[PushTokenSync]   subscriptionId: $subscriptionId');
      debugPrint('[PushTokenSync]   token: ${token != null && token.isNotEmpty ? "${token.substring(0, 20)}..." : "null/empty"}');
    }

    if (userId == null) {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] ⏳ No user ID, skipping sync');
      }
      return;
    }

    if (subscriptionId == null) {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] ⏳ No subscription ID, skipping sync');
      }
      return;
    }

    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] ⏳ No valid token, skipping sync');
      }
      return;
    }

    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

    try {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] 📤 Syncing to Supabase...');
        debugPrint('[PushTokenSync]   user_id: $userId');
        debugPrint('[PushTokenSync]   subscription_id: $subscriptionId');
        debugPrint('[PushTokenSync]   platform: $platform');
      }

      await supabase.from('push_tokens').upsert({
        'user_id': userId,
        'subscription_id': subscriptionId,
        'push_token': token,
        'platform': platform,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, subscription_id');

      if (kDebugMode) {
        debugPrint('[PushTokenSync] ✅ Sync successful!');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[PushTokenSync] ❌ Sync failed: $e');
        debugPrint('[PushTokenSync] Stack: $stack');
      }
    }
  }
}
