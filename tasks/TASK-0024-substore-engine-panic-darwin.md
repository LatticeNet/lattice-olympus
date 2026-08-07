---
task: TASK-0024
title: Sub-Store engine panics under -race on darwin/arm64
owner: principal
status: open
repos: [lattice-plugin-sub-store]
last_touched_by: principal
depends_on: []
blocked_by_ruling: —
needs_ack: no
created: 2026-08-07
---

## What happens

The embedded Sub-Store engine (QuickJS on wazero) panics when engine-touching
tests run under `-race` on darwin/arm64. The plugin recovers and reports
`Sub-Store engine panicked (panic_sha256=…)`, so the test fails rather than the
process dying.

It is not one test. Across runs it has hit at least:

- `TestSubStoreEngineResponseTransformCallDoesNotUseHost`
- `TestPipelineRecordsRunSavedPipelineWithoutStoringRaw`
- `TestEmbeddedSubStoreCoreAppliesResponseTransformerPipeline`
- `TestSubStoreEngineConvertCallDoesNotUseHost`

Every occurrence sits at **~30s**, which is suspiciously uniform for something
described as a panic rather than a timeout.

## What is established

**Pre-existing, not a regression.** Measured rather than assumed: the unmodified
`origin/integration` tree fails 3/3 in isolation on the two tests that were
failing at the time, where the branch under development failed 2/3. Every wave
since has reproduced it on the baseline.

**Platform-specific.** CI runs `go test -race ./system-go/...` on
ubuntu-latest/amd64 and is green on every integration push, including the ones
carrying the work that hit this locally.

**Not caused by any of the design-16 waves.** The failing tests are engine and
pipeline tests untouched by the subscription, collection or UI work.

## Why it matters despite being local-only

A recovered panic in a WASM sandbox is not a flake to shrug at. Two readings and
both are worth ruling out:

1. Resource pressure on this machine (race instrumentation plus a 128 MB memory
   limit plus parallel builds) trips a wazero limit that the recover path
   reports as a panic. Benign, but it means the local suite cannot be trusted as
   a gate, which is how a real failure gets waved through as "that one again".
2. A genuine memory or concurrency fault that linux/amd64 happens not to
   surface. If so, it is a production correctness issue on arm64 hosts — and
   production runs `linux/arm64`.

Reading 2 is the reason this is a task rather than a note. The deployed fleet is
arm64; only the *OS* differs from where it reproduces.

## Progress

**2026-08-07 — the escape hatch exists.** `substoreEngineRawErrors` is an
unexported package var that makes `redactSubStoreJSError` and
`redactSubStoreEnginePanic` return their original text. Only a test helper
assigns it, and a guard test fails if any shipped file ever does, so redaction
cannot quietly become default-off. It paid for itself on its first run,
pinpointing a `produce`/`yaml` shape mismatch in the files work that the hash
had reduced to eight opaque bytes.

The panic itself has not reproduced since; the remaining bullets stand.

## First things to try

- ~~Capture the actual panic before it is hashed.~~ Done — see Progress.
- Run the same tests on `linux/arm64` in a container to separate "arm64" from
  "darwin".
- Run without `-race` on darwin to see whether instrumentation is required to
  reproduce.
- Check whether the 30s is a wazero or QuickJS bound rather than the engine's
  own 10s timeout, since the engine limit is not what is being hit.

## DoD

- [x] the raw panic is known rather than hashed
- [ ] reproduced or excluded on linux/arm64
- [ ] either fixed, or documented as a darwin-only test-harness limitation with
      the local suite's status made explicit so it is not a silent gate
