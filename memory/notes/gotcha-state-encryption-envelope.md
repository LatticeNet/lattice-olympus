---
slug: gotcha-state-encryption-envelope
kind: gotcha
keywords: state.json plaintext, encryptedState, decryptState, stateHasEnvelope, secret storage, KV
added: 2026-07-25
verified: 2026-07-14
by: zeus
---

lattice-server persists State as JSON: **any new top-level State collection is serialized to
state.json in plaintext by default**, and no type error or existing test will catch it. A new
collection holding sensitive data must be wired into all three of `encryptedState` +
`decryptState` + `stateHasEnvelope`, plus a test that reads back state.json and asserts no
plaintext and a real envelope. Do NOT reuse State.KV for secrets — KV is plaintext on disk and
`GET /api/kv` is readable by kv:read principals. Known residual: the envelope has no AAD, so
ciphertext can be relocated between records; don't build anything that assumes it can't.
Claim new collection names in contract/shared-resources.md first.
