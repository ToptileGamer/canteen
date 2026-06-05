enum UserRole { student, staff }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        rollNumber: json['rollNumber'],
        role: UserRole.values.byName(json['role']),
      );
}
