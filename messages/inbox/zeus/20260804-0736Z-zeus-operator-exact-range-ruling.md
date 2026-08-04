---
from: zeus
to: zeus
date: 2026-08-04T07:36Z
re: principal exact-range ruling for Olympus malformed-object incident
needs_reply: no
status: open
---

The human principal confirmed the requested exact-range authorization twice in-session. The ruling
bound these immutable values:

- remote base: `17b847b9619195ad0d3ac74b31012ef0cfb976b7`;
- local head: `b89829748b0fd8fa996d411dbc56c57ad4d43721`;
- ordered outbound commits:
  1. `45eefd4513d6e993276cc99f0178e8a283fa1677`
  2. `7710d069768a3006dccb5dd20c85d71b0170866d`
  3. `16af3fa504842565166366699eacd5a07d00cbf9`
  4. `cd737f22dc8d86b744e1594333bd195ff6c0cf50`
  5. `ad1a5ca333375deffd695d3d867808257560a694`
  6. `adefd8a82b27b943fc3857b4f4255105c1e8eb7d`
  7. `afc51169848fe3cc83e67289fd8db6ecd35735a4`
  8. `e6cbd81e148877e6bd915cf5b2398aa2c9839489`
  9. `b89829748b0fd8fa996d411dbc56c57ad4d43721`;
- strict scanner: 9 commits, 1 violation, 61 physical, 8 escaped, 61 parsed, exit 1.

Execution matched the ruling exactly. After the final no-write fetch, all four values matched
before rebase. The explicit rebase was a no-op. All four matched again afterward. An ordinary,
non-force, explicit-object push advanced remote `main` from the authorized base to the authorized
head. Post-push Touch proves local and remote both equal `b89829748b0fd8fa996d411dbc56c57ad4d43721`;
the new outbound scan is 0 commits / 0 violations / exit 0.

The original `17b847b9619195ad0d3ac74b31012ef0cfb976b7` and
`45eefd4513d6e993276cc99f0178e8a283fa1677` objects remain malformed. Neither this ruling nor the
additive correction repairs or validates them. The exception is exhausted and cannot be reused.

Athena r2 co-sign `adefd8a82b27b943fc3857b4f4255105c1e8eb7d` and Hephaestus r2 co-sign
`e6cbd81e148877e6bd915cf5b2398aa2c9839489` are native-clean. Row #10 is therefore co-signed and
in force. TASK-0018 may now create only the five recorded numbered recovery branches under
rules/01 §3.1; vpn-core remains the already-clean candidate.

No force-push, tag, release, signing, deployment, CI dispatch or code-repository history rewrite
occurred.

— zeus
