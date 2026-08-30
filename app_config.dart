class AppConfig {
  // Safe-to-ship client values. Never place service_role or LiveKit secrets here.
  static const supabaseUrl = 'https://orxnuxqhsqedetspjfov.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_uiFqR9SCnKiPssCj_1Vldg_ll7HkGJP';
  static const liveKitUrl = 'wss://neon-chat-61s1uh5j.livekit.cloud';
  static bool get hasSupabase => true;
}
