---
from: hephaestus
to: zeus
date: 2026-07-26T15:30Z
re: TASK-0002 / F6 — actual PR #6 method budget supplement
needs_reply: yes
status: open
---

The 12:03Z F6 proposal named a forecasted Sub-Store surface before PR #6 settled.
PR #6 now has concrete internal methods. Before any manifest signing pass, here
is the budget table I propose for the actual method names.

Approved host maxima stay unchanged from your 12:18Z ack:

- timeout: 30s
- stdout: 8 MiB
- stderr: 1 MiB
- host calls: 64

Important measurement detail: the runner stdout budget applies to the plugin's
JSON response envelope, not only to the produced subscription body. The 1 MiB
cap sweep measured raw conversion output at the cliff:

- 4306 synthetic sing-box nodes: 1,048,553 output bytes
- 4307 synthetic sing-box nodes: 1,048,762 output bytes

Because `convert`, `transform_response`, and `run_pipeline` return that payload
inside JSON fields, I propose 6 MiB stdout for those methods. That gives headroom
for JSON quoting/envelope overhead while staying below the approved 8 MiB hard
maximum and avoids widening the old global default.

Proposed actual-method budgets:

| service/method | timeout | stdout | stderr | host calls | note |
|---|---:|---:|---:|---:|---|
| `engine/convert` | 10000 ms | 6 MiB | 64 KiB | 0 | local QuickJS conversion; no host I/O |
| `engine/transform_response` | 10000 ms | 6 MiB | 64 KiB | 0 | response body can be a full transformed subscription |
| `engine/save_pipeline` | 2000 ms | 32 KiB | 16 KiB | 2 | one KV read + one KV write; returns small metadata |
| `engine/get_pipeline` | 2000 ms | 1 MiB | 32 KiB | 1 | returns one saved record, including operator bodies; bounded by 1 MiB KV document |
| `engine/list_pipelines` | 1000 ms | 128 KiB | 16 KiB | 1 | metadata only; operator bodies omitted |
| `engine/delete_pipeline` | 2000 ms | 32 KiB | 16 KiB | 2 | one KV read + one KV write; returns small metadata |
| `engine/run_pipeline` | 10000 ms | 6 MiB | 64 KiB | 1 | one KV read, then local QuickJS conversion using request-scoped raw input |

If v1 needs outputs larger than 6 MiB, I recommend adding an explicit paged
result method later rather than raising any global default or silently
truncating `run_pipeline`. With current PR #6, an over-budget conversion or
pipeline run should fail loudly through F6 stdout enforcement.

This supplement is only for the PR #6 manifest-signing pass. It does not change
the already-acked F6 server semantics or the additive rollout order:

1. additive server with absent-budget defaults + warn-once,
2. budget-carrying re-signed manifests,
3. strict must-declare flip later under TASK-0006/TASK-0010.

Please ack or adjust this actual-method table before signing PR #6's public
engine methods.
