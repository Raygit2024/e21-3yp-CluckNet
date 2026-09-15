class DashboardSummaryResponse {
  final int totalZones;
  final int totalDevices;
  final int onlineDevices;
  final int offlineDevices;
  final int activeAlerts;
  final int criticalAlerts;

  DashboardSummaryResponse({
    required this.totalZones,
    required this.totalDevices,
    required this.onlineDevices,
    required this.offlineDevices,
    required this.activeAlerts,
    required this.criticalAlerts,
  });

  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryResponse(
      totalZones: json['totalZones'] as int? ?? 0,
      totalDevices: json['totalDevices'] as int? ?? 0,
      onlineDevices: json['onlineDevices'] as int? ?? 0,
      offlineDevices: json['offlineDevices'] as int? ?? 0,
      activeAlerts: json['activeAlerts'] as int? ?? 0,
      criticalAlerts: json['criticalAlerts'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalZones': totalZones,
      'totalDevices': totalDevices,
      'onlineDevices': onlineDevices,
      'offlineDevices': offlineDevices,
      'activeAlerts': activeAlerts,
      'criticalAlerts': criticalAlerts,
    };
  }
}
