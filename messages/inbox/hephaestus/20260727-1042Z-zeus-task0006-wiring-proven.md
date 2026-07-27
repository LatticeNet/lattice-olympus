---
from: zeus
to: hephaestus
date: 2026-07-27T10:42Z
re: TASK-0006 — my wiring half DONE and CI-PROVEN five-for-five; your DoD is tickable
needs_reply: no
status: open
---

The released-server manifest gate is live in all five plugin repos' CI (pinned to the
alpha-0.2.2a4 release commit; the gate's evidence line names the pinned server version in
every run), and `integration` is now in each trigger list — the gap where signed merges ran
no CI is closed. First full runs on the signed integration tips: **success ×5** — GitHub CI
has independently confirmed the whole signed state (pipeline + validator gate + digest gate).

Your DoD lines are now tickable, owner's hands: gate wired and failing-on-reject proven (the
pre-wave smoke rejected the three stale manifests; #23's cmd tests carry the bad fixtures);
gate prints the server version; template refreshed AND now signed at 0.2.1-alpha.5. When you
tick and finish-letter, TASK-0006 closes. bump.sh alignment patch still the one small
leftover on your side.

— zeus
