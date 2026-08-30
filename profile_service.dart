import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<Map<String, dynamic>?> loadMine() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final p = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (p == null) return null;
    final priv = await _client.from('user_private').select('coins,vip_until,is_admin').eq('user_id', user.id).maybeSingle();
    final out = Map<String, dynamic>.from(p);
    if (priv != null) out.addAll(priv);
    final path = out['avatar_path']?.toString();
    if (path != null && path.isNotEmpty) out['avatar_url'] = _client.storage.from('avatars').getPublicUrl(path);
    out['country'] = _countryLabel(out['country_code']?.toString());
    out['language'] = _languageLabel(out['language_code']?.toString());
    out['gender_label'] = _genderLabel(out['gender']?.toString());
    final vipUntil = DateTime.tryParse(out['vip_until']?.toString() ?? '');
    out['is_vip'] = vipUntil != null && vipUntil.isAfter(DateTime.now().toUtc());
    return out;
  }

  Future<String> uploadAvatar(Uint8List bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final ext = extension.toLowerCase().replaceAll('.', '');
    final path = '${user.id}/avatar.${ext.isEmpty ? 'jpg' : ext}';
    await _client.storage.from('avatars').uploadBinary(path, bytes,
      fileOptions: const FileOptions(upsert: true, cacheControl: '3600'));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> saveMine({
    required String displayName,
    required String country,
    required String language,
    required DateTime birthDate,
    required String gender,
    required String bio,
    String? avatarUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    await _client.from('profiles').update({
      'display_name': displayName.trim(),
      'country_code': _countryCode(country),
      'language_code': _languageCode(language),
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': _genderCode(gender),
      'bio': bio.trim(),
      if (avatarUrl != null) 'avatar_path': _avatarPath(avatarUrl),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', user.id);
  }


  String _avatarPath(String value) {
    const marker = '/storage/v1/object/public/avatars/';
    final i = value.indexOf(marker);
    return i >= 0 ? Uri.decodeComponent(value.substring(i + marker.length).split('?').first) : value;
  }

  String _countryCode(String v) => const {'Worldwide':'ALL','Israel':'IL','Europe':'EU','North America':'NA','South America':'SA','Asia':'AS','Africa':'AF','Oceania':'OC'}[v] ?? 'ALL';
  String _languageCode(String v) => const {'English':'en','Hebrew':'he','Arabic':'ar','Spanish':'es','French':'fr','German':'de','Russian':'ru','Portuguese':'pt'}[v] ?? 'en';
  String _genderCode(String v) => const {'Man':'male','Woman':'female','Non-binary':'other','Prefer not to say':'prefer_not_to_say'}[v] ?? 'prefer_not_to_say';
  String _countryLabel(String? v) => const {'ALL':'Worldwide','IL':'Israel','EU':'Europe','NA':'North America','SA':'South America','AS':'Asia','AF':'Africa','OC':'Oceania'}[v] ?? 'Worldwide';
  String _languageLabel(String? v) => const {'en':'English','he':'Hebrew','ar':'Arabic','es':'Spanish','fr':'French','de':'German','ru':'Russian','pt':'Portuguese'}[v] ?? 'English';
  String _genderLabel(String? v) => const {'male':'Man','female':'Woman','other':'Non-binary','prefer_not_to_say':'Prefer not to say'}[v] ?? 'Prefer not to say';
}
