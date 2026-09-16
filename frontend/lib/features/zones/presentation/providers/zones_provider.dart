import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../shared/data/models/zone_models.dart';
import '../../../shared/data/models/telemetry_models.dart';
import '../../../shared/data/models/device_models.dart';

// Fetch the list of zones with local role-based filtering
final zonesProvider = FutureProvider.autoDispose<List<ZoneResponse>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  List<ZoneResponse> allZones = [];
  try {
    allZones = await apiService.getZones();
    // Cache zones list
    await HiveService.cacheData('zones_list', allZones.map((z) => z.toJson()).toList());
  } catch (e) {
    // Fallback to cache if request fails
    final cached = HiveService.getCachedData('zones_list');
    if (cached != null) {
      allZones = (cached as List)
          .map((item) => ZoneResponse.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      rethrow;
    }
  }

  return allZones;
});

// Fetch a single zone details
final zoneDetailProvider = FutureProvider.autoDispose.family<ZoneResponse, int>((ref, zoneId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final zone = await apiService.getZoneById(zoneId);
    await HiveService.cacheData('zone_detail_$zoneId', zone.toJson());
    return zone;
  } catch (e) {
    final cached = HiveService.getCachedData('zone_detail_$zoneId');
    if (cached != null) {
      return ZoneResponse.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    rethrow;
  }
});

// Periodic live telemetry stream
final liveTelemetryProvider = StreamProvider.autoDispose.family<LiveTelemetryResponse, int>((ref, zoneId) async* {
  final apiService = ref.watch(apiServiceProvider);

  // Attempt initial load from api or cache
  try {
    final initialData = await apiService.getLiveTelemetry(zoneId);
    await HiveService.cacheData('live_telemetry_$zoneId', initialData.toJson());
    yield initialData;
  } catch (_) {
    final cached = HiveService.getCachedData('live_telemetry_$zoneId');
    if (cached != null) {
      yield LiveTelemetryResponse.fromJson(Map<String, dynamic>.from(cached as Map));
    }
  }

  // Poll for updates every 5 seconds
  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    try {
      final liveData = await apiService.getLiveTelemetry(zoneId);
      await HiveService.cacheData('live_telemetry_$zoneId', liveData.toJson());
      yield liveData;
    } catch (e) {
      // Print or log errors silently, continue yielding cached or keep previous stream state
    }
  }
});

// Fetch history for telemetry graphs (last 24 hours or last 7 days)
class TelemetryHistoryParam {
  final int zoneId;
  final String range;

  TelemetryHistoryParam(this.zoneId, this.range);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetryHistoryParam &&
          runtimeType == other.runtimeType &&
          zoneId == other.zoneId &&
          range == other.range;

  @override
  int get hashCode => zoneId.hashCode ^ range.hashCode;
}

final telemetryHistoryProvider = FutureProvider.autoDispose.family<List<TelemetryResponse>, TelemetryHistoryParam>((ref, param) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final history = await apiService.getTelemetryHistory(param.zoneId, param.range);
    await HiveService.cacheData('telemetry_history_${param.zoneId}_${param.range}', history.map((t) => t.toJson()).toList());
    return history;
  } catch (e) {
    final cached = HiveService.getCachedData('telemetry_history_${param.zoneId}_${param.range}');
    if (cached != null) {
      return (cached as List)
          .map((item) => TelemetryResponse.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    rethrow;
  }
});

final thresholdProvider = FutureProvider.autoDispose.family<ThresholdResponse, int>((ref, zoneId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final threshold = await apiService.getThresholdByZoneId(zoneId);
    await HiveService.cacheData('threshold_$zoneId', threshold.toJson());
    return threshold;
  } catch (e) {
    final cached = HiveService.getCachedData('threshold_$zoneId');
    if (cached != null) {
      return ThresholdResponse.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    rethrow;
  }
});

// Fetch unassigned devices
final unassignedDevicesProvider = FutureProvider.autoDispose<List<DeviceResponse>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUnassignedDevices();
});

// Fetch devices assigned to a zone
final zoneDevicesProvider = FutureProvider.autoDispose.family<List<DeviceResponse>, int>((ref, zoneId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDevicesByZoneId(zoneId);
});

// Fetch growth schedule stages for a zone
final scheduleProvider = FutureProvider.autoDispose.family<List<GrowthScheduleStageResponse>, int>((ref, zoneId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getScheduleStages(zoneId);
});

