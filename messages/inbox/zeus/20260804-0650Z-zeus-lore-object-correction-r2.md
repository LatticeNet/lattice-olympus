---
from: zeus
to: zeus
date: 2026-08-04T06:50Z
re: row #10 r2 additive correction record
needs_reply: no
status: open
---

This is the durable additive correction for two malformed Olympus commit objects discovered while
TASK-0018 row #10 r1 was under review.

- `4496c52f55758368d5b43fa5842bcbf7dc625981` is the valid control: native Git parses all 9/9
  intended Lore trailers.
- `17b847b9619195ad0d3ac74b31012ef0cfb976b7` is already published. Its persisted TASK-0018
  review content remains evidence, but its
  message stores seven Lore keys after literal escape text and native Git parses 0. Its own claim
  that the commit used a valid contiguous trailer block is false.
- `45eefd4513d6e993276cc99f0178e8a283fa1677` is already embedded in the shared local `main`,
  followed by Hephaestus's valid TASK-0019 request `7710d06`. It stores eight escaped Lore keys and
  native Git parses 0. Athena's
  r1 co-sign remains historical input only: it neither passes the mandatory object check nor
  covers the materially expanded r2 rule. Changelog row #10 therefore remains unchecked.

**The original commits remain malformed; this record does not repair or validate either object.**
Rewriting, force-pushing, resetting away a shared-seat commit, or adding an empty descendant is not
authorized. The r2 draft instead separates code task-head replacement from append-only Olympus
correction and adds a scanner that has no SHA allowlist or automatic waiver.

Predicted and measured evidence:

- scanner harness: 10 cases, expected 10 pass, actual 10/10 pass, including injected helper failure
  returning loud exit 2;
- current `refs/remotes/origin/main..HEAD`: expected 2 commits / 1 violation / physical 7 /
  escaped 8 / parsed 7; actual matches and exits 1;
- no TASK-0018 recovery branch, merge, release, deployment, signing action or push occurred.

Fresh r2 affected-seat review is required. Even after two co-signs, the agent must stop for the
human principal's one-time exact-range ruling because the strict scanner must remain red for the
outbound malformed object.

— zeus
