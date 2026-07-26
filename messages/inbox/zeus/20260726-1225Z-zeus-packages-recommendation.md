---
from: zeus
to: zeus (operator record)
date: 2026-07-26T12:25Z
re: RECOMMENDATION — publish @latticenet/plugin-bridge to GitHub Packages now; npmjs reserved as a train-time migration
needs_reply: yes
status: answered
---

Per ruling §7 ("evaluate GitHub Packages and letter the operator"), the evaluation and my
recommendation.

**Recommend: GitHub Packages, now.**
- **Zero new credentials** — publishing runs in the repo's own Actions with the ephemeral
  per-run `GITHUB_TOKEN` (`permissions: packages: write`). Fits rules/03 exactly: no
  credential creation, nothing long-lived, nothing in my hands. npmjs would need a token you
  have not issued, plus its 2FA/rotation lifecycle.
- Same org namespace (`@latticenet/plugin-bridge`), access follows the org, versions sit next
  to the code.
- Every CURRENT consumer (five plugin UIs + dashboard) builds inside LatticeNet CI where
  `GITHUB_TOKEN` grants read — consumption is one `.npmrc` line per repo, no secret material
  committed.

**The one real limitation, stated plainly**: GitHub Packages requires authentication to
INSTALL npm packages even when public. Inside the org that is free (CI token). For an external
third-party plugin author it is friction: they need any GitHub token with `read:packages`.
Mitigation: the package name is registry-independent — if/when external consumption matters,
migrating to npmjs at a stable train (TASK-0010) is a publish-target change plus consumer
`.npmrc` updates, nothing in the code. I recommend deciding npmjs THEN (with you issuing the
token at train time), not now.

**Already done under the §7 grant** (reversible, no publish yet):
`github.com/LatticeNet/lattice-plugin-bridge` created — public, presentable README (checked
against the public-surface conditions: no hosts/IPs/fleet detail), `main` + `integration`
branches seeded at `a3471aa`. Athena is unblocked for code; the FIRST PUBLISH waits for your
one-word confirmation of this recommendation.

**Ask**: confirm "GitHub Packages" (or override to npmjs + issue a token). On your confirm I
wire the publish workflow in the bridge repo's CI (prereleases only, `--latest=false`
semantics per rules/01 §8.5) via the normal branch/review flow.

— zeus

> [answered] zeus 2026-07-26T12:38Z: operator confirmed "GitHub Packages" in-session. Publish workflow wired as bridge#2 (tag-triggered, operator pushes tags).
