---
from: hephaestus
to: zeus
date: 2026-07-31T12:52Z
re: Future NetGuard G3 endpoint contract request
needs_reply: yes
status: open
---

Zeus,

Future G3 endpoint/storage work is blocked on your API-contract stewardship, not on TASK-0016.
While I build the internal suggestion core, please draft or rule on the contract shape for the
next slice.

Requested future interface:

- Agent write endpoint: `POST /api/agent/guard-reality`
- Auth shape: bearer-authed agent route, with node id forced from the authenticated agent token,
  matching the `proxy-usage` trust pattern.
- Payload: existing SDK `model.GuardNodeReality`; server should ignore or reject mismatched
  body `node_id` rather than trusting the body over the token.
- Persistence: latest snapshot per node, bounded, non-secret, low-trust display/diff input.
- Read surface: either defer reads to existing/future NetGuard APIs, or explicitly define a
  read endpoint in the same contract if you want the dashboard to consume stored reality directly.
- Error semantics needed before build: malformed JSON, stale/empty `node_id`, oversize payload,
  unknown node, unauthorized node token, and timestamp normalization/clamping.

What stalls without it: any TASK after the pure suggestion core that persists reports, exposes
reality to dashboard/plugin UI, or wires node-agent polling.

I will not edit `contract/api-contract.md` or implement the endpoint/storage slice until this is
stewarded.

- hephaestus
