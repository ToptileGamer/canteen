enum UserRole { student, collegeStaff, canteenStaff }

/// Maps between the Dart enum and the string stored in the `profiles.role` column.
extension UserRoleDb on UserRole {
  String get dbName => switch (this) {
        UserRole.student => 'student',
        UserRole.collegeStaff => 'college_staff',
        UserRole.canteenStaff => 'canteen_staff',
      };
}

UserRole userRoleFromDb(String value) => switch (value) {
      'college_staff' => UserRole.collegeStaff,
      'canteen_staff' => UserRole.canteenStaff,
      _ => UserRole.student,
    };

class AppUser {
  final String id;
  final String name;
  final String email;
  final String rollNumber;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.role,
  });

  bool get isStaffRole =>
      role == UserRole.collegeStaff || role == UserRole.canteenStaff;

  /// Only canteen staff are allowed to add/manage menu items.
  bool get canManageMenu => role == UserRole.canteenStaff;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'role': role.dbName,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        rollNumber: json['rollNumber'],
        role: userRoleFromDb(json['role']),
      );
}
