import 'dart:io' show Platform, NetworkInterface;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiBaseUrlProvider = StateNotifierProvider<ApiBaseUrlNotifier, String>((ref) {
  return ApiBaseUrlNotifier();
});

class ApiBaseUrlNotifier extends StateNotifier<String> {
  ApiBaseUrlNotifier() : super(ApiConstants.baseUrl);

  Future<void> updateBaseUrl(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', newUrl);
    ApiConstants.setBaseUrl(newUrl);
    state = newUrl;
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_base_url');
    await ApiConstants.detectBaseUrl();
    state = ApiConstants.baseUrl;
  }
}

class ApiConstants {
  static String _baseUrl = 'http://localhost:8080';

  static String get baseUrl {
    const String customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    return _baseUrl;
  }

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static Future<void> detectBaseUrl() async {
    const String customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _baseUrl = savedUrl;
        return;
      }
    } catch (_) {}

    if (kIsWeb) {
      _baseUrl = 'http://localhost:8080';
      return;
    }

    try {
      if (Platform.isAndroid) {
        // Check network interfaces to detect if we are on the Android Emulator.
        // Android Emulator NAT router assigns IP addresses starting with '10.0.2.'.
        final interfaces = await NetworkInterface.list();
        bool isEmulator = false;
        for (final interface in interfaces) {
          for (final addr in interface.addresses) {
            if (addr.address.startsWith('10.0.2.')) {
              isEmulator = true;
              break;
            }
          }
          if (isEmulator) break;
        }

        if (isEmulator) {
          _baseUrl = 'http://10.0.2.2:8080';
          return;
        }
      }
    } catch (_) {}
    _baseUrl = 'http://localhost:8080';
  }

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Dashboard
  static const String dashboardSummary = '/api/dashboard/summary';

  // Zones
  static const String zones = '/api/zones';
  static String liveTelemetry(int zoneId) => '/api/zones/$zoneId/live';

  // Telemetry
  static String telemetryHistory(int zoneId) => '/api/telemetry/$zoneId';

  // Thresholds
  static String thresholds(int zoneId) => '/api/thresholds/$zoneId';
  static String schedule(int zoneId) => '/api/thresholds/$zoneId/schedule';

  // Alerts
  static const String alerts = '/api/alerts';
  static String resolveAlert(int alertId) => '/api/alerts/$alertId/resolve';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String markAllRead = '/api/notifications/mark-all-read';
  static String markNotificationRead(int id) => '/api/notifications/$id/read';
  static const String fcmToken = '/api/notifications/fcm-token';
  static const String fcmTokenUnregister = '/api/notifications/fcm-token/unregister';

  // User Profile
  static const String userMe = '/api/users/me';
  static const String users = '/api/users';
  static String userZones(String username) => '/api/users/$username/zones';

  // Devices & Assignments
  static const String devices = '/api/devices';
  static String zoneDevices(int zoneId) => '/api/zones/$zoneId/devices';
  static const String unassignedDevices = '/api/devices/unassigned';
  static String zoneDeviceById(int zoneId, String deviceId) => '/api/zones/$zoneId/devices/$deviceId';
  static String reassignDevice(String deviceId) => '/api/devices/$deviceId/reassign';
}
