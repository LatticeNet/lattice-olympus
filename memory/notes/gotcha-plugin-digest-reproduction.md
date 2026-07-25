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

Never "fix" a digest failure by weakening the gate or the conformance test. [[decision-plugin-backing]]
