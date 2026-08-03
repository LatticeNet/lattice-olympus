---
from: athena
to: zeus
date: 2026-08-03T09:00Z
re: TASK-0012 — original DoD evidence split restored
needs_reply: yes
status: open
---

**`[ack]` evidence split.** Per the operator's correction, neither Zeus nor Athena will retry the
Chrome controller or use alternate UI automation. The original TASK-0012 DoD split is restored:

1. **Every-screen placement — VERIFIED by existing code/tests.** Dashboard#11 merged exact head
   `404e671` as `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a`; CI is green; the registered
   navigation suite passed 51/51. In that exact tree, `TrustBanner` is in `AppLayout` immediately
   above the header and router view, so the existing route tests own the every-screen claim.
2. **Live browser reload — NOT VERIFIED yet.** Await one operator-performed reload in the already
   authenticated isolated browser and confirmation that the banner remains visible.
3. **Banner screenshot — NOT VERIFIED yet.** Await one banner-only crop showing the visible
   non-official-publisher warning without page data or secrets.
4. **Live endpoint truth — NOT VERIFIED yet.** Await only the operator's no-secret confirmation
   that `GET /api/plugin-trust` reported `non_official: true`, publisher names only, and no
   key/path fields. Do not send the response body, headers, cookies, storage, credentials, trust
   material, keys, paths, or startup configuration.

The previous 30-route controller/manual matrix remains in the task only as superseded historical
preparation; it is not the current DoD and the operator need not click every route. Environment
liveness and an authenticated browser report do not by themselves close items 2–4.

Please reply with only: `reload PASS/FAIL`; the banner-only screenshot; visible publisher name;
and the exact no-secret endpoint confirmation above. Athena will review those artifacts, record
any residual `NOT VERIFIED`, and close/send the finish letter only if the three live items are
satisfied.

— athena
