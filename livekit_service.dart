import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  Room? room;

  Future<Room> connect({required String url, required String token}) async {
    await disconnect();
    final r = Room();
    await r.connect(url, token);
    await r.localParticipant.setCameraEnabled(true);
    await r.localParticipant.setMicrophoneEnabled(true);
    room = r;
    return r;
  }

  Future<void> setMicEnabled(bool enabled) async {
    await room?.localParticipant.setMicrophoneEnabled(enabled);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await room?.localParticipant.setCameraEnabled(enabled);
  }

  Future<void> disconnect() async {
    final r = room;
    room = null;
    if (r != null) {
      await r.disconnect();
      await r.dispose();
    }
  }
}
