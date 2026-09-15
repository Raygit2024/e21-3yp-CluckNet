class JwtAuthResponse {
  final String accessToken;
  final String tokenType;
  final String username;
  final String role;

  JwtAuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.username,
    required this.role,
  });

  factory JwtAuthResponse.fromJson(Map<String, dynamic> json) {
    return JwtAuthResponse(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'FARMER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'username': username,
      'role': role,
    };
  }
}

class UserProfileResponse {
  final int id;
  final String username;
  final String email;
  final String role;
  final List<int> assignedZones;

  UserProfileResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.assignedZones,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'FARMER',
      assignedZones: List<int>.from(json['assignedZones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'assignedZones': assignedZones,
    };
  }
}
