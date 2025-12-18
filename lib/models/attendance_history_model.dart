// lib/models/attendance_history_model.dart

class AttendanceHistoryModel {
  int? count;
  Statistics? statistics;
  List<Results>? results;

  AttendanceHistoryModel({this.count, this.statistics, this.results});

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      count: json['count'] as int?,
      statistics: json['statistics'] != null
          ? Statistics.fromJson(json['statistics'] as Map<String, dynamic>)
          : null,
      results: (json['results'] as List<dynamic>?)
          ?.map((v) => Results.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (statistics != null) 'statistics': statistics!.toJson(),
      if (results != null)
        'results': results!.map((v) => v.toJson()).toList(),
    };
  }
}

class Statistics {
  int? total;
  int? verified;
  int? pending;
  int? rejected;
  String? verificationRate;

  Statistics({
    this.total,
    this.verified,
    this.pending,
    this.rejected,
    this.verificationRate,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      total: json['total'] as int?,
      verified: json['verified'] as int?,
      pending: json['pending'] as int?,
      rejected: json['rejected'] as int?,
      verificationRate: json['verification_rate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'verified': verified,
      'pending': pending,
      'rejected': rejected,
      'verification_rate': verificationRate,
    };
  }
}

class Results {
  String? id;
  String? userName;
  String? employeeId;
  String? timestamp;
  String? date;
  double? latitude;
  double? longitude;
  double? locationAccuracy;
  String? imageUrl;
  String? status;
  double? confidenceScore;
  bool? faceDetected;
  bool? isVerified;
  double? imageQualityScore;
  bool? isSuspicious;
  String? suspiciousReason;

  Results({
    this.id,
    this.userName,
    this.employeeId,
    this.timestamp,
    this.date,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.imageUrl,
    this.status,
    this.confidenceScore,
    this.faceDetected,
    this.isVerified,
    this.imageQualityScore,
    this.isSuspicious,
    this.suspiciousReason,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      id: json['id'] as String?,
      userName: json['user_name'] as String?,
      employeeId: json['employee_id'] as String?,
      timestamp: json['timestamp'] as String?,
      date: json['date'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['location_accuracy'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      faceDetected: json['face_detected'] as bool?,
      isVerified: json['is_verified'] as bool?,
      imageQualityScore: (json['image_quality_score'] as num?)?.toDouble(),
      isSuspicious: json['is_suspicious'] as bool?,
      suspiciousReason: json['suspicious_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'employee_id': employeeId,
      'timestamp': timestamp,
      'date': date,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': locationAccuracy,
      'image_url': imageUrl,
      'status': status,
      'confidence_score': confidenceScore,
      'face_detected': faceDetected,
      'is_verified': isVerified,
      'image_quality_score': imageQualityScore,
      'is_suspicious': isSuspicious,
      'suspicious_reason': suspiciousReason,
    };
  }
}
