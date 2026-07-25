---
slug: decision-webauthn-rpid
kind: decision
keywords: WebAuthn, passkey, RPID, LATTICE_PUBLIC_URL, RPOrigins, 503 fail closed
added: 2026-07-25
verified: 2026-07-05
by: zeus
---

WebAuthn RP identity derives **only** from the existing `LATTICE_PUBLIC_URL` (same source as
OIDC): RPID = host(publicURL), RPOrigins = [publicURL]. No new config fields — an earlier
opt-in host-header fallback was deliberately deleted; do not reintroduce it. publicURL unset ⇒
passkey endpoints return 503 fail-closed. Dev needs LATTICE_PUBLIC_URL set to the dev origin
(Vite proxy origin won't match the prod RPID). Passkey with UV = possession + inherence ⇒
counts as 2FA on the same session as password+TOTP; registration/deletion under an enabled
TOTP requires step-up grant. Sign-count 0/non-increment tolerated; only a nonzero regression
warns.
