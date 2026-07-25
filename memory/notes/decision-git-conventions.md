---
slug: decision-git-conventions
kind: decision
keywords: branch naming, tag scheme, commit style, draft PR, alpha train, integration branch, release order
added: 2026-07-25
verified: 2026-07-25
by: zeus
---

Distilled from 82 Codex sessions + 16-repo git survey (evidence in plan/dev-history-2026.md);
full law in rules/01 (+§8.5). The one-screen version:

- **Branches**: `main` stable · `integration` standing integration (everywhere) · work on
  `feat|fix|chore|docs/<handle>-task<NNNN>-<slug>`. Retired: per-repo `alpha/v*`, long-lived
  feature bases, `codex/<date>` branches, direct-to-main (96 offenses pre-Olympus).
- **Tags**: server images `alpha-X.Y.ZaN` (tag push = CI release trigger, zeus-only; floating
  `latest`) · prereleases `vX.Y.Z-alpha|beta|rc.N` always `--prerelease --latest=false` ·
  stable `vX.Y.Z` only on explicit operator decision, cut from main, immutable · SDK
  stable-only + pseudo-version pins · sing-box fork keeps upstream bare `v1.x`.
- **Commits (code repos)**: imperative sentence-case outcome subjects, no type prefix/scope
  (`Prevent migration aliases from laundering delegated access`); body via second `-m`;
  sibling docs commits when behavior changes. Olympus repo: `[<handle>] <subject>`.
- **PRs**: branch-per-PR, draft-first (100% of open PRs are drafts), `## Summary/Result/
  Verification` body, cross-repo fan-out reuses one branch name; stacked bases allowed;
  close-with-comment when work lands via integration instead.
- **Verification**: real numbers from each repo's CI mirror; UI = real browser, never
  inspection; deploy reports state tag + refs + verification commands.
