---
task: TASK-0025
title: Forward declared query parameters to a subscription share, and apply the headers it returns
owner: principal
status: ready
repos: [lattice-sdk, lattice-server, lattice-dashboard]
branches: []
last_touched_by: principal
depends_on: [TASK-0023]
blocked_by_ruling: —
needs_ack: no
created: 2026-08-07
---

## What is missing

A Sub-Store file whose document is built by a script can read two things this
platform does not yet give it:

- **`$options._req.query`** — the URL parameters on the request. Operators use
  this for per-client switches; the real generator this was measured against
  selects its DNS `enhanced-mode` that way.
- **`$options._res.headers`** — headers the document asks to be served with.
  The same generator sets `profile-update-interval: 24` and its own
  `content-type`.

The plugin side of both already exists and is tested: `render` accepts a
`query` map, narrows it to the names the record declares, and returns a
`headers` map alongside the content. Nothing reaches or reads them, because the
serve path in `server_subscription_share.go` sends
`{subscription_id, format, ua_class, raw}` and decodes only
`{content, content_type}`.

## The part that is not a straight passthrough

`subscriptionCache` is an LRU keyed on `{ShareID, Format, UAClass}`, and its own
comment states the invariant:

> It is bounded in entries rather than bytes because `classifyClientUA` already
> bounds how many entries one share can produce; an unbounded map keyed on
> caller-supplied data would be a memory amplifier.

A share URL is public. Putting a free-form query into the key breaks that
invariant: one share could mint unlimited distinct keys. The LRU caps memory,
but the damage is worse than memory — every request would miss, and a miss boots
a QuickJS VM and runs a 60 KB program. A public endpoint that renders on every
request is a denial-of-service amplifier, and the cache exists precisely to stop
that.

So the set of parameters that may vary the output has to be **bounded and known
to the server**, not free-form.

## Options, with the trade

1. **Declare on the share** (server-side model). `SubscriptionShare` gains an
   allowed-parameter list; the server forwards only those and keys the cache on
   them. Bounded by construction and auditable in one place. Costs an SDK model
   change, so the release chain is sdk → server → dashboard, plus a dashboard
   control to set it.
2. **Bound and forward everything.** Cap count and size, include the canonical
   query in the key. No model change, but junk parameters still evict real
   entries, so the cache degrades under exactly the traffic it protects against.
3. **Learn it from the plugin.** The render reply reports which parameters it
   consulted; the server caches that per share and keys on the intersection.
   No model change and self-healing, but the first request per share is
   unkeyed, and a cache whose key depends on a previous response is a
   correctness surface worth more than it saves here.

Option 1 is the recommendation. The plugin keeps its own filter regardless —
two gates, and the plugin's one also covers the preview path, which has no
server in front of it.

## Headers

Simpler, but not unconditional. The plugin returns what the document asked for;
the server decides what it is willing to send. `Cache-Control`, `Content-Length`
and anything security-relevant stay the server's, and `Subscription-Userinfo`
must keep coming from the snapshot rather than from a document that could
misreport a user's remaining quota.

## DoD

- [ ] a share declares which query parameters may reach its source
- [ ] the cache key stays bounded per share, with a test that a junk parameter
      cannot mint a new entry
- [ ] declared parameters reach the plugin and undeclared ones do not
- [ ] a document's headers are applied, with the server-owned ones refused, and
      a test naming which those are
- [ ] finish letter

## Log (append-only, newest first)

- 2026-08-07: filed while landing script files. The plugin half is done and
  tested on `feat/principal-substore-file-scripts`; scripts work today using
  stored `$arguments` instead of URL parameters, so this is an enhancement
  rather than a blocker.
