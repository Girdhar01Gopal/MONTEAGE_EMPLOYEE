class AttendanceResponse {
  final bool success;
  final int count;
  final Statistics statistics;
  final FiltersApplied filtersApplied;
  final List<Result> results;

  AttendanceResponse({
    required this.success,
    required this.count,
    required this.statistics,
    required this.filtersApplied,
    required this.results,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'],
      count: json['count'],
      statistics: Statistics.fromJson(json['statistics']),
      filtersApplied: FiltersApplied.fromJson(json['filters_applied']),
      results: List<Result>.from(json['results'].map((x) => Result.fromJson(x))),
    );
  }
}

class Statistics {
  final int total;
  final int verified;
  final int pending;
  final int rejected;
  final String verificationRate;

  Statistics({
    required this.total,
    required this.verified,
    required this.pending,
    required this.rejected,
    required this.verificationRate,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      total: json['total'],
      verified: json['verified'],
      pending: json['pending'],
      rejected: json['rejected'],
      verificationRate: json['verification_rate'],
    );
  }
}

class FiltersApplied {
  final dynamic startDate;
  final dynamic endDate;
  final dynamic status;
  final dynamic limit;

  FiltersApplied({
    this.startDate,
    this.endDate,
    this.status,
    this.limit,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      limit: json['limit'],
    );
  }
}

class Result {
  final String id;
  final String employeeId;
  final String username;
  final String employeeName;
  final String department;
  final String date;
  final String time;
  final String timestamp;
  final double latitude;
  final double longitude;
  final dynamic locationAccuracy;
  final String status;
  final double confidenceScore;
  final bool faceDetected;
  final bool isVerified;
  final String imageUrl;
  final double imageQualityScore;
  final int faceLandmarksDetected;
  final bool isSuspicious;
  final dynamic suspiciousReason;
  final Map<String, dynamic> deviceInfo;

  Result({
    required this.id,
    required this.employeeId,
    required this.username,
    required this.employeeName,
    required this.department,
    required this.date,
    required this.time,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.locationAccuracy,
    required this.status,
    required this.confidenceScore,
    required this.faceDetected,
    required this.isVerified,
    required this.imageUrl,
    required this.imageQualityScore,
    required this.faceLandmarksDetected,
    required this.isSuspicious,
    this.suspiciousReason,
    required this.deviceInfo,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      employeeId: json['employee_id'],
      username: json['username'],
      employeeName: json['employee_name'],
      department: json['department'] ?? "Not Available",
      date: json['date'],
      time: json['time'],
      timestamp: json['timestamp'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      locationAccuracy: json['location_accuracy'],
      status: json['status'],
      confidenceScore: json['confidence_score'].toDouble(),
      faceDetected: json['face_detected'],
      isVerified: json['is_verified'],
      imageUrl: json['image_url'],
      imageQualityScore: json['image_quality_score'].toDouble(),
      faceLandmarksDetected: json['face_landmarks_detected'],
      isSuspicious: json['is_suspicious'],
      suspiciousReason: json['suspicious_reason'],
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
    );
  }
}
