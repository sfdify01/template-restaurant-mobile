import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  static final PermissionService instance = PermissionService._();

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // The caller should decide whether to open settings or not
      return false;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// Request location permission (When In Use)
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      return status;
    }

    if (status.isPermanentlyDenied) {
      return status;
    }

    return await Permission.locationWhenInUse.request();
  }

  /// Check current notification permission status
  Future<PermissionStatus> getNotificationStatus() async {
    return await Permission.notification.status;
  }

  /// Check current location permission status (When In Use)
  Future<PermissionStatus> getLocationStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  /// Check if location permission is granted
  Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
