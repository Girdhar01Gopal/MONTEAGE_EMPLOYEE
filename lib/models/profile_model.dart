class ProfileModel {
  final UserModel user;

  ProfileModel({
    required this.user,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }
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
  final DateTime faceRegisteredAt;
  final String profileImage;
  final DateTime dateJoined;
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
    required this.faceRegisteredAt,
    required this.profileImage,
    required this.dateJoined,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      employeeId: json['employee_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      department: json['department'] as String,
      isFaceRegistered: json['is_face_registered'] as bool,
      faceRegisteredAt: DateTime.parse(json['face_registered_at']),
      profileImage: json['profile_image'] as String,
      dateJoined: DateTime.parse(json['date_joined']),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'employee_id': employeeId,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'department': department,
      'is_face_registered': isFaceRegistered,
      'face_registered_at': faceRegisteredAt.toIso8601String(),
      'profile_image': profileImage,
      'date_joined': dateJoined.toIso8601String(),
      'is_active': isActive,
    };
  }
}
