import 'package:supabase_flutter/supabase_flutter.dart';

class SocialService {
  final _db = Supabase.instance.client;

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    final response = await _db.functions.invoke('social', body: body);
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['error'] != null) throw Exception(data['error']);
    return data;
  }

  Future<void> addFriend(String id) async {
    await _invoke({'action': 'friend_request', 'targetUserId': id});
  }

  Future<void> respondRequest(String id, bool accept) async {
    await _invoke({'action': 'respond_request', 'requestId': id, 'accept': accept});
  }

  Future<void> sendMessage(String id, String body) async {
    final me = _db.auth.currentUser?.id;
    if (me == null) throw StateError('Not signed in');
    await _db.from('messages').insert({'sender_id': me, 'receiver_id': id, 'body': body.trim()});
  }

  Future<void> sendGift(String id, String key) async {
    await _invoke({'action': 'gift', 'targetUserId': id, 'giftKey': key});
  }

  Future<void> rate(String id, int stars) async {
    await _invoke({'action': 'rate', 'targetUserId': id, 'stars': stars});
  }

  Future<List<Map<String, dynamic>>> requests() async {
    final d = await _invoke({'action': 'requests'});
    final rows = List<Map<String, dynamic>>.from(d['requests'] ?? const []);
    for (final r in rows) {
      final p = r['profiles'];
      if (p is Map && p['avatar_path'] != null) {
        final pp = Map<String, dynamic>.from(p);
        pp['avatar_url'] = _db.storage.from('avatars').getPublicUrl(pp['avatar_path'].toString());
        r['profiles'] = pp;
      }
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> friends() async {
    final d = await _invoke({'action': 'friends'});
    final rows = List<Map<String, dynamic>>.from(d['friends'] ?? const []);
    for (final p in rows) {
      final path = p['avatar_path']?.toString();
      if (path != null && path.isNotEmpty) {
        p['avatar_url'] = _db.storage.from('avatars').getPublicUrl(path);
      }
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> messagesWith(String id) async {
    final me = _db.auth.currentUser?.id;
    if (me == null) throw StateError('Not signed in');
    final rows = await _db
        .from('messages')
        .select('id,sender_id,receiver_id,body,created_at,read_at')
        .or('and(sender_id.eq.$me,receiver_id.eq.$id),and(sender_id.eq.$id,receiver_id.eq.$me)')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }
}
