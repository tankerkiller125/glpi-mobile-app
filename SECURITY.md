# Security policy

## Reporting a vulnerability

Please **do not** open a public issue for a security problem.

Use GitHub's private vulnerability reporting on this repository
(*Security → Report a vulnerability*), or contact the maintainer privately
through their GitHub profile. Expect an acknowledgement within a week; this is a
spare-time project, not a vendor with an on-call rota, and the response time
reflects that.

When reporting, please include the GLPI version, the plugin version, whether the
issue is in the app or the [`glpimobile`](https://github.com/bijstaan/glpi-mobile-plugin)
plugin, and enough detail to reproduce it.

## Supported versions

Only the latest release is supported. There are no backports.

## Where the sensitive parts live

If you are reviewing this project, these are the areas worth your time:

| Area | What matters |
| --- | --- |
| `lib/core/auth/` | Pairing, device credentials, token refresh, and what happens when a refresh fails |
| `lib/core/api/hl_client.dart` | Token challenge detection, error classification |
| `lib/core/sync/` | Outbox ordering, idempotency markers, entity pinning of queued writes |
| Secure storage | Tokens and device credentials are held in `flutter_secure_storage` (Keystore / Keychain) |
| The plugin | The OAuth client secret, the pairing broker and the unauthenticated endpoints all live server-side — see that repository |

## Design decisions you should know about

- **The app is a secretless public client.** It holds no OAuth client id or
  secret; the plugin brokers tokens server-side. GLPI 11 always issues a client
  secret and requires it at `/token`, so a secret embedded in a distributed APK
  was never an acceptable option.
- **The app does not hold the GLPI refresh token.** It holds a non-rotating
  device credential; the rotating refresh token is stored encrypted on the
  server against that device. This trades one risk (a lost response permanently
  locking a technician out) for another (a long-lived credential on the device),
  deliberately, and admins can revoke any device from the GLPI UI.
- **Some plugin endpoints are unauthenticated by design** — pairing and refresh,
  because the pairing code or device credential *is* the credential. Pairing
  codes are single-use and expire in 120 seconds.
- **Release builds are HTTPS-only.** Cleartext is permitted only in Android
  debug builds and for local networking on iOS.

## Known gaps

No independent security review has been performed on this project. It was
written largely by an AI assistant under human direction — see
[AI-DISCLOSURE.md](AI-DISCLOSURE.md) — and a review of the auth and sync paths by
someone with no stake in it would be genuinely welcome.
