import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'neon_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.hasSupabase) {
    runApp(const ConfigurationErrorApp());
    return;
  }
  await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  runApp(const WorldLiveChatApp());
}

class WorldLiveChatApp extends StatelessWidget {
  const WorldLiveChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Live Chat',
      theme: NeonTheme.dark,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (_, __) => auth.currentSession == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(body: SafeArea(child: Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('Missing SUPABASE_URL / SUPABASE_ANON_KEY. Start Flutter with the --dart-define values shown in README.md.', textAlign: TextAlign.center)),
    ))),
  );
}
