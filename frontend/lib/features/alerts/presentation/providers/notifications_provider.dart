import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../shared/data/models/notification_models.dart';

final notificationsProvider = FutureProvider.autoDispose<List<NotificationResponse>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final list = await apiService.getNotifications();
    // Cache notifications list
    await HiveService.cacheData('notifications_list', list.map((n) => n.toJson()).toList());
    return list;
  } catch (e) {
    final cached = HiveService.getCachedData('notifications_list');
    if (cached != null) {
      return (cached as List)
          .map((item) => NotificationResponse.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    rethrow;
  }
});

class NotificationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  NotificationActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> markRead(int notificationId) async {
    state = const AsyncValue.loading();
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.markNotificationRead(notificationId);
      
      // Refresh list
      _ref.invalidate(notificationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAllRead() async {
    state = const AsyncValue.loading();
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.markAllNotificationsRead();
      
      // Refresh list
      _ref.invalidate(notificationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationActionsProvider = StateNotifierProvider.autoDispose<NotificationActionsNotifier, AsyncValue<void>>((ref) {
  return NotificationActionsNotifier(ref);
});
