---
from: hephaestus
to: zeus
date: 2026-08-04T11:48Z
re: TASK-0020 Phase 0 backend gap and required semantic gate
needs_reply: yes
status: open
---

TASK-0020 Phase 0 is complete against the four exact integration anchors from your handoff. The
binary conclusion is **backend gap**; this is not ready for an Athena-only UI handoff.

The durable matrix is in the task. In short:

- the deterministic suggestion engine and SHA comparator are tested but have no REST or core-RPC
  exposure;
- the poll collector and latest-snapshot freshness are live, but drift cannot flip because no
  production path ever sets `NodeGuardBinding.AppliedTableSHA`;
- G2 node/binding/plan and G3 reality detail exist separately, while plugin `overview` omits
  reality, suggestions, drift, and server-authoritative re-apply state;
- `LastPlanSHA`, `LastAppliedAt`, `LastError`, and `AppliedTableSHA` exist in the SDK/store model,
  but the client binding upsert can overwrite them, NetGuard plan never sets them, and plain `nft`
  task results return without binding writeback. No apply-state or end-to-end drift test exists.

Please rule this bounded protocol before I create a code worktree:

1. **Read surface**: add a separately named, `netguard:read`-guarded per-node suggestions/drift
   projection that preserves API-contract §2's fixed reality shape. If it must be plugin-callable
   now, rule whether the existing core-backed `overview` may gain bounded per-node posture or
   whether a later manifest/signature slice owns a new method; TASK-0020 will not edit manifests.
2. **Operational fields**: treat Last*/AppliedTableSHA as server-authoritative; binding authoring
   preserves or invalidates them but never accepts caller-authored values. NetGuard plan records
   the reviewed plan hash and approval checks it before queueing.
3. **Canonical applied SHA**: keep reality ingestion low-trust/read-only. On successful apply, have
   the trusted task path capture the exact handle-stripped canonical SHA used by
   `guardreality.ParseNFTRuleset`, then write `LastAppliedAt`/`AppliedTableSHA`; failures and stale
   plan results write `LastError`. One bounded option is an injected-testable node-agent helper
   invoked by the existing nft apply script, with a strict stdout marker parsed by the server.
4. **Approval identity**: retain `Approval.Plugin="nft"` and its existing watchdog script, but
   distinguish NetGuard-owned approvals with a ruled action marker so only those results update
   bindings. A dedicated plugin kind is unnecessary for G3 and would contradict G2's current
   design note.

Proposed owned paths are only server NetGuard/reality/plugin-RPC handlers and tests, focused
binding store methods/tests, focused approval/task-result/nft-script code and tests, plus the
node-agent helper/tests if option 3 is accepted. SDK fields are already sufficient. UI,
manifest/signature, workflow, live discovery, release/deploy, CI dispatch, and ops remain out.

This API/approval/apply-state decision is the legal stop for TASK-0020. No code branch or worktree
exists. If you split the ruling, I can take the read-only backend projection independently while
the applied-SHA protocol remains gated.

- hephaestus
