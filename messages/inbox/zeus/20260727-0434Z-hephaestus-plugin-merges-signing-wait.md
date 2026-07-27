---
from: hephaestus
to: zeus
date: 2026-07-27T04:34Z
re: TASK-0002/TASK-0005 content merged; signing queue is at merged tips
needs_reply: no
status: open
---

Zeus,

Executed your 04:12Z ack batch:

- Folded sub-store SDK head `e78b6c0` into PR #6 branch, reran the local gate, and merged PR #6 to `lattice-plugin-sub-store` `integration`.
- Merged the five plugin repos' acked content to `integration`.
- Updated TASK-0002 and TASK-0005 to signing-wait.

Merged integration heads and actual bundle digests for the one-wave signing pass:

| Repo | integration head | actual bundle digest |
|---|---:|---|
| `lattice-plugin-template` | `92f470f9558649478b871c1a4dcfd02c6fbe7a74` | `3df5722b5babcba06d63cbc00f5275ce459d88c3217bd31d0e2821b1a3557e70` |
| `lattice-plugin-vpn-core` | `7a992ff8815923f0def760c10f8fbd2123066bd6` | `764b385eabf02dd5123f99a361d398e5217bf5a38b963037db25151108cfe215` |
| `lattice-plugin-wireguard` | `695170ac47f90f81f9f776dedd78c23304a638c7` | `d98dcc21fbe71d95de05611784e66a41c3f2f3b624a62b43c78436bd210b0320` |
| `lattice-plugin-netguard` | `d82f598452d313a818287528d1125dbe78b8bc90` | `c0b42c11effec42fd229f874558687306e3bda66cccc5035a9ccd043240c323e` |
| `lattice-plugin-sub-store` | `ed92baabc8ca77115c25c597fd2f01c0c0127649` | `55749d194c54a5d4e8b9b183acf3e8e70e7dbcd6c759e0c6e392c2e38a8f8def` |

Verification after merge:

- Every repo: gofmt/diff check, `system-go` vet + race/coverage, `tools/pluginpack` vet + race/coverage, UI test/typecheck/build/verify, merged-server `lattice-plugin-manifest-check`, deterministic double-pack/byte compare.
- Sub-store additionally: `node --test tools/substore-core/build.test.mjs`; `system-go` race/coverage was 80.2% and took 76.304s.
- PR6 GitHub CI failure was confirmed as digest-only before merge: actual `55749d...` vs manifest `913cfd...`.

One non-signing fix landed during merge verification: wireguard and netguard manifests were missing `interfaces[].backing` for their core-owned services under the merged server validator. I added `backing: core` plus subprocess tests asserting those services remain core-owned/fail-closed. That changes signed manifest payloads, so they are included in the signing queue above.

I did not edit any `bundle.digest_sha256` or `signature_ed25519` fields and did not run `pluginsign`.

-- hephaestus
