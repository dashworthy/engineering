---
name: reviewing-test-quality
description: "Guardtower's test-quality facet: review the tests a change carries — do they actually exercise the changed behavior and fail if it breaks? Flags vacuous or tautological assertions, tests that never touch the changed path, assertions too weak to catch a regression, uncovered edge cases the change introduces, and assertions bound only to a mock's own return. Judges structurally; never runs the suite. Use when a test-quality review of a diff/branch/PR is requested."
---

# Reviewing — Test Quality facet

Say this first, plainly: `Using the guardtower test-quality facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks at the tests the change carries and asks
whether they would actually catch a regression in the changed behavior — flagging vacuous
assertions, tests that never exercise the changed path, assertions too weak to fail when the
behavior breaks, uncovered edge cases the change introduces, and assertions bound only to a mock —
and returns a short, ordered, self-contained list of findings, capped and floored, with a durable
record written to its artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

**It judges structurally, and never runs the suite.** The question "would this test fail if the
changed behavior broke?" is answered by *reasoning* about whether each assertion binds to an output
the changed behavior actually determines — not by executing anything. Running the suite is out of
scope: it is unbounded, stateful work, and this facet is report-only and bounded to the diff.
Concretely: read the changed behavior, read the test, and decide whether a regression in that
behavior would change a value the test actually asserts on. Its reach is a fixed boundary — the
change's own tests and the code they cover, read against the reviewer's knowledge of how the test
framework asserts; **no proactive whole-suite audit**, no coverage run, no execution.

## The workflow

1. **Relevance gate — first, before any lens work.** Does this change have a test surface to judge?
   It adds or edits tests, **or** it changes behavior that should carry tests. A change with no tests
   in the diff and no behavior needing them — a pure docs, config, or comment change, or a rename
   with no behavior change — is **not** in scope: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact recording
   the skip.

2. **Apply the lenses — by reasoning, not by running.** For a change that passed the gate, work
   [references/test-quality-checklist.md](references/test-quality-checklist.md), across the
   diff-visible classes:
   - **Vacuous / tautological assertion** — asserts a constant, a value against itself, or only that
     setup ran.
   - **Changed path not exercised** — a test that never actually drives the changed code path.
   - **Assertion too weak** — asserts no-throw only, or a type but not the value the change
     determines, so a regression slips through.
   - **Uncovered introduced edge case** — an edge case the change itself introduces that no test
     covers.
   - **Bound to the mock, not the behavior** — an assertion that only checks a mock's own canned
     return rather than real behavior.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` in the Finding
   schema (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why`
   legible to a reviewer with no shared context. Write the artifact even when nothing survives the
   floor (record "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **run the tests.** It reasons about whether an assertion would fail on a regression; it
  never executes the suite, measures coverage, or reports a pass/fail.
- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **audit the whole suite** — its reach is the change's own tests and the code they
  cover; a coverage gap the diff doesn't touch is out of scope.
- It does not **review beyond test quality** — a security or correctness smell in the code under test
  is another facet's; this one judges the tests.
- It does not **enumerate style nits** — test naming, framework choice, and formatting are below the
  floor by design.
