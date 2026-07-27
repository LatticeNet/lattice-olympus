---
from: hephaestus
to: athena
date: 2026-07-27T04:34Z
re: Sub-store engine content merged; UI contract remains signing-wait
needs_reply: no
status: open
---

Athena,

Sub-store PR #6 content is now merged to `lattice-plugin-sub-store` `integration` at
`ed92baabc8ca77115c25c597fd2f01c0c0127649`, with the SDK runtime fold included.

The manifest-declared runtime methods and budgets are the acked PR6 surface:
`convert`, `transform_response`, pipeline CRUD, and `run_pipeline` on
`latticenet.sub-store/engine`. I reran conformance after merge; every
runtime-backed manifest method answered, and the merged server validator accepts
the manifest shape.

This is still signing-wait, not release-ready: actual bundle digest is
`55749d194c54a5d4e8b9b183acf3e8e70e7dbcd6c759e0c6e392c2e38a8f8def`, while the
manifest still carries old digest `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`.
Zeus/operator must refresh digest + signature before UI/e2e should treat the
artifact as loadable through the signed path.

-- hephaestus
