class ProfileModel {
  final UserModel user;

  ProfileModel({required this.user});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      // ✅ Safe — if 'user' is null, use empty map
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {'user': user.toJson()};
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String department;
  final bool isFaceRegistered;
  final DateTime? faceRegisteredAt;  // ✅ nullable
  final String profileImage;
  final DateTime? dateJoined;        // ✅ nullable
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.department,
    required this.isFaceRegistered,
    this.faceRegisteredAt,
    required this.profileImage,
    this.dateJoined,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // ✅ All fields null-safe with fallbacks
      id: (json['id'] as int?) ?? 0,
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      employeeId: (json['employee_id'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      department: (json['department'] as String?) ?? '',
      isFaceRegistered: (json['is_face_registered'] as bool?) ?? false,
      faceRegisteredAt: json['face_registered_at'] != null
          ? DateTime.tryParse(json['face_registered_at'].toString())
          : null,
      profileImage: (json['profile_image'] as String?) ?? '',
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'].toString())
          : null,
      isActive: (json['is_active'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'employee_id': employeeId,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'department': department,
        'is_face_registered': isFaceRegistered,
        'face_registered_at': faceRegisteredAt?.toIso8601String(),
        'profile_image': profileImage,
        'date_joined': dateJoined?.toIso8601String(),
        'is_active': isActive,
      };
}