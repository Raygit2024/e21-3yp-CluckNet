class AlertResponse {
  final int id;
  final int? zoneId;
  final String? zoneName;
  final String severity; // INFO, WARNING, CRITICAL
  final String message;
  final String status; // ACTIVE, RESOLVED
  final String createdAt;
  final String? resolvedAt;
  final String? type;
  final double? triggeredValue;
  final double? thresholdValue;

  AlertResponse({
    required this.id,
    this.zoneId,
    this.zoneName,
    required this.severity,
    required this.message,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.type,
    this.triggeredValue,
    this.thresholdValue,
  });

  factory AlertResponse.fromJson(Map<String, dynamic> json) {
    return AlertResponse(
      id: json['id'] as int? ?? 0,
      zoneId: json['zoneId'] as int?,
      zoneName: json['zoneName'] as String?,
      severity: json['severity'] as String? ?? 'INFO',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String? ?? '',
      resolvedAt: json['resolvedAt'] as String?,
      type: json['type'] as String?,
      triggeredValue: (json['triggeredValue'] as num?)?.toDouble(),
      thresholdValue: (json['thresholdValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'severity': severity,
      'message': message,
      'status': status,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
      'type': type,
      'triggeredValue': triggeredValue,
      'thresholdValue': thresholdValue,
    };
  }
}
