import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const int maxOrdersPerSlot = 30;

  /// Custom scheme registered in the macOS/Android/iOS app manifests. Supabase
  /// redirects to this after the user clicks the email confirmation link, and
  /// the app exchanges the returned PKCE code for a session.
  ///
  /// This exact URL must also be allow-listed under Supabase → Authentication →
  /// URL Configuration → Redirect URLs.
  static const String authCallbackUrl = 'canteen://auth-callback';

  static SupabaseClient? _client;

  static bool get isSupabaseConfigured => _client != null;

  static SupabaseClient get supabase {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Supabase is not initialized. Make sure .env exists with your '
        'SUPABASE_URL and SUPABASE_ANON_KEY, then restart the app.',
      );
    }
    return client;
  }

  static Future<void> init() async {
    await dotenv.load();

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase credentials missing. Copy .env.example to .env and fill in '
        'your Supabase project URL and anon key.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
    _client = Supabase.instance.client;
  }
}