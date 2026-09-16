import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/hive_service.dart';

class FarmerModel {
  final String username;
  final String email;
  final List<int> assignedZones;

  FarmerModel({
    required this.username,
    required this.email,
    required this.assignedZones,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      assignedZones: List<int>.from(json['assignedZones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'assignedZones': assignedZones,
    };
  }

  FarmerModel copyWith({List<int>? assignedZones}) {
    return FarmerModel(
      username: username,
      email: email,
      assignedZones: assignedZones ?? this.assignedZones,
    );
  }
}

class FarmersNotifier extends StateNotifier<List<FarmerModel>> {
  final Ref _ref;
  static const String rosterKey = 'farmer_roster';

  FarmersNotifier(this._ref) : super([]) {
    _loadRoster();
  }

  void _loadRoster() {
    final cached = HiveService.getCachedData(rosterKey);
    if (cached != null) {
      state = (cached as List)
          .map((item) => FarmerModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      // Seed default demo farmer if empty
      state = [
        FarmerModel(username: 'farmer', email: 'farmer@clucknet.com', assignedZones: [])
      ];
      _saveRoster();
    }
  }

  Future<void> _saveRoster() async {
    await HiveService.cacheData(rosterKey, state.map((f) => f.toJson()).toList());
  }

  Future<void> addFarmer({
    required String username,
    required String password,
    required String email,
  }) async {
    final apiService = _ref.read(apiServiceProvider);
    
    // Register farmer on backend
    await apiService.registerFarmer(
      username: username,
      password: password,
      email: email,
    );

    // If backend registration succeeds, save to local roster
    final newFarmer = FarmerModel(
      username: username,
      email: email,
      assignedZones: [],
    );

    state = [...state, newFarmer];
    await _saveRoster();
  }

  Future<void> deleteFarmer(String username) async {
    final apiService = _ref.read(apiServiceProvider);
    await apiService.deleteFarmer(username);

    state = state.where((f) => f.username != username).toList();
    await _saveRoster();

    // Clean up local assignments keys
    await HiveService.cacheData('farmer_assignments_$username', null);
    await HiveService.cacheData('has_configured_assignments_$username', null);
  }

  Future<void> assignZones(String username, List<int> zoneIds) async {
    final apiService = _ref.read(apiServiceProvider);
    await apiService.assignZonesToFarmer(username, zoneIds);

    state = state.map((f) {
      if (f.username == username) {
        return f.copyWith(assignedZones: zoneIds);
      }
      return f;
    }).toList();

    await _saveRoster();

    // Cache assignments for farmer's query filtering
    await HiveService.cacheData('farmer_assignments_$username', zoneIds);
    await HiveService.cacheData('has_configured_assignments_$username', true);
  }
}

final farmersProvider = StateNotifierProvider<FarmersNotifier, List<FarmerModel>>((ref) {
  return FarmersNotifier(ref);
});
