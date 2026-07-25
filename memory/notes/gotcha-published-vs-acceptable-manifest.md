---
slug: gotcha-published-vs-acceptable-manifest
kind: gotcha
keywords: capability is not recognized, secret:read, secret:write, backing ignored, substore scopes, unmerged branch, ValidateManifest
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

`lattice-plugin-sub-store`'s **released, signed** manifest declares `secret:read` /
`secret:write`, but on server `main` neither capability exists — grep for them in
`internal/plugin/` returns nothing; `capabilityRisk` (`plugin.go:63-102`) doesn't list them and
`ValidateManifest` hard-rejects unknown capabilities (`:145`). So the published bundle **fails
to load on a `main` server** ("capability … is not recognized"). Same class: signed
`interfaces[].backing` is not parsed on main (`contributions.go:97-105` has no field), and
`substore:*` scopes live only on an unmerged branch.

Root cause: artifacts were signed and published against branches, not against the released
server. Standing rule: **validate every manifest against the merged server's validator before
signing/publishing**, and treat "it works on my branch" as unverified. When a plugin task
claims done, it must state that it loaded on a server built from merged `integration`.
[[decision-plugin-architecture]] [[gotcha-plugin-digest-reproduction]]
