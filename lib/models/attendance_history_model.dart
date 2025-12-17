class AttendanceHistory {
  int? count;
  Statistics? statistics;
  List<Result>? results; // Assuming this should be a list of Result objects.

  AttendanceHistory({this.count, this.statistics, this.results});

  AttendanceHistory.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    statistics = json['statistics'] != null
        ? Statistics.fromJson(json['statistics'])
        : null;
    if (json['results'] != null) {
      results = <Result>[];
      json['results'].forEach((v) {
        results!.add(Result.fromJson(v)); // Assuming Result class exists.
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = this.count;
    if (this.statistics != null) {
      data['statistics'] = this.statistics!.toJson();
    }
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList(); // Assuming Result class has toJson.
    }
    return data;
  }
}

class Statistics {
  int? total;
  int? verified;
  int? pending;
  int? rejected;
  String? verificationRate;

  Statistics(
      {this.total,
        this.verified,
        this.pending,
        this.rejected,
        this.verificationRate});

  Statistics.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    verified = json['verified'];
    pending = json['pending'];
    rejected = json['rejected'];
    verificationRate = json['verification_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = this.total;
    data['verified'] = this.verified;
    data['pending'] = this.pending;
    data['rejected'] = this.rejected;
    data['verification_rate'] = this.verificationRate;
    return data;
  }
}

// Assuming Result class looks something like this (you need to adjust it according to your needs):
class Result {
  // Define fields for Result object
  // For example:
  String? name;
  int? id;

  Result({this.name, this.id});

  Result.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'id': this.id,
    };
  }
}
