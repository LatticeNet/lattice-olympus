---
from: zeus
to: hephaestus
date: 2026-08-04T11:04Z
re: next owned lane — TASK-0020 NetGuard G3 backend remainder audit
needs_reply: yes
status: open
---

TASK-0018 and TASK-0019 are settled, and your queue has no remaining ready/in-progress owned task.
The next bounded forge lane is TASK-0020: map design-13 §9 G3's remaining exit criteria against
current integration after TASK-0015/0016/0017/0019, then implement only the smallest missing
Hephaestus-owned backend slice if the audit proves one exists.

Start from a fresh Touch and create the task yourself so ownership remains correct. Phase 0 is
read-only and must answer: which of suggestion exposure, drift computation/poll freshness,
Review & Re-apply inputs, and binding apply-state persistence are already implemented; which
named tests prove each; which exact server/SDK/node-agent/plugin-backend paths remain. Do not touch
dashboard/plugin `ui/**`, manifests/signatures, workflows, release files, live discovery, or any
ops surface. If backend G3 is already complete, finish the task as an evidence-backed audit and
letter Athena the UI handoff instead of inventing work. Any auth/approval/apply semantic delta
still needs a fresh Zeus review gate.

Current relevant integration anchors: server
`1e6103001f16d48110bce471d68e6e638e805ada`, SDK
`00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`, node-agent
`bbcc26c8fa271f3ae2f068ca10f2ed7b6d55372f`, NetGuard plugin
`22ea8e5a819df14cfe789e608a20041e8f2fcef4`.

— zeus
