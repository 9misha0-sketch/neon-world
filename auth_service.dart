import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Session? get session => _client.auth.currentSession;
  User? get user => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email.trim(), password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}
