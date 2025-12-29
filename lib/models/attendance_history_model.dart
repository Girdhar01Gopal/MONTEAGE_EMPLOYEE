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
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      statistics: Statistics.fromJson(json['statistics'] ?? {}),
      filtersApplied: FiltersApplied.fromJson(json['filters_applied'] ?? {}),
      results: json['results'] == null
          ? <Result>[]
          : List<Result>.from(
        json['results'].map((x) => Result.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "count": count,
      "statistics": statistics.toJson(),
      "filters_applied": filtersApplied.toJson(),
      "results": results.map((x) => x.toJson()).toList(),
    };
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
      total: json['total'] ?? 0,
      verified: json['verified'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
      verificationRate: json['verification_rate'] ?? "0%",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "verified": verified,
      "pending": pending,
      "rejected": rejected,
      "verification_rate": verificationRate,
    };
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

  Map<String, dynamic> toJson() {
    return {
      "start_date": startDate,
      "end_date": endDate,
      "status": status,
      "limit": limit,
    };
  }
}

class DurationInfo {
  final double totalHours;
  final int hours;
  final int minutes;
  final String formatted;
  final int seconds;

  DurationInfo({
    required this.totalHours,
    required this.hours,
    required this.minutes,
    required this.formatted,
    required this.seconds,
  });

  factory DurationInfo.fromJson(Map<String, dynamic> json) {
    return DurationInfo(
      totalHours: json['total_hours'] != null ? (json['total_hours'] as num).toDouble() : 0.0,
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      formatted: json['formatted'] ?? '',
      seconds: json['seconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total_hours": totalHours,
      "hours": hours,
      "minutes": minutes,
      "formatted": formatted,
      "seconds": seconds,
    };
  }
}

class Result {
  // ✅ All fields from JSON
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

  final DurationInfo? duration;

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
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      username: json['username'] ?? '',
      employeeName: json['employee_name'] ?? '',

      date: json['date'] ?? '',
      time: json['time'] ?? '',
      timestamp: json['timestamp'] ?? '',

      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationAccuracy: json['location_accuracy'] != null
          ? (json['location_accuracy'] as num).toDouble()
          : null,

      status: json['status'] ?? '',
      confidenceScore: json['confidence_score'] != null
          ? (json['confidence_score'] as num).toDouble()
          : 0.0,
      faceDetected: json['face_detected'] ?? false,
      isVerified: json['is_verified'] ?? false,

      imageUrl: json['image_url'] ?? '',
      imageQualityScore: json['image_quality_score'] != null
          ? (json['image_quality_score'] as num).toDouble()
          : 0.0,
      faceLandmarksDetected: json['face_landmarks_detected'] ?? 0,

      checkoutDate: json['checkout_date'],
      checkoutTime: json['checkout_time'],
      checkoutTimestamp: json['checkout_timestamp'],

      checkoutLatitude: json['checkout_latitude'] != null
          ? (json['checkout_latitude'] as num).toDouble()
          : null,
      checkoutLongitude: json['checkout_longitude'] != null
          ? (json['checkout_longitude'] as num).toDouble()
          : null,
      checkoutLocationAccuracy: json['checkout_location_accuracy'] != null
          ? (json['checkout_location_accuracy'] as num).toDouble()
          : null,

      checkoutImageUrl: json['checkout_image_url'],
      checkoutConfidenceScore: json['checkout_confidence_score'] != null
          ? (json['checkout_confidence_score'] as num).toDouble()
          : null,
      checkoutStatus: json['checkout_status'],

      duration: json['duration'] != null ? DurationInfo.fromJson(json['duration']) : null,

      isSuspicious: json['is_suspicious'] ?? false,
      suspiciousReason: json['suspicious_reason'],

      deviceInfo: (json['device_info'] is Map<String, dynamic>)
          ? (json['device_info'] as Map<String, dynamic>)
          : <String, dynamic>{},

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employee_id": employeeId,
      "username": username,
      "employee_name": employeeName,
      "date": date,
      "time": time,
      "timestamp": timestamp,
      "latitude": latitude,
      "longitude": longitude,
      "location_accuracy": locationAccuracy,
      "status": status,
      "confidence_score": confidenceScore,
      "face_detected": faceDetected,
      "is_verified": isVerified,
      "image_url": imageUrl,
      "image_quality_score": imageQualityScore,
      "face_landmarks_detected": faceLandmarksDetected,
      "checkout_date": checkoutDate,
      "checkout_time": checkoutTime,
      "checkout_timestamp": checkoutTimestamp,
      "checkout_latitude": checkoutLatitude,
      "checkout_longitude": checkoutLongitude,
      "checkout_location_accuracy": checkoutLocationAccuracy,
      "checkout_image_url": checkoutImageUrl,
      "checkout_confidence_score": checkoutConfidenceScore,
      "checkout_status": checkoutStatus,
      "duration": duration?.toJson(),
      "is_suspicious": isSuspicious,
      "suspicious_reason": suspiciousReason,
      "device_info": deviceInfo,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
