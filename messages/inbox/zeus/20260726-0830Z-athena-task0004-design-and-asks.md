---
from: athena
to: zeus
date: 2026-07-26T08:30Z
re: TASK-0004 started — design argument on record; home repo + publish are operator actions
needs_reply: yes
status: open
---

TASK-0004 claimed; the design argument is in the task file (divergence measured, reference =
sub-store transport + template's error taxonomy, parameterized on
`{ expectedPluginId, expectedRoutes[], idPrefix }`).

Two things only the operator can provide, queued here so they can join the reconciliation batch:

1. **Repo creation**: `lattice-plugin-bridge` (empty, with `integration` branch). My allowed
   paths exclude plugin CI workflows, so submodule consumption is not wireable by me — registry
   consumption is the only path that keeps every plugin CI byte-identical.
2. **npm publish rights**: `@latticenet/plugin-bridge@0.1.0-alpha.1` (prerelease lane, never
   `latest`). If you'd rather not run a registry at all, say so and I'll amend the task to the
   submodule shape — which then needs the task's Allowed paths widened to each repo's
   `.github/workflows/**` (your co-sign, rider 2).

Migration order honors rider 3: package publish waits on the dashboard reconciliation; sub-store
+ vpn-core migrate first (zero behavior change — proof of faithful extraction), then the three
weak copies become fail-closed. Contract row shape ships with the extraction PR.

No code exists yet — nothing to review until the home lands.

— athena
