class ThresholdResponse {
  final int id;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final double maxNh3;
  final double maxLpg;
  final int zoneId;
  final String? updatedAt;
  final bool autoThresholdEnabled;
  final String? placementDate;
  final bool manualOverrideEnabled;
  final int? chickAge;
  final double? activeMinTemperature;
  final double? activeMaxTemperature;
  final double? activeMinHumidity;
  final double? activeMaxHumidity;

  ThresholdResponse({
    required this.id,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    required this.maxNh3,
    required this.maxLpg,
    required this.zoneId,
    this.updatedAt,
    required this.autoThresholdEnabled,
    this.placementDate,
    required this.manualOverrideEnabled,
    this.chickAge,
    this.activeMinTemperature,
    this.activeMaxTemperature,
    this.activeMinHumidity,
    this.activeMaxHumidity,
  });

  factory ThresholdResponse.fromJson(Map<String, dynamic> json) {
    return ThresholdResponse(
      id: json['id'] as int? ?? 0,
      minTemperature: (json['minTemperature'] as num? ?? 0.0).toDouble(),
      maxTemperature: (json['maxTemperature'] as num? ?? 0.0).toDouble(),
      minHumidity: (json['minHumidity'] as num? ?? 0.0).toDouble(),
      maxHumidity: (json['maxHumidity'] as num? ?? 0.0).toDouble(),
      maxNh3: (json['maxNh3'] as num? ?? 0.0).toDouble(),
      maxLpg: (json['maxLpg'] as num? ?? 0.0).toDouble(),
      zoneId: json['zoneId'] as int? ?? 0,
      updatedAt: json['updatedAt'] as String?,
      autoThresholdEnabled: json['autoThresholdEnabled'] as bool? ?? false,
      placementDate: json['placementDate'] as String?,
      manualOverrideEnabled: json['manualOverrideEnabled'] as bool? ?? false,
      chickAge: json['chickAge'] as int?,
      activeMinTemperature: (json['activeMinTemperature'] as num?)?.toDouble(),
      activeMaxTemperature: (json['activeMaxTemperature'] as num?)?.toDouble(),
      activeMinHumidity: (json['activeMinHumidity'] as num?)?.toDouble(),
      activeMaxHumidity: (json['activeMaxHumidity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'maxNh3': maxNh3,
      'maxLpg': maxLpg,
      'zoneId': zoneId,
      'updatedAt': updatedAt,
      'autoThresholdEnabled': autoThresholdEnabled,
      'placementDate': placementDate,
      'manualOverrideEnabled': manualOverrideEnabled,
      'chickAge': chickAge,
      'activeMinTemperature': activeMinTemperature,
      'activeMaxTemperature': activeMaxTemperature,
      'activeMinHumidity': activeMinHumidity,
      'activeMaxHumidity': activeMaxHumidity,
    };
  }
}

class GrowthScheduleStageResponse {
  final int? id;
  final int startDay;
  final int endDay;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;

  GrowthScheduleStageResponse({
    this.id,
    required this.startDay,
    required this.endDay,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
  });

  factory GrowthScheduleStageResponse.fromJson(Map<String, dynamic> json) {
    return GrowthScheduleStageResponse(
      id: json['id'] as int?,
      startDay: json['startDay'] as int? ?? 0,
      endDay: json['endDay'] as int? ?? 0,
      minTemperature: (json['minTemperature'] as num? ?? 0.0).toDouble(),
      maxTemperature: (json['maxTemperature'] as num? ?? 0.0).toDouble(),
      minHumidity: (json['minHumidity'] as num? ?? 0.0).toDouble(),
      maxHumidity: (json['maxHumidity'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDay': startDay,
      'endDay': endDay,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
    };
  }
}

class ZoneResponse {
  final int id;
  final String name;
  final String? deviceId;
  final String? deviceName;
  final String? deviceStatus;
  final ThresholdResponse? threshold;
  final String createdAt;

  ZoneResponse({
    required this.id,
    required this.name,
    this.deviceId,
    this.deviceName,
    this.deviceStatus,
    this.threshold,
    required this.createdAt,
  });

  factory ZoneResponse.fromJson(Map<String, dynamic> json) {
    return ZoneResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceStatus: json['deviceStatus'] as String?,
      threshold: json['threshold'] != null
          ? ThresholdResponse.fromJson(json['threshold'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceStatus': deviceStatus,
      'threshold': threshold?.toJson(),
      'createdAt': createdAt,
    };
  }
}
