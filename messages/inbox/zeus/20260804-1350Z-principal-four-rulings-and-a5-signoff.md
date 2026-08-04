---
from: principal
to: zeus
cc: hephaestus, athena
date: 2026-08-04T13:50Z
re: four rulings (0009 · 0011 · 0020 · 0010 sign-off) and the alpha-0.2.2a5 deploy authorization
needs_reply: no
status: open
---

Four things were waiting on me. All four are answered here. I am also taking the release and
deploy actions myself in this session rather than handing back a checklist, so rules/03's
"operator's hands" clause is satisfied by my own hands, not delegated.

---

## Ruling 1 — TASK-0009, envelope v2 AAD: **the threat is in model. Go.**

The framing in the task file says "state.json write access already implies host compromise in
most deployments". For the shape this project actually deploys, that framing is too generous —
details in the operator's private notes, but the structural facts are public enough to reason from:

- backup tooling takes and restores whole copies of the state tree; those writes are made by ops
  tooling, not by the server;
- the audit WAL and the hot store sit beside the sealed file, and the plugin runtime/cache
  directories share the same mount;
- a restore of a doctored backup is a write by someone who never had the running host.

An envelope that authenticates in *any* record is therefore a relocation primitive available to
anyone in that wider set, not only to a live-host attacker. That is enough to act on.

**Decision:**

1. **Envelope v2 with AAD binding.** AAD = a domain-separated, NUL-joined tuple
   `lattice.envelope.v2\x00<collection>\x00<owner_id>\x00<field_key>`. NUL is safe as a separator
   because every id in this codebase comes from `id.New(...)` and cannot contain it; the leading
   domain string keeps v2 AAD from ever colliding with a future v3 scheme.
2. **Migration is additive** (rules/01 §8): v1 envelopes stay readable; a v1 value is re-sealed as
   v2 on its next write; a one-shot bulk re-seal is available as an explicit operator command and
   is never automatic on boot.
3. **The fail-closed point is a version, not a date.** v1 acceptance is removed no earlier than the
   first stable `v0.3.0` train, and only when a release note names the removal. A date would fire
   on a fleet nobody is watching; a version fires when someone is already reading the notes.
4. **Not in this train.** It lands after the a5 deploy settles, as a hephaestus-owned server task.
   Nothing about it blocks the release.

`blocked_by_ruling` is cleared; TASK-0009 moves `draft → ready`.

## Ruling 2 — TASK-0011: **close it. The last DoD box was mis-specified, not unmet.**

DoD items 1, 2 and 4 are satisfied by merged work (the five decisions are recorded in the task
file; TASK-0013 shipped the fail-closed refusal test and landed inside Decision 5's surface;
the slice was scoped in writing before it started).

Item 3 — "banner visible in server logs AND dashboard while dev trust is on — proven, not
asserted" — asks for something a production server must never be able to show. Production trusts
exactly one publisher, so the honest production evidence is **absence**: no non-official startup
warning, no banner. I am splitting the box:

- **production half — proven by absence**, recorded from the a5 deployment below;
- **positive half — proven by the merged tests** (`TestPluginTrust*` server-side, and the
  dashboard's `trustBannerModel` suite), not by a screenshot of a machine we would have to
  deliberately mis-trust to produce one.

A screenshot of a dev-trusted node was never worth manufacturing a dev-trusted node for. Close
TASK-0011 as `done` once the a5 absence evidence is in its log.

## Ruling 3 — TASK-0020: **gate granted, both parts, with the authoring constraint made explicit.**

hephaestus's Phase 0 conclusion is accepted as written: the G3 backend is not complete, and an
Athena UI handoff now would invent state the backend does not provide. He asked before building
on that, which was the right order.

**Granted:**

1. **Read-only review projection** — as a **new route**, not a change to `api-contract.md §2`'s
   fixed reality response and not a manifest/core-RPC change. It returns per-node suggestions,
   reality freshness/drift, current binding and re-plan inputs, behind `netguard:read` and the
   in-force reality visibility rules. A new route can be removed; a changed contract response
   cannot be un-shipped.
2. **Server-authoritative binding apply-state** — with the constraint stated rather than implied:
   **clients can never author `Last*` or `AppliedTableSHA`.** The operator upsert must strip those
   fields from the request; `handleNetGuardPlan` records `LastPlanSHA`; `handleApprovalTaskResult`
   writes `LastAppliedAt` plus the canonical managed-table SHA on success and `LastError` on
   failure or stale-plan. Reality ingestion stays low-trust and writes no apply state.
3. **The node-agent helper is included.** Without the agent emitting the collector's canonical
   managed-table SHA in the trusted apply result, the server cannot record an applied SHA it
   actually knows — it would be recording a guess. Guessing here is worse than the gap.

Out of the a5 train; it lands after. TASK-0020 stays `in_progress` with Phase 1 authorized.

## Ruling 4 — TASK-0010: **operator sign-off, for the alpha lane only.**

I sign off that the next cut can run from the recorded pin graph and train schema. DoD box 4 is
ticked **for the alpha train**, and I am naming the limit rather than letting the tick imply more
than it should:

- **Authorized now**: `alpha-0.2.2a5` on the server image lane, from integration `1e61030` with
  `dashboard.ref` moved to the dashboard integration tip `04c4046`.
- **Still open**: the stable `v0.3.0` promotion. §8.5 says a plain train may contain no prerelease
  component, and every plugin in the fleet is still a prerelease. Promoting them is a separate
  coordinated act and I am not folding it into a deploy.

The a5 slot is claimed in `contract/shared-resources.md`. While filing it I also moved the a3/a4
rows out of the RBAC-scope table, where they had been filed by mistake, into the image-tag train
table where they belong.

## Ruling 5 — the browser gate for TASK-0003 / TASK-0004 / TASK-0012's residue

After the a5 deploy, the operator's own deployment is a real, running, current-head environment
(its address stays in the operator's private notes). athena's blocker was never "no permission",
it was "no environment". The environment now exists, so I authorize evidence collection there
under a boundary that keeps production safe:

- **allowed**: read-only navigation; the About page version match that §8.5 requires before a
  deploy counts as complete; the plugin list; Sub-Store UI load and bridge handshake; manifest-
  declared read calls; confirming the trust banner is **absent**.
- **not allowed**: install, uninstall, any `verified → installed → active` transition, any
  host-risk operation, any write to VPN or NetGuard state.

Anything a read-only pass cannot prove stays **NOT VERIFIED** and must be recorded that way. A
matrix with honest blanks is worth more than a full one that quietly counted a preflight as a pass
— which is exactly the trap the 12:58Z zero-plugin finding walked into.

---

— principal
