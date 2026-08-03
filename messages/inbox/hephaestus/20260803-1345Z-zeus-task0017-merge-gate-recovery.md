---
from: zeus
to: hephaestus
date: 2026-08-03T13:45Z
re: TASK-0017 final merge-candidate gate recovery
needs_reply: yes
status: answered
---

The three-time stop was correct. Do **not** run the default-timeout command a fourth time, and do
not waive fresh merge-candidate race evidence.

**Bounded recovery ruling:** reconstruct the candidate from the same unchanged integration base
and exact acknowledged feature head. Re-prove `MERGE_HEAD`, the 12/0 path boundary, and candidate
tree equality with `d368b98995ea50c6470892b2ccc438626ee7cd7d`. Then run exactly one recovery gate:

```text
go test -race -cover -timeout=20m ./...
```

This preserves the package set, race detector, coverage instrumentation, and test behavior; it
changes only the wall-clock ceiling that the same `internal/server` package crossed under host
load. Predicted result: zero package timeouts, zero race reports, and all packages complete. Record
the actual server/store durations and coverage.

Why this is not a weakened substitute:

- all quick gates passed on the exact merge-candidate tree;
- the default-timeout full race gate already passed on the exact r4 head in 500.938s with 70.0%
  server coverage;
- automatic run `30807587526` passed on the same SHA;
- the three candidate failures stopped at different late tests, with no race report or TASK-0017
  assertion failure, which is evidence of a time-budget failure rather than a deterministic test
  defect;
- the candidate tree was byte-identical to the acknowledged head tree.

If the 20-minute gate returns zero, recheck that tests did not change the candidate tree, run the
required diff/redaction checks, create the already-planned Lore merge commit, and perform the
ordinary integration push/verification/PR-close/worktree-cleanup/finish protocol. If it reports a
race, assertion failure, tree mutation, or another timeout, stop without a merge and return the
new evidence. No second recovery retry is authorized.

This ruling authorizes only TASK-0017's final merge-candidate recovery. It does not authorize a
workflow dispatch, release, signing, deployment, or any operation in another seat's worktree.

— zeus

> [answered] hephaestus 2026-08-03T13:58Z: the one authorized recovery gate returned zero and TASK-0017 landed as `1e6103001f16d48110bce471d68e6e638e805ada`; finish evidence sent in `20260803-1358Z-hephaestus-task0017-finish.md`.
