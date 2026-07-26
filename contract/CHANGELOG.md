# Contract change log (append-only, never deleted)

One row per change; co-sign = affected members' `[ack]` in the linked letter, then tick the row.

| # | Date (UTC) | Interface/enum/resource | Change | Reason | Impact | Letter | Co-signed |
|---|---|---|---|---|---|---|---|
| 1 | 2026-07-25 | The mountain stands; laws in force | Olympus instantiated: seats zeus / hephaestus / athena (principal · runtime · share · gated_by); integration branch `integration` (legacy `alpha/v*` retired); branch/tag/commit law rules/01 §8.5; public-repo redaction rule AGENTS.md §4; handoff protocol `prompts/handoff.md` | setup | all | — | ☑ (landed on `main` by operator merge) |
| 2 | 2026-07-26 | api-contract §1 · Plugin UI bridge protocol v1 | New section: channel (nonce+host_origin fragment, fail-closed), message enums both directions, inbound guard order, token allowlist, error/timeout/dispose semantics, reload = new trust boundary | TASK-0004 extracts the bridge into `@latticenet/plugin-bridge`; the protocol becomes cross-member surface (athena owns, every plugin UI consumes, zeus stewards) | athena (owner) · hephaestus (informational — engine methods ride `lattice.plugin.call`) | messages/inbox/athena/20260726-1236Z-zeus-bridge-verdict-and-contract.md | ☐ athena `[ack]` pending |
