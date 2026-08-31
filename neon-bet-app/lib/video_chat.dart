import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const turnUrl = String.fromEnvironment('TURN_URL', defaultValue: '');
const turnUsername = String.fromEnvironment('TURN_USERNAME', defaultValue: '');
const turnCredential = String.fromEnvironment('TURN_CREDENTIAL', defaultValue: '');

class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final RTCVideoRenderer _local = RTCVideoRenderer();
  final RTCVideoRenderer _remote = RTCVideoRenderer();

  RTCPeerConnection? _pc;
  MediaStream? _stream;
  Timer? _matchTimer;
  Timer? _signalTimer;

  bool _renderersReady = false;
  bool _ageConfirmed = false;
  bool _searching = false;
  bool _connected = false;
  bool _muted = false;
  bool _cameraOff = false;
  bool _busyMatching = false;
  bool _busySignals = false;
  bool _remoteDescriptionSet = false;

  String _status = 'וידאו צ׳אט אחד על אחד';
  String? _sessionId;
  String? _otherUserId;
  int _lastSignalId = 0;
  final List<RTCIceCandidate> _pendingCandidates = [];

  SupabaseClient get db => Supabase.instance.client;
  String? get uid => db.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    try {
      await _local.initialize();
      await _remote.initialize();
      if (!mounted) return;
      setState(() => _renderersReady = true);
      await _ensureAuth();
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'לא ניתן לאתחל את רכיב הווידאו במכשיר');
    }
  }

  Future<bool> _ensureAuth() async {
    try {
      if (db.auth.currentUser == null) {
        await db.auth.signInAnonymously();
      }
      return db.auth.currentUser != null;
    } catch (_) {
      if (mounted) {
        setState(() => _status = 'לא ניתן להתחבר כרגע לשרת הווידאו');
      }
      return false;
    }
  }

  Future<bool> _ensureMedia() async {
    if (_stream != null) return true;
    if (!_renderersReady) {
      _snack('רכיב הווידאו עדיין נטען');
      return false;
    }

    try {
      final media = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 720},
          'height': {'ideal': 1280},
          'frameRate': {'ideal': 24},
        }
      });
      _stream = media;
      _local.srcObject = media;
      if (mounted) setState(() {});
      return true;
    } catch (_) {
      if (mounted) {
        setState(() => _status = 'יש לאשר הרשאה למצלמה ולמיקרופון');
      }
      _snack('פתח הרשאות מצלמה ומיקרופון עבור NEON BET');
      return false;
    }
  }

  Future<void> _startSearch() async {
    if (_searching || _sessionId != null) return;
    if (!_ageConfirmed) {
      _snack('יש לאשר גיל 18+ לפני התחלת שיחה');
      return;
    }

    if (!await _ensureAuth()) return;
    if (!await _ensureMedia()) return;

    final me = uid;
    if (me == null) return;

    try {
      await db.from('video_profiles').upsert({
        'user_id': me,
        'is_18_plus': true,
      });
    } catch (_) {
      _snack('לא ניתן להכין את פרופיל הווידאו');
      return;
    }

    if (!mounted) return;
    setState(() {
      _searching = true;
      _status = 'מחפש משתמש פנוי…';
    });

    await _pollMatch();
    _matchTimer?.cancel();
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollMatch());
  }

  Future<void> _pollMatch() async {
    if (!_searching || _sessionId != null || _busyMatching || uid == null) return;
    _busyMatching = true;
    try {
      final dynamic result = await db.rpc('video_matchmake');
      if (result is List && result.isNotEmpty) {
        final row = Map<String, dynamic>.from(result.first as Map);
        final sid = row['session_id']?.toString();
        final other = row['other_user_id']?.toString();
        final caller = row['is_caller'] == true;
        if (sid != null && other != null && _sessionId == null) {
          await _joinSession(sid, other, caller);
        }
      }
    } catch (_) {
      if (mounted && _sessionId == null) {
        setState(() => _status = 'מנסה להתחבר למשתמש נוסף…');
      }
    } finally {
      _busyMatching = false;
    }
  }

  List<Map<String, dynamic>> _iceServers() {
    final servers = <Map<String, dynamic>>[
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun.cloudflare.com:3478'},
    ];
    if (turnUrl.isNotEmpty && turnUsername.isNotEmpty && turnCredential.isNotEmpty) {
      servers.add({
        'urls': turnUrl,
        'username': turnUsername,
        'credential': turnCredential,
      });
    }
    return servers;
  }

  Future<void> _joinSession(String sid, String other, bool caller) async {
    if (_sessionId != null) return;
    _sessionId = sid;
    _otherUserId = other;
    _matchTimer?.cancel();

    if (mounted) {
      setState(() {
        _searching = false;
        _status = 'מתחבר לשיחה…';
      });
    }

    if (!await _ensureMedia()) {
      await _endSession(stopMedia: true);
      return;
    }

    try {
      _pc = await createPeerConnection({
        'iceServers': _iceServers(),
        'sdpSemantics': 'unified-plan',
      });

      for (final track in _stream!.getTracks()) {
        await _pc!.addTrack(track, _stream!);
      }

      _pc!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remote.srcObject = event.streams.first;
          if (mounted) {
            setState(() {
              _connected = true;
              _status = 'מחובר';
            });
          }
        }
      };

      _pc!.onIceCandidate = (candidate) async {
        if (candidate.candidate == null || _sessionId == null || uid == null) return;
        try {
          await db.from('video_signals').insert({
            'session_id': _sessionId,
            'sender_id': uid,
            'kind': 'candidate',
            'payload': candidate.toMap(),
          });
        } catch (_) {}
      };

      _pc!.onIceConnectionState = (state) {
        final text = state.toString();
        if (!mounted) return;
        if (text.contains('Failed') || text.contains('Disconnected')) {
          setState(() {
            _connected = false;
            _status = turnUrl.isEmpty
                ? 'החיבור הישיר נכשל. נדרש TURN לחלק מהרשתות.'
                : 'החיבור נותק. לחץ הבא כדי לנסות שוב.';
          });
        }
      };

      _signalTimer?.cancel();
      _signalTimer = Timer.periodic(const Duration(milliseconds: 700), (_) => _pollSignals());
      await _pollSignals();

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
    } catch (_) {
      if (mounted) setState(() => _status = 'אירעה שגיאה בהקמת שיחת הווידאו');
      await _endSession(stopMedia: false);
    }
  }

  Future<void> _pollSignals() async {
    if (_pc == null || _sessionId == null || uid == null || _busySignals) return;
    _busySignals = true;
    try {
      final rows = await db
          .from('video_signals')
          .select('id,sender_id,kind,payload')
          .eq('session_id', _sessionId!)
          .gt('id', _lastSignalId)
          .order('id');

      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw);
        final id = (row['id'] as num).toInt();
        if (id > _lastSignalId) _lastSignalId = id;
        if (row['sender_id']?.toString() == uid) continue;

        final kind = row['kind']?.toString();
        final payload = Map<String, dynamic>.from(row['payload'] as Map);

        if (kind == 'offer') {
          await _pc!.setRemoteDescription(
            RTCSessionDescription(payload['sdp']?.toString(), payload['type']?.toString()),
          );
          _remoteDescriptionSet = true;
          await _flushPendingCandidates();

          final answer = await _pc!.createAnswer();
          await _pc!.setLocalDescription(answer);
          await db.from('video_signals').insert({
            'session_id': _sessionId,
            'sender_id': uid,
            'kind': 'answer',
            'payload': {'sdp': answer.sdp, 'type': answer.type},
          });
        } else if (kind == 'answer') {
          await _pc!.setRemoteDescription(
            RTCSessionDescription(payload['sdp']?.toString(), payload['type']?.toString()),
          );
          _remoteDescriptionSet = true;
          await _flushPendingCandidates();
        } else if (kind == 'candidate') {
          final candidate = RTCIceCandidate(
            payload['candidate']?.toString(),
            payload['sdpMid']?.toString(),
            payload['sdpMLineIndex'] is num ? (payload['sdpMLineIndex'] as num).toInt() : null,
          );
          if (_remoteDescriptionSet) {
            await _pc!.addCandidate(candidate);
          } else {
            _pendingCandidates.add(candidate);
          }
        }
      }
    } catch (_) {
      // Polling continues automatically; transient network failures do not end the call.
    } finally {
      _busySignals = false;
    }
  }

  Future<void> _flushPendingCandidates() async {
    if (_pc == null || !_remoteDescriptionSet) return;
    final pending = List<RTCIceCandidate>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in pending) {
      try {
        await _pc!.addCandidate(candidate);
      } catch (_) {}
    }
  }

  Future<void> _next() async {
    await _endSession(stopMedia: false);
    await _startSearch();
  }

  Future<void> _reportAndBlock() async {
    if (uid == null || _otherUserId == null) return;
    try {
      await db.from('video_reports').insert({
        'reporter_id': uid,
        'reported_id': _otherUserId,
        'session_id': _sessionId,
        'reason': 'user_reported_in_video_chat',
      });
      await db.from('video_blocks').upsert({
        'blocker_id': uid,
        'blocked_id': _otherUserId,
      });
      _snack('המשתמש דווח ונחסם');
    } catch (_) {
      _snack('הדיווח לא נשלח. נסה שוב.');
    }
    await _next();
  }

  Future<void> _endSession({bool stopMedia = true}) async {
    _matchTimer?.cancel();
    _signalTimer?.cancel();
    _matchTimer = null;
    _signalTimer = null;

    final sid = _sessionId;
    if (sid != null) {
      try {
        await db.from('video_sessions').update({
          'status': 'ended',
          'ended_at': DateTime.now().toIso8601String(),
        }).eq('id', sid);
      } catch (_) {}
    }

    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;
    _remote.srcObject = null;

    if (stopMedia) {
      for (final track in _stream?.getTracks() ?? <MediaStreamTrack>[]) {
        track.stop();
      }
      _stream = null;
      _local.srcObject = null;
    }

    _sessionId = null;
    _otherUserId = null;
    _lastSignalId = 0;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();

    if (mounted) {
      setState(() {
        _connected = false;
        _searching = false;
        _status = 'וידאו צ׳אט אחד על אחד';
      });
    }
  }

  void _toggleMute() {
    _muted = !_muted;
    for (final track in _stream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_muted;
    }
    if (mounted) setState(() {});
  }

  void _toggleCamera() {
    _cameraOff = !_cameraOff;
    for (final track in _stream?.getVideoTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_cameraOff;
    }
    if (mounted) setState(() {});
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    _signalTimer?.cancel();
    for (final track in _stream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
    _pc?.close();
    _local.dispose();
    _remote.dispose();
    super.dispose();
  }

  Widget _videoArea() {
    if (_stream == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_camera_front_outlined, size: 72),
              const SizedBox(height: 14),
              Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: _ageConfirmed,
                onChanged: (value) => setState(() => _ageConfirmed = value ?? false),
                title: const Text('אני מאשר/ת שאני בן/בת 18 ומעלה'),
                subtitle: const Text('אסור תוכן מיני, עירום, הטרדה או צילום ללא הסכמה.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _searching ? null : _startSearch,
                icon: const Icon(Icons.search),
                label: const Text('מצא שיחה אחד על אחד'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_remote.srcObject != null)
          RTCVideoView(
            _remote,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        else
          RTCVideoView(
            _local,
            mirror: true,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        if (_remote.srcObject != null)
          Positioned(
            left: 12,
            top: 12,
            width: 120,
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: RTCVideoView(
                _local,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        if (!_connected)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_status, textAlign: TextAlign.center),
            ),
          ),
      ],
    );
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('וידאו צ׳אט 18+', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                    Text(
                      _connected ? '● LIVE' : _searching ? 'מחפש…' : 'מוכן',
                      style: TextStyle(color: _connected ? Colors.greenAccent : Colors.cyanAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      color: const Color(0xFF111827),
                      child: _videoArea(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_stream != null)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: _toggleMute,
                        icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                      ),
                      IconButton.filled(
                        onPressed: _toggleCamera,
                        icon: Icon(_cameraOff ? Icons.videocam_off : Icons.videocam),
                      ),
                      FilledButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('הבא'),
                      ),
                      if (_otherUserId != null)
                        OutlinedButton.icon(
                          onPressed: _reportAndBlock,
                          icon: const Icon(Icons.report),
                          label: const Text('דווח וחסום'),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                const Text(
                  '18+ בלבד • שמרו על כבוד ופרטיות • ניתן לדווח ולחסום בכל עת',
                  style: TextStyle(color: Color(0xFF9CA8BD), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
