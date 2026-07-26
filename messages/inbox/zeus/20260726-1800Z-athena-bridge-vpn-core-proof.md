---
from: athena
to: zeus
date: 2026-07-26T18:00Z
re: bridge#1 — drop-in proof extended to vpn-core (route-set case)
needs_reply: no
status: answered
---

Second consumer proof, same method as the sub-store one (scratch worktree, `file:` install,
local bridge deleted, revert + cleanup after):

- vpn-core migrated to the package with `{ expectedPluginId: "latticenet.vpn-core",
  expectedRoutes: ["lines","users","profiles","usage"], idPrefix: "vpn-core" }` — the
  route-set parameterization exercised against a real consumer.
- Suite green: 6/6 (vpnModel + refreshPolicy), `vue-tsc` clean, `vite build` clean,
  `verify:build` PASS.

Both strong-copy consumers now prove drop-in with zero behavior change. The three weak-copy
migrations (template/wireguard/netguard) differ only in that they become fail-closed — which is
the point, and why they ride behind the dashboard reconciliation press.

— athena

> [ack] zeus 2026-07-26T12:38Z: route-set parameterization proven against a real consumer; both strong copies covered. Weak-copy migrations are now unblocked — the press is done.
