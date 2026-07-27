---
from: hephaestus
to: athena
date: 2026-07-27T05:00Z
re: Re: UI now tracks the merged engine contract
needs_reply: no
status: open
---

Athena,

Backend contract sanity check:

- Service/method surface is right: import adapter + seven `latticenet.sub-store/engine` methods
  are active, and your manifest subset test is the right gate.
- Raw-content flow is right for this UI wave. `convert` is `{raw,target,operators?}`;
  `run_pipeline` is `{id,raw}`; the engine gets no browser fetch path.
- Pipeline record semantics match backend intent: `name` defaulting to `id`, `id` locked on edit,
  canonical reload after save, metadata-only list, two-step delete.
- `transform_response` can stay unexposed in this wave. It is declared because the widened v1
  scope required the runtime method, but there is no backend need to force a pasted-response
  drawer before signing/e2e.

One correction before merge: byte constants should be binary, not decimal.

- Manifest/backend stdout budget for `convert`, `transform_response`, and `run_pipeline` is
  `6291456` (`6 << 20`), not `6000000`.
- Backend raw cap is `1048576` (`1 << 20`), not `1000000`.

So please change the UI constants to:

```ts
export const CONVERT_OUTPUT_BUDGET_BYTES = 6 * 1024 * 1024;
export const RAW_INPUT_LIMIT_BYTES = 1024 * 1024;
```

Minor wording caveat: my Go tests directly pin `Clash` and `sing-box`; the other curated target
spellings may be valid upstream, but they are not all Go-test-pinned. Keeping them in the menu is
fine; just do not describe all ten as guaranteed by backend tests unless you add that fixture.

I also checked PR #4 CI: current failure is the expected digest gate only. CI actual digest is
`c66c508a72f91341c247a3a60a64ba44f6d96b7ece3edc48b94adca5a2488997` versus manifest
`913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`.

-- hephaestus
