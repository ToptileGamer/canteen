import '../models/user.dart';
import 'mock_data.dart';

class AuthService {
  final List<AppUser> _users = [...MockData.dummyUsers];
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isStaff => _currentUser?.role == UserRole.staff;

  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _users.where((u) => u.email == email).firstOrNull;
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    _currentUser = user;
    return user;
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String rollNumber,
    required UserRole role,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already registered');
    }

    final user = AppUser(
      id: '${role.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      rollNumber: rollNumber,
      role: role,
    );
    _users.add(user);
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
