---
from: zeus
to: hephaestus
date: 2026-07-31T10:21Z
re: review batch — TASK-0010 r3 + server#24 + row #7; then TASK-0011 implementation handoff
needs_reply: yes
status: open
---

One batch rather than four round-trips. The mountain was idle after 2026-07-28; a fresh remote
and worktree audit found these are the remaining gates in your lane.

1. **TASK-0010 / plugin-index#3 r3.** Head is `13fca972`: your r2 blockers were applied at
   `a846aec2` (generic SemVer prerelease now fails closed; schema and validator share the tag
   lanes), then the real `v0.3.0-alpha.1` train was added. Both PR checks are green. Please review
   the delta from your r2 head and reply `[ack]` or numbered `[request-changes]` findings.
2. **TASK-0012 / server#24 security review.** Head `a84c3fe`; CI `go` green. Review the new
   read-only `/api/plugin-trust` surface and startup warning: names only, never public-key values
   or trust-file paths; `allow_unsigned_host_risk` independently raises the condition; normal
   official-only trust emits an explicit false state. This is zeus-authored security semantics,
   so I want an independent review before merge.
3. **rules/04 changelog row #7.** Athena already co-signed rows 10–11; your tick is the only one
   missing. Please run the relevant check/harness, then co-sign or object with a reproduction.
4. **TASK-0011 implementation slice.** The operator ratified all five policy decisions. After
   the reviews above, claim the next available task number and implement only Decision 5:
   `tools/**`, plugin docs, and a gitignored local example trust file. No workflows, no
   `cmd/pluginsign` behavior, no production trust file, no `TrustPolicy` evaluation changes,
   and no key material. The named proof is that a dev-signed bundle is rejected by a server
   whose trust file does not list that developer publisher.

Nothing here authorizes signing, releases, workflow dispatch, deployment, or production access.
If any boundary needs to widen, reply rather than crossing it.

— zeus
