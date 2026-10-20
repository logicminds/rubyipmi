# CI, build, and release improvement plan

Review of the test, packaging, and release setup as of October 2026. Status is against `main` plus the open pull requests that already edit a file.

## Done

### Make the Lint workflow a real gate

Merged. `.rubocop.yml` ignores `vendor/**/*` and the other generated paths, `.rubocop_todo.yml` records the remaining offenses, and the Lint job no longer sets `continue-on-error`. A new offense fails the workflow.

### Publish unit coverage and show the gaps

Merged. The Ruby 3.3 cell sets `COVERAGE=1`, writes the SimpleCov HTML and JSON reports, uploads them, and `script/report_coverage.rb` prints line and branch totals plus the ten files with the most missed lines. A low percentage does not fail the build. Coveralls still uploads only when `COVERALLS_REPO_TOKEN` is set; the workflow does not set it.

## This pull request

### Require Ruby 4.0

**Why it matters.** The matrix required Ruby 3.0 through 3.4. Ruby 4.0 ran in a second job with `continue-on-error: true`, so a failure on the current interpreter stayed green. Unit tests and `gem build` already pass on Ruby 4.0.7.

**This pull request.** Ruby 4.0 is a cell in the required matrix, the allowed-to-fail job is gone, and the job times out after 20 minutes. `spec/unit/ci_workflow_spec.rb` locks that shape in. Ruby 3.0, 3.1, and 3.2 stay required.

**Left for a later change.** Dropping those end-of-life interpreters has to change the support promise in the same change. The README and `.github/copilot-instructions.md` still say Ruby 3.0+ tested through 3.4, and both files are already in open pull requests.

## Follow-ups

### Drop end-of-life Rubies from the required matrix

**Why it matters.** As of October 2026, Ruby 3.0, 3.1, and 3.2 are end of life. Keeping them required will break when `ruby/setup-ruby` drops the builds, for a reason unrelated to the gem.

**Blocked for now.** The README requirements line and the CI table, plus the Copilot instructions, are already edited by the credential-hardening and ipmitool option pull requests. Changing the support promise in a third pull request would overlap those files.

**Risk.** Medium. Dropping 3.0–3.2 stops catching regressions for anyone still on those interpreters.

### Tighten gem packaging

**Why it matters.** `gem build` warns on every run: `logger` has no upper bound, and on current RubyGems `required_ruby_version` is unset. `logger` is no longer a default gem, so an unbounded dependency can resolve to a future major version. The archive filter is `/^*.tar\.gz/`, which is not anchored the way a `*.tar.gz` exclusion should be. The gemspec date is still 2021-09-29, and the version is stored in both `VERSION` and `lib/rubyipmi/version.rb`.

**Blocked for now.** `rubyipmi.gemspec` is already edited by the open Dependabot rdoc bump. Development dependencies `rspec` and `bundler` are open-ended too; bounding them belongs with the same gemspec edit.

**Risk.** Low if `required_ruby_version` stays at 3.0, which is what the README still promises. Setting it higher would reject installs the project still claims to support.

### Stop tests from passing on the wrong failure

**Why it matters.** The freeipmi and ipmitool error-code specs use `raise_error` with no class. RSpec warns that this can pass on `NoMethodError`. The freeipmi example for a nil code does pass that way: `search` calls `chomp` and raises `NoMethodError`, not the "No Fix found" error the example is named for. Ipmitool's nil example does raise `RuntimeError`, but the matcher would also accept a name error. Separately, `rake integration` with no `ipmiprovider` builds an empty provider list (`Array(nil)` is truthy), so the intended default of freeipmi and ipmitool never runs and the task falls through to RSpec's default pattern.

**Blocked for now.** The freeipmi and ipmitool error-code libraries are in the open RuboCop cleanup pull requests, the ipmitool spec is in the spec cleanup, and the Rakefile is in the credential-hardening pull request. Integration tests still need real hardware, so a fix should be covered by a unit example of the provider list, not by running the hardware suite.

**Risk.** Low. Tightening the nil-code example will fail until `search` handles nil on purpose.

### Narrow CI credentials and add a release path

**Why it matters.** Publishing is `rake release` from `bundler/gem_tasks`, with no GitHub Actions release workflow and no trusted-publishing setup. The test and lint workflows do not set `permissions`, so the token keeps the repository default. `Gemfile.lock` is gitignored, so `bundler-audit` checks a freshly resolved set rather than a committed one. Dependabot already bumps floating action tags; SHA pins are a separate hardening step.

**Blocked for now.** `security.yml` is already edited by the open Dependabot bump of `dependency-review-action`. The Gemfile is already edited by the dead-code removal pull request, so committing a lockfile from today's resolution would fight that change.

**Risk.** Medium for anything that can push a gem. Low for read-only workflow permissions. Committing a lockfile would change the current library policy of testing against current dependency resolution.
