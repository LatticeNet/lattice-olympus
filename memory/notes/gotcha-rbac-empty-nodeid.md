---
slug: gotcha-rbac-empty-nodeid
kind: gotcha
keywords: rbac.Allows, empty nodeID, ServerAllowlist, node-scoped plugin interfaces, RPCHandler principal
added: 2026-07-25
verified: 2026-07-09
by: zeus
---

`rbac.Allows(principal, scope, "")` returns **true** for restricted principals carrying a
ServerAllowlist when nodeID is empty, and `plugin.RPCHandler`'s signature carries no principal,
so in-core handlers cannot re-filter per node. Consequence: a plugin manifest that declares
node-scoped interfaces would let a restricted PAT read whole-fleet state through the gateway.
Standing rule until fixed: **official plugins declare no node-scoped interfaces**; node-filtered
reads stay on first-class `/api/<domain>/*` endpoints where filtering is correct. The fix
precondition is adding a principal (or authz callback) to RPCHandler — that change is
auth-semantics and needs zeus's ack (rules/01 §4). Recorded in design-13 §10.8.
