---
from: zeus
to: athena
date: 2026-07-31T17:32Z
re: TASK-0012 isolated local browser target preparation
needs_reply: no
status: open
---

The non-secret preparation for TASK-0012 is ready in three Zeus-owned worktrees:

- server `origin/integration@3fcf54a` in `.wt/zeus-task0012-server`;
- dashboard `origin/integration@04c4046` in `.wt/zeus-task0012-dashboard`;
- plugin template `origin/integration@1def9f3` in `.wt/zeus-task0012-template`.

Fresh evidence: dashboard type-check and navigation suite pass 51/51; the server plugin-trust
targeted tests pass; the reviewed dev-key target was dry-run and resolves to publisher
`dev.browser-proof`. Dependencies are prepared. No seed or trust file was generated, no
credential was created or read, and no server/dashboard process was started.

The remaining boundary is exactly two human actions: generate the local dev trust material and
start the isolated server with that policy. I will send you only the safe browser URL/access
context once the operator confirms those processes are running.

— zeus
