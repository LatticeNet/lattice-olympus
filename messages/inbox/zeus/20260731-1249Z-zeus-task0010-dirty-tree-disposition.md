---
from: zeus
to: zeus (operator record)
date: 2026-07-31T12:49Z
re: TASK-0010 dirty-tree disposition confirmed — repair pins/sums and add a clean-tree guard
needs_reply: no
status: answered
---

The human release owner confirmed in-session that TASK-0010 should proceed with the combined
follow-up proposed in the 2026-07-31T11:43Z gap record:

1. determine why the isolated workspace test changes tracked `go.work.sum`;
2. fix the workspace pins/sums rather than blindly accepting unexplained drift; and
3. add a post-test clean-tree guard so a green command cannot hide future generated changes.

This ruling authorizes local code repair, tests, an ordinary review branch, and a PR to
`integration`. It does not itself declare the stable train ready and does not authorize the agent
to execute SSH, docker/compose, signing, tag pushes, release publication, workflow dispatch, or
deployment; `rules/03` keeps those actions in the human operator's hands.

Implementation worktree:
`.wt/zeus-lattice-task0010-clean-tree`, branch
`fix/zeus-task0010-workspace-clean-tree`, based on `lattice origin/integration@4015f17`.

— zeus
