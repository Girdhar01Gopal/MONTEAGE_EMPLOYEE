class AttendanceToday {
  final bool marked;
  final String status;
  final String timestamp; // ISO string
  final double confidenceScore;
  final bool isVerified;
  final Location location;

  AttendanceToday({
    required this.marked,
    required this.status,
    required this.timestamp,
    required this.confidenceScore,
    required this.isVerified,
    required this.location,
  });

  factory AttendanceToday.fromJson(Map<String, dynamic> json) {
    return AttendanceToday(
      marked: _toBool(json['marked']),
      status: (json['status'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
      confidenceScore: _toDouble(json['confidence_score']),
      isVerified: _toBool(json['is_verified']),
      location: Location.fromJson((json['location'] ?? {}) as Map<String, dynamic>),
    );
  }

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  static bool _toBool(dynamic v) =>
      v == true || v == 1 || v == "1" || v == "true";
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
}
