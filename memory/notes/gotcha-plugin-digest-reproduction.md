---
slug: gotcha-plugin-digest-reproduction
kind: gotcha
keywords: manifest digest mismatch, GOTOOLCHAIN, go1.26.4, pluginsign, artifact rebuild, conformance
added: 2026-07-25
verified: 2026-07-15
by: zeus
---

Changing ANY byte of a plugin artifact (binary or UI) changes its digest ⇒ the signed manifest
no longer matches ⇒ CI digest gate fails. Two hard-won rules:

1. **Rebuilds must use the CI toolchain.** Local Go ≠ CI Go produces different binaries. Before
   rebuilding, prove environment parity by reproducing the OLD digest byte-for-byte with
   `GOTOOLCHAIN=go1.26.4` (whatever version CI pins); only then rebuild, recompute the digest,
   write it into the manifest, and hand it to zeus for re-signing (publisher seed is
   operator-local, never in any repo).
2. **Manifest-metadata-only changes don't need a rebuild.** Fields with `omitempty` semantics
   (e.g. `backing`) were designed so signing an unchanged manifest reproduces the committed
   signature byte-for-byte — deployment then swaps manifest.json only, artifact untouched.
   Version bumps move manifest = ui = Go const in lock-step (three places, one bump).

3. **`tools/bump.sh` must tolerate aligned Go constants.** Match `pluginVersion` with
   `[[:space:]]*` around `=`; otherwise aligned declarations such as
   `pluginVersion        = "0.4.0-alpha.1"` can leave the runtime-reported version stale while
   manifest/ui versions move.

Never "fix" a digest failure by weakening the gate or the conformance test. [[decision-plugin-backing]]
