import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_result.dart';

class MatchmakingService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<MatchResult> join({
    required String region,
    required String language,
    String genderPreference = 'Everyone',
  }) async {
    return _find(
      countryCode: _country(region),
      languageCode: _language(language),
      lookingFor: _gender(genderPreference),
    );
  }

  Future<MatchResult> status() => _find();

  Future<MatchResult> _find({String? countryCode, String? languageCode, String? lookingFor}) async {
    final response = await _db.functions.invoke('find-match', body: {
      if (countryCode != null) 'country_code': countryCode,
      if (languageCode != null) 'language_code': languageCode,
      if (lookingFor != null) 'looking_for': lookingFor,
    });
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['error'] != null) throw Exception(data['error']);
    if (data['status'] != 'matched') return const MatchResult.waiting();

    final encounterId = data['encounterId']?.toString();
    final roomName = data['roomName']?.toString();
    if (encounterId == null || roomName == null) throw Exception('Invalid match response');

    final tokenResponse = await _db.functions.invoke('livekit-token', body: {'encounterId': encounterId});
    final tokenData = Map<String, dynamic>.from(tokenResponse.data as Map);
    if (tokenData['error'] != null) throw Exception(tokenData['error']);

    final p = Map<String, dynamic>.from((data['partner'] as Map?) ?? const {});
    String? avatarUrl;
    final avatarPath = p['avatarPath']?.toString();
    if (avatarPath != null && avatarPath.isNotEmpty) {
      avatarUrl = _db.storage.from('avatars').getPublicUrl(avatarPath);
    }

    return MatchResult.matched(
      encounterId: encounterId,
      roomName: tokenData['roomName']?.toString() ?? roomName,
      token: tokenData['token']?.toString() ?? '',
      liveKitUrl: tokenData['url']?.toString() ?? '',
      partnerId: p['id']?.toString() ?? 'unknown',
      partnerName: p['displayName']?.toString() ?? 'Someone',
      partnerAvatarUrl: avatarUrl,
      partnerRating: (p['rating'] as num?)?.toDouble(),
      partnerVip: p['isVip'] == true,
    );
  }

  Future<void> leave() async {
    await _db.functions.invoke('find-match', body: {'action': 'leave'});
  }

  Future<void> report({required String targetUserId, required String reason}) async {
    final me = _db.auth.currentUser?.id;
    if (me == null) throw StateError('Not signed in');
    await _db.from('reports').insert({
      'reporter_id': me,
      'reported_id': targetUserId,
      'reason': reason,
    });
  }

  Future<void> block({required String targetUserId}) async {
    final me = _db.auth.currentUser?.id;
    if (me == null) throw StateError('Not signed in');
    await _db.from('blocks').upsert({
      'blocker_id': me,
      'blocked_id': targetUserId,
    });
  }

  String _country(String v) {
    const m = {
      'Worldwide': 'ALL', 'Israel': 'IL', 'Europe': 'EU', 'North America': 'NA',
      'South America': 'SA', 'Asia': 'AS', 'Africa': 'AF', 'Oceania': 'OC',
    };
    return m[v] ?? 'ALL';
  }

  String _language(String v) {
    const m = {
      'Any language': 'ALL', 'English': 'en', 'Hebrew': 'he', 'Arabic': 'ar',
      'Spanish': 'es', 'French': 'fr', 'German': 'de', 'Russian': 'ru', 'Portuguese': 'pt',
    };
    return m[v] ?? 'ALL';
  }

  String _gender(String v) {
    const m = {'Everyone': 'everyone', 'Man': 'male', 'Woman': 'female', 'Non-binary': 'other'};
    return m[v] ?? 'everyone';
  }
}
