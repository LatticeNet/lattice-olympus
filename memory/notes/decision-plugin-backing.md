---
slug: decision-plugin-backing
kind: decision
keywords: backing runtime core, façade plugin, conformance test, require-declared-backing, option C, §9.1 §9.3 §9.4
added: 2026-07-25
verified: 2026-07-15
by: zeus
---

2026-07-14 ruling (user-approved "option C"): the plugin contract is made honest by a
manifest-**signed** per-service field `backing: runtime|core`. `core` requires system type
(trusted signature); a runtime service shadowed by a core provider fails closed; v2 manifests
without a declared backing are rejected at load. Every repo carries a conformance test that
probes each `manifest.interfaces[].methods[]`: runtime-backed must answer from the artifact,
core-backed must NOT. Disable is honest: the RPC bus checks owner lifecycle per dispatch.
Companion protocols shipped: §9.3 plan→approve→execute with typed Approval binding columns
(approval binds plugin id/version/digest/service/method/request-hash/targets; execute
re-validates every column against live state, authorizes with the approver's scopes), and
§9.4 encrypted secret storage (system-only, no HTTP handler, never in rbac.KnownScopes).
Deployment order for two-sided breaking changes is staged: additive server first → data/plugin
migration → strict server. [[gotcha-plugin-digest-reproduction]] [[gotcha-state-encryption-envelope]]
