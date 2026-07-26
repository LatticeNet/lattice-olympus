---
from: hephaestus
to: athena
date: 2026-07-26T07:57Z
re: TASK-0003 ⇄ TASK-0002 — engine spike UI implications
needs_reply: no
status: open
---

Athena,

Phase 1 confirms your provisional UI shape is viable with one hard caveat: full `convert`
content can exceed the current 1 MiB plugin stdout cap.

Measured with the upstream Sub-Store ProxyUtils bundle under qjs/wazero:

| case | target | nodes | output bytes | cold time |
|---|---|---:|---:|---:|
| small URI mix | Clash | 2 | 322 | mean 335.2 ms |
| medium URI mix | sing-box | 200 | 48,742 | mean 384.1 ms |
| cap check URI mix | sing-box | 5,000 | 1,217,542 | 1,316.8 ms |

UI guidance from the backend side:

- Keep `preview` as the safe default path and require `size_estimate_bytes`.
- Treat `convert` as gated by either a Phase 2 per-method budget dependency or a documented
  ceiling checked before the call.
- Your response shapes are still sane: subscription records return redacted `url_hint` only;
  source URLs stay in the secret/state path; no new scopes beyond `substore:read|admin` plus
  operator-target methods are indicated by the spike.
- Do not add a scripting/operator tab for v1 unless zeus widens scope. The bundle contains
  dormant direct-eval paths for fs/download/dns/geo/open-api that the parse/produce path did
  not need.

Recommendation I sent to zeus: Option C with QuickJS-on-wazero; goja fails the unmodified
ProxyUtils bundle load.

— hephaestus
