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
  final String? startDate;
  final String? endDate;
  final String? status;
  final int? limit;

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
  final String date;
  final String time;
  final String timestamp;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final String status;
  final double confidenceScore;
  final bool faceDetected;
  final bool isVerified;
  final String imageUrl;
  final double imageQualityScore;
  final int faceLandmarksDetected;
  final String? checkoutDate;
  final String? checkoutTime;
  final String? checkoutTimestamp;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final double? checkoutLocationAccuracy;
  final String? checkoutImageUrl;
  final double? checkoutConfidenceScore;
  final String? checkoutStatus;
  final Duration? duration;
  final bool isSuspicious;
  final String? suspiciousReason;
  final Map<String, dynamic> deviceInfo;
  final String createdAt;
  final String updatedAt;

  Result({
    required this.id,
    required this.employeeId,
    required this.username,
    required this.employeeName,
    required this.date,
    required this.time,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    required this.status,
    required this.confidenceScore,
    required this.faceDetected,
    required this.isVerified,
    required this.imageUrl,
    required this.imageQualityScore,
    required this.faceLandmarksDetected,
    this.checkoutDate,
    this.checkoutTime,
    this.checkoutTimestamp,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkoutLocationAccuracy,
    this.checkoutImageUrl,
    this.checkoutConfidenceScore,
    this.checkoutStatus,
    this.duration,
    required this.isSuspicious,
    this.suspiciousReason,
    required this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      employeeId: json['employee_id'],
      username: json['username'],
      employeeName: json['employee_name'],
      date: json['date'],
      time: json['time'],
      timestamp: json['timestamp'],
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
      locationAccuracy: json['location_accuracy'] != null ? json['location_accuracy'].toDouble() : null,
      status: json['status'],
      confidenceScore: json['confidence_score'] != null ? json['confidence_score'].toDouble() : 0.0,
      faceDetected: json['face_detected'],
      isVerified: json['is_verified'],
      imageUrl: json['image_url'] ?? '',
      imageQualityScore: json['image_quality_score'] != null ? json['image_quality_score'].toDouble() : 0.0,
      faceLandmarksDetected: json['face_landmarks_detected'],
      checkoutDate: json['checkout_date'],
      checkoutTime: json['checkout_time'],
      checkoutTimestamp: json['checkout_timestamp'],
      checkoutLatitude: json['checkout_latitude'] != null ? json['checkout_latitude'].toDouble() : null,
      checkoutLongitude: json['checkout_longitude'] != null ? json['checkout_longitude'].toDouble() : null,
      checkoutLocationAccuracy: json['checkout_location_accuracy'] != null ? json['checkout_location_accuracy'].toDouble() : null,
      checkoutImageUrl: json['checkout_image_url'],
      checkoutConfidenceScore: json['checkout_confidence_score'] != null ? json['checkout_confidence_score'].toDouble() : null,
      checkoutStatus: json['checkout_status'],
      duration: json['duration'] != null ? Duration(seconds: json['duration']['seconds']) : null,
      isSuspicious: json['is_suspicious'],
      suspiciousReason: json['suspicious_reason'],
      deviceInfo: json['device_info'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
