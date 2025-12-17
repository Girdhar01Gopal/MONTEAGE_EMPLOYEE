class AttendanceHistoryItem {
  final String date;
  final String status;
  final String checkIn;
  final String checkOut;
  final String address;
  final String latitude;
  final String longitude;
  final String remarks;

  AttendanceHistoryItem({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.remarks,
  });

  factory AttendanceHistoryItem.fromJson(Map<String, dynamic> j) {
    return AttendanceHistoryItem(
      date: j["date"] ?? "",
      status: j["status"] ?? "",
      checkIn: j["check_in"] ?? "--",
      checkOut: j["check_out"] ?? "--",
      address: j["address"] ?? "",
      latitude: j["latitude"]?.toString() ?? "",
      longitude: j["longitude"]?.toString() ?? "",
      remarks: j["remarks"] ?? "",
    );
  }
}
