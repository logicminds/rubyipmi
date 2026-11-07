# CI supply-chain and publishing notes

Public-library guidance for GitHub Actions and gem publishing. This is not a clean bill of health for the dependency tree or for developer machines.

## What CI does

| Control | Where |
|---------|--------|
| Third-party Actions pinned to full commit SHAs (version in a trailing comment) | `.github/workflows/*.yml` |
| Workflow `GITHUB_TOKEN` limited to `contents: read` (CodeQL also needs `security-events: write` / `actions: read`) | workflow / job `permissions` |
| `actions/checkout` does not keep the token in the local git config | `persist-credentials: false` |
| PRs use `pull_request` (not `pull_request_target`); no workflow secrets are referenced | workflow `on:` and steps |
| PR dependency review fails on high+ advisories | `security.yml` → dependency-review |
| `bundler-audit` CLI pinned; advisory DB refreshed each run | `gem install bundler-audit -v …` then `bundler-audit check --update` |

`Gemfile.lock` remains gitignored so the matrix can resolve current gems per Ruby. That means audit results reflect a freshly resolved set, not a committed lockfile.

## Publishing (no Actions release pipeline)

There is **no** GitHub Actions workflow that builds or pushes the gem. Releases use local Bundler gem tasks (`rake release` from `bundler/gem_tasks`).

Optional local RubyGems credentials (for example `~/.gem/credentials` or the host’s configured API key) are **maintainer machine** concerns. They are not wired into this repository’s workflows. Do not add a publishing secret to Actions unless you intentionally introduce a release workflow and review its trigger surface (tags, trusted publishing, environment protection).

Stolen developer publishing credentials are outside what CI permissions can fully stop. Prefer short-lived RubyGems tokens, revoke on compromise, and keep release steps off untrusted runners.

## Updating Action pins

Dependabot already watches `github-actions`. Prefer updates that keep the full SHA and refresh the `# vX.Y.Z` comment. Before merging, confirm the tag still points at that commit on the upstream repository.

## Related open work (do not duplicate)

Library credential and command hardening lives in other drafts (for example [PR #99](https://github.com/logicminds/rubyipmi/pull/99) and [PR #107](https://github.com/logicminds/rubyipmi/pull/107)), not in the workflow pin/permissions changes.
