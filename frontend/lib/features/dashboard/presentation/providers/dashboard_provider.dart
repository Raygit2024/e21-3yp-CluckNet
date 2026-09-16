import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../shared/data/models/dashboard_models.dart';

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummaryResponse>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final summary = await apiService.getDashboardSummary();
    // Cache data for offline usage
    await HiveService.cacheData('dashboard_summary', summary.toJson());
    return summary;
  } catch (e) {
    // Attempt to load from cache
    final cached = HiveService.getCachedData('dashboard_summary');
    if (cached != null) {
      return DashboardSummaryResponse.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    rethrow;
  }
});
