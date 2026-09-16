import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../shared/data/models/alert_models.dart';

final alertsProvider = FutureProvider.autoDispose.family<List<AlertResponse>, int?>((ref, zoneId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final alerts = await apiService.getAlerts(zoneId: zoneId);
    // Cache alerts list
    await HiveService.cacheData('alerts_list_${zoneId ?? "all"}', alerts.map((a) => a.toJson()).toList());
    return alerts;
  } catch (e) {
    // Fallback to local cache
    final cached = HiveService.getCachedData('alerts_list_${zoneId ?? "all"}');
    if (cached != null) {
      return (cached as List)
          .map((item) => AlertResponse.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    rethrow;
  }
});

class AlertResolutionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AlertResolutionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> resolveAlert(int alertId, int? zoneId) async {
    state = const AsyncValue.loading();
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.resolveAlert(alertId);
      
      // Invalidate alerts query to force refresh
      _ref.invalidate(alertsProvider(zoneId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final alertResolutionProvider = StateNotifierProvider.autoDispose<AlertResolutionNotifier, AsyncValue<void>>((ref) {
  return AlertResolutionNotifier(ref);
});
