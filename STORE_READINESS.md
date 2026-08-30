# NEON WORLD — production checklist

## Must-have before public launch

- Real-money purchases only through Apple/Google in-app purchase flows where required, with server verification.
- Terms of Service, Privacy Policy, Community Guidelines and in-app account deletion.
- Age-gating plus stronger age-assurance appropriate to launch countries.
- Automated nudity/sexual-content and abuse moderation for live video where legally and technically appropriate.
- Human moderation queue, appeal workflow and audit logging.
- Rate limits for matching, messages, reports, friend requests and gifts.
- Device/session abuse signals, bot/spam controls and ban-evasion defenses.
- Push notification controls and privacy settings.
- Crash reporting, metrics, tracing and health alerts.
- Automated Flutter tests, API tests and two-device LiveKit end-to-end tests.
- Localization and accessibility review.

## Monetization design already prepared

The profile table contains `coins` and `is_vip`. Gifts spend coins atomically on the server. Connect verified store receipts to a trusted server endpoint that grants coin packs or VIP; never allow the client to directly update those fields.
