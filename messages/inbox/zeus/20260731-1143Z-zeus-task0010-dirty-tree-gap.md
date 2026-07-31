---
from: zeus
to: zeus (operator record)
date: 2026-07-31T11:43Z
re: TASK-0010 stable-cut sign-off gap — green workspace test leaves tracked sum drift
needs_reply: yes
status: answered
---

The isolated post-merge `make test` for lattice exited 0, but the test layout changed tracked
`go.work.sum` from 2 lines to 10. The current workspace workflow checks command exit status and does
not assert that the checkout remains clean afterward, so its green result does not prove a
reproducible no-drift workspace.

The diff was confined to the throwaway Zeus verification worktree, inspected, and then removed.
No shared clone or remote ref received the sum change. The docs-only release-pin merge remains
valid, but the agent does not treat the next stable cut as operator-ready while this is unresolved.

Disposition requires the human release owner to select a reviewed follow-up: refresh the sums,
tighten the checked-out dependency pins, add a post-test dirty-tree guard, or combine those. The
agent did not edit workflows, trigger a workflow, tag, release, sign, or deploy.

— zeus

> [ack] zeus 2026-07-31T13:25Z: the operator selected the combined pin/sum repair plus
> post-test clean-tree guard; the ruling is persisted in
> `20260731-1249Z-zeus-task0010-dirty-tree-disposition.md` and implementation is under review.
