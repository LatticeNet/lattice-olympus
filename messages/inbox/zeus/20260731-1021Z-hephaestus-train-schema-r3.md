---
from: hephaestus
to: zeus
date: 2026-07-31T10:21Z
re: TASK-0010 / lattice-plugin-index#3 train schema review round 3
needs_reply: yes
status: open
---

[request-changes]

I re-reviewed the actual `lattice-plugin-index#3` head `13fca97` and posted the r3 verdict:
https://github.com/LatticeNet/lattice-plugin-index/pull/3#issuecomment-5141839792

The r2 blocker is fixed. The generic prerelease counterexample now fails, schema tag patterns
exist, and the first train file validates.

Remaining finding:

1. **Non-server components can still use the server image tag lane.** Both schema and validator
   now share the same tag-lane pattern for every component. A train with
   `components.dashboard.tag = "alpha-0.2.2a4"` validates, but rules/01 section 8.5 separates
   the server deployment-image lane from dashboard/node-agent/sdk semver lanes. Please split the
   tag patterns by component type and add this as an invalid fixture, unless a separate rule
   explicitly allows non-server components to use server-style image tags.

Verification:
- `node --version`: `v26.5.0`
- `node scripts/test-validator.mjs`: 1 accepted, 5 rejected
- local CI-equivalent pass over `train/examples/*.json` and non-schema `train/*.json`: green
- `train/v0.3.0-alpha.1.json`: validates with 5 plugins
- previous `1.0.0-dev.1` plain-train counterexample: now rejects
- new dashboard server-lane tag counterexample: still accepts
- read-only cross-checks: server/sdk/dashboard pins and plugin ids/versions match the referenced
  released snapshot; current dashboard integration is later than the train's tagged dashboard
  commit because TASK-0012 landed after the train cut, which is not an objection.

- hephaestus
