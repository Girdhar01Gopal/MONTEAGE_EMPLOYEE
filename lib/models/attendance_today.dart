class AttendanceToday {
  final bool marked;
  final String status;
  final String timestamp; // ISO string
  final double confidenceScore;
  final bool isVerified;
  final String employeeId;
  final String imageUrl;
  final Location location;
  final FaceAnalysis faceAnalysis;

  AttendanceToday({
    required this.marked,
    required this.status,
    required this.timestamp,
    required this.confidenceScore,
    required this.isVerified,
    required this.employeeId,
    required this.imageUrl,
    required this.location,
    required this.faceAnalysis,
  });

  factory AttendanceToday.fromJson(Map<String, dynamic> json) {
    return AttendanceToday(
      marked: _toBool(json['marked']),
      status: (json['status'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
      confidenceScore: _toDouble(json['confidence_score']),
      isVerified: _toBool(json['is_verified']),
      employeeId: (json['employee_id'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      location:
      Location.fromJson((json['location'] ?? {}) as Map<String, dynamic>),
      faceAnalysis: FaceAnalysis.fromJson(
          (json['face_analysis'] ?? {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "marked": marked,
      "status": status,
      "timestamp": timestamp,
      "confidence_score": confidenceScore,
      "is_verified": isVerified,
      "employee_id": employeeId,
      "image_url": imageUrl,
      "location": location.toJson(),
      "face_analysis": faceAnalysis.toJson(),
    };
  }

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  static bool _toBool(dynamic v) =>
      v == true || v == 1 || v == "1" || v == "true";
}

class Location {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String address;

  Location({
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
      accuracy: _toNullableDouble(json['accuracy']),
      address: (json['address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracy": accuracy,
      "address": address,
    };
  }

  static double? _toNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class FaceAnalysis {
  final double qualityScore;
  final int landmarksDetected;

  FaceAnalysis({
    required this.qualityScore,
    required this.landmarksDetected,
  });

  factory FaceAnalysis.fromJson(Map<String, dynamic> json) {
    return FaceAnalysis(
      qualityScore: _toDouble(json['quality_score']),
      landmarksDetected: (json['landmarks_detected'] ?? 0) is int
          ? (json['landmarks_detected'] ?? 0)
          : int.tryParse(json['landmarks_detected'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quality_score": qualityScore,
      "landmarks_detected": landmarksDetected,
    };
  }

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
}
