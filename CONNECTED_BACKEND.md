# NEON WORLD v0.5 — Connected backend

This source package is wired to the owner's live Supabase project:

- Supabase URL: `https://orxnuxqhsqedetspjfov.supabase.co`
- Client key: Supabase **publishable** key only (safe for a mobile client)
- LiveKit URL: `wss://neon-chat-61s1uh5j.livekit.cloud`
- LiveKit API key/secret are NOT in the app. They stay in Supabase Edge Function secrets.

## Production backend currently deployed

Authenticated Supabase Edge Functions:

- `find-match` — queue, 18+ validation, block checks, mutual gender filter, atomic partner reservation, active encounter reuse, leave/end encounter.
- `livekit-token` — creates a short-lived LiveKit token only for a participant of the encounter.
- `social` — friend requests, friend list, gifts and ratings.
- `admin` — report list and moderation actions for users flagged as admins.

Database includes profiles, private account state, blocks, reports, encounters, ratings, gifts, queue, friendships, requests and messages with RLS.

## Run on Android

A machine with Flutter + Android SDK is required to create an APK.

1. From this folder run `flutter create .` if `android/` and `ios/` do not exist.
2. Run `flutter pub get`.
3. Add Android permissions to `android/app/src/main/AndroidManifest.xml` above `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

4. Run `flutter run` on a connected Android phone, or build with `flutter build apk --release`.

## iPhone permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>NEON WORLD uses the camera for live video chat.</string>
<key>NSMicrophoneUsageDescription</key>
<string>NEON WORLD uses the microphone for live video chat.</string>
```

## Important test

For a real matching test, create two different accounts on two phones, complete both 18+ profiles, tap START VIDEO CHAT on both, and allow camera/microphone. One device should create the encounter and both should receive room-specific LiveKit tokens.

Do not put the LiveKit API secret or Supabase service-role key inside Flutter source code.
