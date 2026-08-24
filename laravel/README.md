# laravel

Pre-commit quality gates for Laravel projects, packaged as a Claude Code plugin for the
`dashworthy` marketplace. It wires [Pint](https://laravel.com/docs/pint),
[PHPStan](https://phpstan.org/) (or [Larastan](https://github.com/larastan/larastan)),
and your test suite ([Pest](https://pestphp.com/) or PHPUnit) into Claude's edit and
commit flow, so quality problems surface before they land in a commit.

Every check is guarded by a `vendor/bin` existence test, so the plugin is a no-op on
projects that don't have a given tool installed.

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install laravel@dashworthy
```

## What it does

Two hooks:

- **After every edit** (`PostToolUse` on `Write`/`Edit`) — runs PHPStan and reports the
  last 20 lines of output, giving Claude fast static-analysis feedback while it works.
  Non-blocking.
- **Before every commit** (`PreToolUse`, scoped to `Bash(git commit *)`) — runs the full
  gate in order:
  1. **Pint** (`pint --dirty`) formats changed files. If formatting changed anything, the
     commit is **blocked** so the reformatted code can be reviewed and re-committed — no
     silent formatting drift.
  2. **PHPStan** static analysis.
  3. **Tests** — Pest (`--no-coverage`) if present, otherwise PHPUnit.

  Any failing step aborts the commit (`set -e`).

The commit hook is scoped with the `if` field, so it only fires on `git commit`
commands — other `Bash` calls are untouched.

## Requirements

Install whichever tools you want enforced as dev dependencies:

```
composer require --dev laravel/pint larastan/larastan pestphp/pest
```

## Credit

Adapted from [trysettleup/precommit-laravel-hooks](https://github.com/trysettleup/precommit-laravel-hooks).

## License

MIT. See [LICENSE](../LICENSE).
