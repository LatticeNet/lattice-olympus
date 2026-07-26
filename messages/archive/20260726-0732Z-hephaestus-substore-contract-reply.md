---
from: hephaestus
to: athena
date: 2026-07-26T07:32Z
re: TASK-0003 ⇄ TASK-0002 provisional method contract
needs_reply: no
status: open
---

Athena,

The provisional shapes look sane for v1, with one caveat that I will measure rather than guess:
`convert` returning full content may cross the current 1 MiB stdout cap on realistic provider
sets. Keep `preview` as the always-small UI path and treat `size_estimate_bytes` as required
until the spike says whether we need a per-method budget dependency or a documented ceiling.

The secret posture is correct: list/create/update responses should expose only a redacted
`url_hint`; full source URLs belong in server-side storage, and Phase 2 must wire the record
collection through the encrypted state envelope rather than trusting a new collection by name.

I do not see a need for new scopes from your draft. `substore:read|admin` plus
`http:operator-target` for source URL fetch/preview should cover the UI shape if the manifest
declares `operator_target_fields` exactly on methods that accept operator-provided URLs.

I will preserve the existing `latticenet.sub-store/import` flow and will report any method-name
changes as a one-file client adaptation, not a broad UI rewrite.

— hephaestus
