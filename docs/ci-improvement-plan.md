# CI, build, and release improvement plan

Review of the test, packaging, and release setup as of October 2026. The first item is the change in this pull request. The rest are follow-ups.

## 1. Make the Lint workflow a real gate

**Why it matters.** `.rubocop.yml` replaces RuboCop's default ignore list with only the gemspec. CI installs gems into `vendor/bundle`, so RuboCop inspects those gems (3311 files on the latest `main` run) and fails. The Lint job sets `continue-on-error`, so the workflow still succeeds. A style regression in the project is invisible, and the check does not describe the code under review.

**Effort.** Small. Restore the generated-path ignores, baseline the project's existing offenses so the job can be required without a style rewrite, and remove `continue-on-error`.

**Risk.** Low. The baseline records today's offenses per file and leaves the cops enabled, so a new file still fails. A later RuboCop release can add cops and turn the job red until the baseline is regenerated. That is the point of a required check.

**This pull request does this item.**

## 2. Match the Ruby matrix to versions that are still supported

**Why it matters.** The required matrix is Ruby 3.0 through 3.4. As of October 2026, 3.0, 3.1, and 3.2 are end of life. Ruby 4.0 already passes the unit tests and gem build, but that job is allowed to fail. The README and contributor notes still promise Ruby 3.0+. Keeping EOL interpreters on the required matrix will break when the runner image or `ruby/setup-ruby` drops them.

**Effort.** Small for the workflow and docs. The support promise has to change in the same change.

**Risk.** Medium. Dropping 3.0–3.2 from CI stops catching regressions for anyone still on those interpreters. Leaving them required risks a red matrix for a reason unrelated to the gem.

## 3. Tighten gem packaging

**Why it matters.** `gem build` warns on every run: `logger` has no upper bound, and `required_ruby_version` is unset. `logger` is no longer a default gem on current Ruby, so an unbounded dependency can resolve to a future major version. The file list uses a pattern meant to drop `*.tar.gz` archives that does not match a normal archive name. The gemspec date is still 2021-09-29, and the version is stored in both `VERSION` and `lib/rubyipmi/version.rb`.

**Effort.** Small. Bound `logger`, set `required_ruby_version` to the versions the project still claims, and fix the archive filter. Decide whether one version file is enough before deleting the other.

**Risk.** Low if the Ruby requirement stays at 3.0 or whatever the README still promises. Setting it higher than the tested matrix would reject installs the project still claims to support.

## 4. Stop tests from passing on the wrong failure

**Why it matters.** The freeipmi and ipmitool error-code specs use `raise_error` with no class. On Ruby 3.4 the freeipmi example for a nil code passes because `chomp!` raises `NoMethodError`, not the "no fix" error the example is named for. Separately, `rake integration` with no `ipmiprovider` builds an empty provider list (`Array(nil)` is truthy), so the documented default of freeipmi and ipmitool never runs.

**Effort.** Small for the matcher assertions and the provider default. Integration tests still need real hardware, so the rake fix should be covered by a unit-level example of the provider list, not by running the hardware suite.

**Risk.** Low. Tightening the nil-code example will fail until `search` handles nil on purpose. That is a behavior choice, not a CI-only edit.

## 5. Add a release path and narrow CI credentials

**Why it matters.** Publishing is `rake release` from `bundler/gem_tasks`, with no GitHub Actions release workflow and no trusted-publishing setup. Test, lint, and security workflows do not set `permissions`, so the token keeps the repository default (write on the latest run). Coverage never uploads: Coveralls loads only when `COVERALLS_REPO_TOKEN` is set, and the test workflow does not set it. `Gemfile.lock` is gitignored, so `bundler-audit` checks a freshly resolved set rather than a committed one. Dependabot already bumps floating action tags; SHA pins are a separate hardening step.

**Effort.** Medium. A release workflow needs a publishing credential and a decision about trusted publishing. Permission blocks and a coverage token are smaller.

**Risk.** Medium for anything that can push a gem. Low for read-only workflow permissions. Committing a lockfile would change the current library policy of testing against current dependency resolution.
