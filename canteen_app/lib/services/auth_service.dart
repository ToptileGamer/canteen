import '../config/app_config.dart';
import '../models/user.dart';

/// Outcome of a sign-up attempt.
enum SignupResult {
  /// A session was returned immediately (email confirmation disabled).
  signedIn,

  /// The account was created but no session exists yet — the user has to click
  /// the confirmation link that was emailed to them. The session is established
  /// later through the [AppConfig.authCallbackUrl] deep link.
  needsEmailVerification,
}

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isStaff => _currentUser?.isStaffRole ?? false;
  bool get canManageMenu => _currentUser?.canManageMenu ?? false;

  Future<AppUser?> restoreSession() async {
    final supabase = AppConfig.supabase;
    if (supabase.auth.currentSession == null) return null;
    _currentUser = await _loadProfile();
    return _currentUser;
  }

  Future<AppUser> login(String email, String password) async {
    final supabase = AppConfig.supabase;
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } catch (_) {
      throw Exception('Invalid email or password');
    }
    _currentUser = await _loadProfile();
    return _currentUser!;
  }

  Future<SignupResult> signup({
    required String name,
    required String email,
    required String rollNumber,
    required UserRole role,
    required String password,
  }) async {
    final supabase = AppConfig.supabase;
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: AppConfig.authCallbackUrl,
        data: {'name': name, 'roll_number': rollNumber, 'role': role.dbName},
      );
    } catch (e) {
      throw Exception(_cleanError(e));
    }

    // With email confirmation enabled there is no session yet, so the profile
    // row is loaded later, once the confirmation link signs the user in.
    if (supabase.auth.currentUser == null) {
      return SignupResult.needsEmailVerification;
    }

    _currentUser = await _loadProfile();
    return SignupResult.signedIn;
  }

  /// Loads the profile for the session that the email-confirmation deep link
  /// just established. Returns null when there is no session (yet).
  Future<AppUser?> loadProfileFromSession() async {
    final supabase = AppConfig.supabase;
    if (supabase.auth.currentSession == null) return null;
    _currentUser = await _loadProfile();
    return _currentUser;
  }

  Future<AppUser> _loadProfile() async {
    final supabase = AppConfig.supabase;
    final userId = supabase.auth.currentUser!.id;
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row == null) {
      throw Exception('Profile not found. Please contact the canteen admin.');
    }

    return AppUser(
      id: row['id'],
      name: row['name'] ?? '',
      email: row['email'] ?? '',
      rollNumber: row['roll_number'] ?? '',
      role: userRoleFromDb(row['role'] ?? 'student'),
    );
  }

  Future<void> logout() async {
    final supabase = AppConfig.supabase;
    try {
      await supabase.auth.signOut();
    } catch (_) {
      // ignore sign out errors
    } finally {
      _currentUser = null;
    }
  }

  String _cleanError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('already')) return 'Email already registered';
    if (msg.contains('password')) return 'Password should be at least 6 characters';
    return msg;
  }
}