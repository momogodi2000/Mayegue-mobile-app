import 'package:permission_handler/permission_handler.dart';

/// Service for handling mobile permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Request storage permission
  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  /// Request location permission
  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  /// Check microphone permission
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }

  /// Check camera permission
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// Check storage permission
  Future<PermissionStatus> checkStoragePermission() async {
    return await Permission.storage.status;
  }

  /// Check notification permission
  Future<PermissionStatus> checkNotificationPermission() async {
    return await Permission.notification.status;
  }

  /// Check location permission
  Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.location.status;
  }

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Check if permission is granted
  bool isPermissionGranted(PermissionStatus status) {
    return status.isGranted;
  }

  /// Check if permission is denied
  bool isPermissionDenied(PermissionStatus status) {
    return status.isDenied;
  }

  /// Check if permission is permanently denied
  bool isPermissionPermanentlyDenied(PermissionStatus status) {
    return status.isPermanentlyDenied;
  }
}