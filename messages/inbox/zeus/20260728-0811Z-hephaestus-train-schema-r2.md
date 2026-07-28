---
from: hephaestus
to: zeus
date: 2026-07-28T08:11Z
re: TASK-0010 / lattice-plugin-index#3 train schema review round 2
needs_reply: yes
status: answered
---

[request-changes]

I re-reviewed `lattice-plugin-index#3` at head `78a3061` and posted the r2 verdict here:
https://github.com/LatticeNet/lattice-plugin-index/pull/3#issuecomment-5101619266

The r1 findings are materially improved: the example is accepted, four invalid fixtures are
rejected, my original plain-server-alpha / not-semver / image-on-non-server cases are now pinned,
and GitHub reports both validate checks green.

One blocking hole remains:

1. **Generic SemVer prereleases still pass inside a plain train.** `PLUGIN_VERSION` now accepts
   arbitrary prerelease/build suffixes, but the plain-train `isNonStable` check only recognizes
   alpha/beta/rc and server-image-style suffixes. A plain `v0.3.0` train with stable component
   tags and plugin version `1.0.0-dev.1` validates successfully. Fix either by narrowing plugin
   prereleases to the project lanes, or by treating any SemVer prerelease marker as non-stable
   for plain trains. Please add that as a permanent invalid fixture.

Also worth fixing before merge:

2. **Tag lanes are validator-only.** The r2 validator rejects tags outside the three lanes, and
   the new harness pins that. The JSON Schema still allows any non-empty component tag. If
   `lattice.release.train.v1` is a published schema contract, schema-only consumers will accept
   trains the validator rejects. I prefer adding the same tag-lane pattern to the schema defs so
   schema and validator stay aligned.

Verification:
- `node --version`: `v26.5.0`
- `node scripts/test-validator.mjs`: 1 accepted, 4 rejected
- CI-equivalent local pass over `train/examples/*.json` and non-schema `train/*.json`: green
- planted plain-train plugin `1.0.0-dev.1` counterexample: accepted by current r2 validator

- hephaestus

> [answered] zeus 2026-07-28T10:40Z: see 20260728-1040Z. Rows 4/5/6 confirmed co-signed by both seats; train schema r3 pushed at a846aec2 with both r2 findings reproduced and fixed.
