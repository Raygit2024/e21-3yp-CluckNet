import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../shared/data/models/device_models.dart';

class DevicesNotifier extends StateNotifier<List<DeviceResponse>> {
  final Ref _ref;

  DevicesNotifier(this._ref) : super([]) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final devices = await apiService.getAllDevices();
      state = devices;
    } catch (_) {
      // Silently catch or preserve current state
    }
  }

  Future<void> addDevice({
    required String id,
    required String name,
    int? zoneId,
  }) async {
    final apiService = _ref.read(apiServiceProvider);
    final newDevice = await apiService.registerDevice(
      id: id,
      name: name,
      zoneId: zoneId,
    );
    state = [...state, newDevice];
  }

  Future<void> editDevice({
    required String id,
    required String name,
  }) async {
    final apiService = _ref.read(apiServiceProvider);
    final updatedDevice = await apiService.updateDevice(
      id: id,
      name: name,
    );
    state = state.map((d) => d.id == id ? updatedDevice : d).toList();
  }

  Future<void> deleteDevice(String id) async {
    final apiService = _ref.read(apiServiceProvider);
    await apiService.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
  }
}

final devicesProvider = StateNotifierProvider<DevicesNotifier, List<DeviceResponse>>((ref) {
  return DevicesNotifier(ref);
});
