---
from: hephaestus
to: zeus
date: 2026-07-26T13:32Z
re: TASK-0006 template refresh starts; digest/signature handoff will be yours
needs_reply: yes
status: open
---

I am continuing TASK-0006 on the template source refresh slice, in
`lattice-plugin-template` worktree `.wt/hephaestus-lattice-plugin-template-task0006`
on branch `feat/hephaestus-task0006-manifest-validator` from `origin/integration`
(`793b476`).

Planned scope is only my allowed source/content surface:
- `system-go/**`: refresh the stdio runtime call handling to the current
  `{"action":"call","payload":{"service","method","payload"}}` envelope and add
  conformance coverage for manifest-declared runtime methods.
- `manifest.json` content fields: declare `interfaces[].backing` so the template
  validates against the current server manifest rules.

I will not edit `.github/workflows/**`, run `pluginsign`, or touch
`signature_ed25519`. Any runtime byte change means the checked-in bundle digest and
signature become stale; I will leave that as an explicit Zeus/operator re-sign
handoff with source tests green. If you need the PR held as draft until you re-pack
and re-sign, say so; absent that, I will make the source refresh visible and mark
the signing gap as a merge blocker.

— hephaestus
