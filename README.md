# World Live Chat MVP

Flutter starter app for a global random 1:1 live-video chat product.

## Included
- Home / matchmaking filters
- 18+ confirmation gate for the MVP
- Video-chat UI with mic, camera, skip, report and block controls
- LiveKit client service
- Node token server for LiveKit
- Supabase starter schema for profiles, reports and blocks

## Run the Flutter app
1. Install Flutter.
2. Create platform folders if needed: `flutter create .`
3. Run `flutter pub get`.
4. Run `flutter run`.

## Connect real video
1. Create a LiveKit Cloud project (or self-host LiveKit).
2. Run the token server in `/server` with `LIVEKIT_API_KEY` and `LIVEKIT_API_SECRET` set on the SERVER only.
3. Build a matchmaking API that pairs two waiting users into the same random `roomName`.
4. Request a short-lived token from `/token` and call `LiveKitService.connect(url: ..., token: ...)`.
5. Render LiveKit participant video tracks in `VideoChatScreen`.

Never place `LIVEKIT_API_SECRET` in the Flutter/mobile app.

## Supabase
Run `supabase.sql`, then add authentication and RLS policies before production use.

## Mobile permissions
Android and iOS require camera and microphone permissions. Follow the current LiveKit Flutter setup guide for each platform.

## Production safety checklist
This type of app needs stronger protections before public launch: verified age policy appropriate to each market, moderation, report/block enforcement, rate limits, ban evasion controls, abuse detection, privacy policy, terms, data-retention rules, and human review/escalation. Do not ship the demo report/block buttons as-is.

## Recommended next build steps
1. Email/phone/OAuth sign-in.
2. Matchmaking queue stored server-side.
3. Real LiveKit participant rendering.
4. Server-enforced report/block/ban system.
5. Moderation dashboard.
6. Localization.
7. App Store / Google Play compliance pass.
