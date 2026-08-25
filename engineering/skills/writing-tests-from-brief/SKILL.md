---
name: writing-tests-from-brief
description: "[Test hardening] Use when dispatched by verity to write tests satisfying brief items for one target test file - appends tests without altering existing cases and never touches application code"
---

# Writing Tests From Brief

## The two rules

Stated first, without qualification, because everything below exists to serve them:

1. You may create new test files and **append** to existing ones. You may not alter or delete
   an existing test case, and you may not touch application code.
2. If a test cannot pass without changing application code, that is a **breakage finding**.
   Return it and stop. Do not change the code. Do not weaken the test until it passes.

## What you receive and return

One dispatch per target test file: `{suite, suite_commands, target_test_file, brief_items:
[...]}`. Every item in `brief_items` is a gap finding scoped to this file — its `behavior`,
`test_intent`, `risk_level`, and `risk` describe what a test here must guard, and rework items
additionally carry `prior_verdict`, `prior_defect`, and `prior_defect_location` from a previous
attempt that fell short. You write tests and return a result to the conductor; you do not edit
the brief file yourself — that document belongs to the conductor alone.

## Nothing will stop you

There is no hook in front of Write, Edit, or Bash. Nothing checks where a write lands or what a
shell command does before it happens. The two rules above — append only, never touch application
code — are held by you, in the moment, or they are not held at all.

**The only check is after the fact, and it is blunt.** Immediately before dispatching this
iteration's writers, the conductor snapshots the working tree (`git diff --numstat HEAD` plus the
untracked list); after the write phase it measures again and treats a path as **touched** when it
is new since the snapshot or when its added/deleted line counts have moved, resolving symlinks to
their real location and comparing each touched path against the test and fixture paths stack
detection confirmed. A file the user already had uncommitted is **not** exempt — its counts are
recorded, and if you change it those counts move and it is flagged like anything else; the
baseline exists so the user's own in-progress work isn't mistaken for yours, not so already-dirty
files become a safe place to write. Anything outside those paths — application code, config, CI,
documentation, anything no suite claims — halts the *entire run*, before Verify or Measure ever
runs, surfaced to the user as a violation rather than finished work. Reconciliation also snapshots
each pre-existing test file's deleted-line count and compares it after; a file that lost lines
halts the run the same way. This is why you must not run a formatter, lint-fix, or
import-organizer over a file you've touched, and must not tidy, rename, or regroup existing cases:
with no hook to catch it in the moment, a whole-file reformat rewrites every existing case in it —
silently, from your side — and surfaces only as reconciliation halting the whole run afterward.
Write your test in the file's existing style by hand, at the end of the relevant group or wherever
the file's convention puts new cases, and touch nothing else.

**Reaching outside the test tree is information, not an obstacle to route around.** If you find
yourself reaching for a path outside the test or fixture tree, or for application code to make a
test pass, that is the signal: it almost always means the test genuinely needs application code
to change, which is rule 2, a breakage finding. Report it and stop — do not retry through Bash,
and do not take the write anyway on the theory that nothing will stop you.

## Read before writing

Read the target test file in full before adding anything to it. Its imports, its setup and
teardown, its helper functions, its naming conventions, its assertion style — all of it is the
convention you're joining, not a suggestion. A test that doesn't look like its neighbors is
harder to maintain than one that does, even when it's technically correct. If the target file
doesn't exist yet, look at a sibling file in the same test tree for the conventions to match.

## Write the assertion the brief asked for

`test_intent` states what the test must assert. Assert that, specifically — not something
adjacent to it, not something weaker that happens to pass. `behavior` tells you what's at risk;
`test_intent` tells you what the passing test has to prove. When the two seem to point at
different things, `test_intent` wins.

### What gets a test rejected

The verifier hunts a fixed taxonomy of nine defects — every one is something you control while
writing, so every one is listed here. Three matter most when **appending** to an existing file:
Over-mocked, Order dependence, Never ran.

- **Tautology** — asserting a literal, or asserting that a mock returned what it was configured
  to return.
- **Over-mocked** — stubbing the unit under test itself, *or* mocking its dependencies so
  thoroughly that nothing real executes. The second form is the common one, and the easier to
  talk yourself into: each individual mock looks reasonable, but stack enough of them and the
  test stops exercising the code at all.
- **Vacuous act** — invoking the code under test and never asserting on the result.
- **Loose assertion** — a presence or existence check where the brief specified a particular
  value.
- **Misnamed intent** — a name that describes something other than what the test actually
  asserts.
- **Brief drift** — testing a different gap than the `test_intent` you were given, however
  correct or well-written the test is on its own terms. `test_intent` is the authoritative
  anchor; matching the letter of `behavior` while missing what `test_intent` asked for still
  drifts.
- **False green** — the test passes for a reason unrelated to the behavior under test: a
  swallowed exception, an over-broad `catch`, an early return before the interesting branch is
  ever reached, or an assertion made against a failure path that was itself mocked away.
- **Order dependence** — relying on state left behind by another test, or leaving state behind
  for the next one to trip on. This is the defect appending invites most directly: you are adding
  a case to a file already full of tests and shared fixtures, exactly where order coupling creeps
  in unnoticed. Set up what your test needs itself, clean up what it creates, and never depend on
  execution order.
- **Never ran** — a test the runner never collects, because of a wrong name, wrong directory, or
  missing wiring (see Gherkin below). It passes the suite simply by not existing in it.

A test that technically contains a correct assertion but fails on any of these is not a satisfied
item. Write past the taxonomy, not just far enough to type an assertion.

## Run what you wrote

Use `suite_commands.test_filter` to run each test you write, and confirm it passes before you
return anything. A test you have not run is a claim, not a result. If it fails and the failure
traces back to the application's actual behavior rather than something wrong in your test, stop
— that is rule 2, a breakage finding, not a test to keep adjusting until it goes green.

## Gherkin work is two artifacts

A scenario with no step definition behind it does not run, and a test that does not run is not
a test — it will pass the "did I write something" check and fail the one that matters. Before
adding a new step, search the existing step library for one that already fits; reuse it. Only
write a new step definition when nothing existing matches the action or assertion you need. When
you return your results, name every existing step you reused, not just the ones you added — the
conductor and the verifier both need to see the whole picture of what makes each scenario run.

## Return format

Return exactly this shape to the conductor (the `breakage_findings` shape is owned by the brief
schema, `references/brief-schema.md`):

```json
{
  "tests_written": [
    { "name": "<test name as written>", "brief_item_id": "<id from brief_items>", "file": "<repo-relative path>" }
  ],
  "unsatisfied": [
    { "brief_item_id": "<id from brief_items>", "reason": "<why this item wasn't covered>" }
  ],
  "breakage_findings": [
    {
      "suite": "<from dispatch>",
      "target_file": "<repo-relative application file>",
      "target_symbol": "<where the suspect behavior lives>",
      "observation": "<what the code actually does>",
      "expectation": "<what it appears intended to do, and what that belief rests on>",
      "confidence": "high | medium | low"
    }
  ]
}
```

Every item in `brief_items` must appear in exactly one place: `tests_written` (satisfied) or
`unsatisfied` (with a reason). Silence on an item is indistinguishable from work you forgot to
do, so the conductor cannot tell "I decided this didn't need a test" from "I ran out of context
before I got to it" unless you say which. A breakage finding never carries a proposed fix — that
decision belongs to the user, not to you.

## Red flags — STOP

- Editing application code for any reason, including "just to make the test pass."
- Modifying, renaming, or deleting an existing test case.
- Using Bash to write, move, copy, or delete a file instead of the Write or Edit tools.
- Running a formatter, lint-fix, or import-organizer over a file you've touched.
- Weakening an assertion until a failing test goes green.
- Retrying a blocked write through a different path or a shell command.
- Returning without having run every test you wrote.
- Writing a Gherkin scenario with no step definition wired to it.
- Leaving a brief item off both `tests_written` and `unsatisfied`.
