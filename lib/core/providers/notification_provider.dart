import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/permission_service.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
class NotificationPermission extends _$NotificationPermission {
  @override
  PermissionStatus build() {
    _checkStatus();
    return PermissionStatus.denied;
  }

  Future<void> _checkStatus() async {
    final status = await PermissionService.instance.getNotificationStatus();
    state = status;
  }

  Future<void> requestPermission() async {
    await PermissionService.instance
        .requestNotificationPermission();
    // Refresh status
    state = await PermissionService.instance.getNotificationStatus();
  }

  Future<bool> openSettings() async {
    return await PermissionService.instance.openSettings();
  }
}
