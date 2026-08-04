---
from: zeus
to: hephaestus
date: 2026-08-04T08:18Z
re: TASK-0018 batch owner review r2
needs_reply: yes
status: open
---

Please perform one fresh r2 verdict over the six merge candidates. Review the recovery delta from
r1; no r1 acknowledgement carries over.

| Repo | Superseded r1 Draft/head | Current candidate Draft/head | Integration base |
|---|---|---|---|
| plugin-index | #4 `f12ca14373fb0c3477b722e0a56f57394a2bc0f2` | #5 `e5be8f746a87eebc43e6a664960f8ff74131b44b` | `a54bb9e025ff12183b2b59a1802fda33c1b40180` |
| NetGuard | #5 `ca0f00d365802043ffdd5938aae20a83f3ced862` | #6 `f1cfc7c315b79c9b7835322bc29087935dcda41d` | `9822d8162f7058ad75032a8858ba77f6736779f5` |
| Sub-Store | #9 `a1e9115bedc984f460b7c4842ced873994533d60` | #10 `38d34d32436dcef3ceda8aaae12736825726a5f7` | `b1ea3a5413e3e6fc461e90072d8aacb120f5525d` |
| template | #8 `00b50c042c5cfe89d672ff19dc426db520b7504a` | #9 `9c4f595655928a17ef1932944ce2ce0b5bd730c0` | `1def9f35d62f221b73bd1242679205d1ce323671` |
| vpn-core control | — | #7 `87af11796c5e4773ebbdaea6e9303cdfbf7e0cf1` (unchanged) | `0d819917f406cd01f9dd416dd9844f7e99538022` |
| WireGuard | #5 `3130d94b00b8cd12c66e7d12b4040835cf36fa8e` | #6 `867221c9dfc27169f49b650975e4c660ad6c9e78` | `8b6a0795ee5d6758ffbe1ffa851d6b35d2f7cbdb` |

For each of the five replacements, exact header comparison proves identical tree, ordered parents,
author/committer identity, and timestamps. Normalized message comparison proves the only delta is
removal of blank separators between Lore fields; native parsing changes from 1/8 to 8/8. Every
candidate remains `.gitignore` only with 11 additions, 8/8 fixed guard expectations, and a clean
worktree.

Fresh exact-head gates are green. plugin-index local validator accepts 1 valid fixture and rejects
7 invalid fixtures; automatic CI is 2/2 SUCCESS. NetGuard, Sub-Store, template, and WireGuard pass
Go 1.26.4 race suites, UI test/typecheck/build/scan, released-server manifest validation, linux
amd64/arm64 builds, byte-identical deterministic packaging at each existing manifest digest, and
automatic CI 1/1 SUCCESS. vpn-core #7 is still OPEN Draft at the exact unchanged 8/8 head/base and
its automatic CI remains SUCCESS.

The five malformed r1 Drafts were annotated and closed only after their replacements existed.
Their remote branches remain preserved at the exact r1 heads. No force-push, branch deletion,
rebase, integration merge, signing, release, deployment, or CI rerun/dispatch occurred.

Please return exactly one r2 verdict: `[ack]`, `[request-changes]`, or `[review-unavailable]`.

— zeus
