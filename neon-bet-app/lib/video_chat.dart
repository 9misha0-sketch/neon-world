import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});
  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final _local = RTCVideoRenderer();
  final _remote = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _stream;
  StreamSubscription<List<Map<String, dynamic>>>? _queueSub;
  StreamSubscription<List<Map<String, dynamic>>>? _signalSub;
  bool _ageConfirmed = false;
  bool _searching = false;
  bool _connected = false;
  bool _muted = false;
  bool _cameraOff = false;
  String _status = 'וידאו צ׳אט אחד על אחד';
  String? _sessionId;
  String? _otherUserId;
  int _lastSignalId = 0;

  SupabaseClient get db => Supabase.instance.client;
  String? get uid => db.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _local.initialize();
    _remote.initialize();
    _ensureAuth();
  }

  Future<void> _ensureAuth() async {
    if (db.auth.currentUser != null) return;
    try {
      await db.auth.signInAnonymously();
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'נדרשת התחברות כדי להשתמש בווידאו צ׳אט');
    }
  }

  Future<void> _startSearch() async {
    if (!_ageConfirmed) {
      _snack('יש לאשר גיל 18+ לפני התחלת שיחה');
      return;
    }
    await _ensureAuth();
    final me = uid;
    if (me == null) {
      _snack('לא ניתן להתחבר כרגע');
      return;
    }
    await db.from('video_profiles').upsert({'user_id': me, 'is_18_plus': true});
    await db.from('video_queue').upsert({'user_id': me});
    setState(() {
      _searching = true;
      _status = 'מחפש משתמש פנוי…';
    });
    await _tryMatch();
    _queueSub?.cancel();
    _queueSub = db.from('video_queue').stream(primaryKey: ['user_id']).listen((_) => _tryMatch());
  }

  Future<void> _tryMatch() async {
    if (!_searching || _sessionId != null || uid == null) return;
    final rows = await db.from('video_queue').select('user_id,joined_at').neq('user_id', uid!).order('joined_at').limit(1);
    if (rows.isEmpty) return;
    final other = rows.first['user_id'] as String;
    final blocked = await db.from('video_blocks').select('blocked_id').eq('blocker_id', uid!).eq('blocked_id', other).limit(1);
    if (blocked.isNotEmpty) return;
    try {
      final created = await db.from('video_sessions').insert({'user_a': uid, 'user_b': other}).select('id').single();
      final sid = created['id'] as String;
      await db.from('video_queue').delete().inFilter('user_id', [uid!, other]);
      await _joinSession(sid, other, true);
    } catch (_) {
      // Another client may have matched first. Wait for the next queue update.
    }
  }

  Future<void> _joinSession(String sid, String other, bool caller) async {
    _sessionId = sid;
    _otherUserId = other;
    _queueSub?.cancel();
    setState(() {
      _searching = false;
      _status = 'מתחבר למצלמה…';
    });

    _stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user', 'width': 720, 'height': 1280}
    });
    _local.srcObject = _stream;

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'}
      ]
    });
    for (final track in _stream!.getTracks()) {
      await _pc!.addTrack(track, _stream!);
    }
    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remote.srcObject = event.streams.first;
        if (mounted) setState(() { _connected = true; _status = 'מחובר'; });
      }
    };
    _pc!.onIceCandidate = (candidate) async {
      if (candidate.candidate == null || _sessionId == null || uid == null) return;
      await db.from('video_signals').insert({
        'session_id': _sessionId,
        'sender_id': uid,
        'kind': 'candidate',
        'payload': candidate.toMap(),
      });
    };

    _signalSub?.cancel();
    _signalSub = db.from('video_signals').stream(primaryKey: ['id']).eq('session_id', sid).order('id').listen(_handleSignals);

    if (caller) {
      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      await db.from('video_signals').insert({
        'session_id': sid,
        'sender_id': uid,
        'kind': 'offer',
        'payload': {'sdp': offer.sdp, 'type': offer.type},
      });
    }
  }

  Future<void> _handleSignals(List<Map<String, dynamic>> rows) async {
    if (_pc == null || uid == null) return;
    for (final row in rows) {
      final id = row['id'] as int;
      if (id <= _lastSignalId || row['sender_id'] == uid) continue;
      _lastSignalId = id;
      final kind = row['kind'] as String;
      final p = Map<String, dynamic>.from(row['payload'] as Map);
      if (kind == 'offer') {
        await _pc!.setRemoteDescription(RTCSessionDescription(p['sdp'] as String?, p['type'] as String?));
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        await db.from('video_signals').insert({
          'session_id': _sessionId,
          'sender_id': uid,
          'kind': 'answer',
          'payload': {'sdp': answer.sdp, 'type': answer.type},
        });
      } else if (kind == 'answer') {
        await _pc!.setRemoteDescription(RTCSessionDescription(p['sdp'] as String?, p['type'] as String?));
      } else if (kind == 'candidate') {
        await _pc!.addCandidate(RTCIceCandidate(p['candidate'] as String?, p['sdpMid'] as String?, p['sdpMLineIndex'] as int?));
      }
    }
  }

  Future<void> _next() async {
    await _endSession();
    await _startSearch();
  }

  Future<void> _reportAndBlock() async {
    if (uid == null || _otherUserId == null) return;
    await db.from('video_reports').insert({
      'reporter_id': uid,
      'reported_id': _otherUserId,
      'session_id': _sessionId,
      'reason': 'user_reported_in_video_chat',
    });
    await db.from('video_blocks').upsert({'blocker_id': uid, 'blocked_id': _otherUserId});
    _snack('המשתמש דווח ונחסם');
    await _next();
  }

  Future<void> _endSession() async {
    _queueSub?.cancel();
    _signalSub?.cancel();
    if (_sessionId != null) {
      try {
        await db.from('video_sessions').update({'status': 'ended', 'ended_at': DateTime.now().toIso8601String()}).eq('id', _sessionId!);
      } catch (_) {}
    }
    for (final t in _stream?.getTracks() ?? <MediaStreamTrack>[]) {
      t.stop();
    }
    await _pc?.close();
    _local.srcObject = null;
    _remote.srcObject = null;
    _pc = null;
    _stream = null;
    _sessionId = null;
    _otherUserId = null;
    _lastSignalId = 0;
    if (mounted) setState(() { _connected = false; _searching = false; _status = 'וידאו צ׳אט אחד על אחד'; });
  }

  void _toggleMute() {
    _muted = !_muted;
    for (final t in _stream?.getAudioTracks() ?? <MediaStreamTrack>[]) { t.enabled = !_muted; }
    setState(() {});
  }

  void _toggleCamera() {
    _cameraOff = !_cameraOff;
    for (final t in _stream?.getVideoTracks() ?? <MediaStreamTrack>[]) { t.enabled = !_cameraOff; }
    setState(() {});
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _endSession();
    _local.dispose();
    _remote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: const Color(0xFF050817),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('וידאו צ׳אט 18+', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                Text(_connected ? '● LIVE' : _searching ? 'מחפש…' : 'מוכן', style: TextStyle(color: _connected ? Colors.greenAccent : Colors.cyanAccent)),
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    color: const Color(0xFF111827),
                    child: _stream == null
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.video_camera_front_outlined, size: 72),
                            const SizedBox(height: 14),
                            Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 20),
                            CheckboxListTile(
                              value: _ageConfirmed,
                              onChanged: (v) => setState(() => _ageConfirmed = v ?? false),
                              title: const Text('אני מאשר/ת שאני בן/בת 18 ומעלה'),
                              subtitle: const Text('אסור תוכן מיני, עירום, הטרדה או צילום ללא הסכמה.'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(onPressed: _searching ? null : _startSearch, icon: const Icon(Icons.search), label: const Text('מצא שיחה אחד על אחד')),
                          ]))
                        : Stack(fit: StackFit.expand, children: [
                            RTCVideoView(_remote, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                            Positioned(left: 12, top: 12, width: 120, height: 170, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: RTCVideoView(_local, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover))),
                          ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_stream != null)
                Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
                  IconButton.filled(onPressed: _toggleMute, icon: Icon(_muted ? Icons.mic_off : Icons.mic)),
                  IconButton.filled(onPressed: _toggleCamera, icon: Icon(_cameraOff ? Icons.videocam_off : Icons.videocam)),
                  FilledButton.icon(onPressed: _next, icon: const Icon(Icons.skip_next), label: const Text('הבא')),
                  OutlinedButton.icon(onPressed: _reportAndBlock, icon: const Icon(Icons.report), label: const Text('דווח וחסום')),
                ]),
              const SizedBox(height: 8),
              const Text('18+ בלבד • שמרו על כבוד ופרטיות • ניתן לדווח ולחסום בכל עת', style: TextStyle(color: Color(0xFF9CA8BD), fontSize: 12), textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }
}
