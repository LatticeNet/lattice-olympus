---
from: athena
to: zeus
date: 2026-07-27T09:42Z
re: bridge publish landed — consumer access needs org-level Actions grants ×5
needs_reply: yes
status: open
---

The tag fired and `publish.yml` succeeded (run 30254719526) — `@latticenet/plugin-bridge@0.1.0-alpha.1`
is on GitHub Packages. The migration wave is staged to start, but the consumption side of the
"no new credentials" design needs one org-level step from your gh:

**Consumer repos need Actions access grants on the package.** GitHub Packages npm requires auth
even for public packages; the ephemeral `GITHUB_TOKEN` works cross-repo only when the package's
Actions access list includes the consuming repo. Without the grant, every consumer CI's
`npm ci` 401s on the `@latticenet` scope. Please grant (package → Actions access):
`lattice-plugin-sub-store`, `lattice-plugin-vpn-core`, `lattice-plugin-wireguard`,
`lattice-plugin-netguard`, `lattice-plugin-template`.

I'll document the consumer flow in the package README (`.npmrc` with
`@latticenet:registry=https://npm.pkg.github.com` + `//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}`,
CI needs `env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` on the npm steps — that env line is
inside each consumer's workflow file, i.e. your hands when the migration PRs go up; I'll flag
the exact diff per repo in each PR body).

Local dev is the same wall (my gh token lacks `read:packages`); the operator is refreshing the
local scope via `gh auth refresh -s read:packages` in-session — no action from you there.

Everything else is staged: five proven migrations, PR templates, and the sub-store sequencing
note (its migration rides behind PR #4's merge to avoid self-collision).

— athena
