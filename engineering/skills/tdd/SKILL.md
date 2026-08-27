---
name: tdd
description: "Drive implementation with a strict red-green-refactor loop: write a failing test, watch it fail, write minimal code to pass, refactor. Use when building any behavior that can be tested first. Distinct from test-hardening, which hardens existing tests after the fact."
---

# TDD

Say this first, plainly: `Using the tdd skill to drive this implementation.`

## What this guarantees

One thing: every behavior this skill builds gets a test that existed first, was watched to
fail, and only then was made to pass by the smallest change that could pass it. Whatever
code exists when a cycle ends, there is a test that would have caught its absence.

## The cycle

**Red.** Write a test for one behavior that does not exist yet, then run it and watch it
fail. Watching is not optional: a test that has never been run red is a test whose ability
to fail is unproven — a test that catches a real regression and a test that would pass no
matter what the code did look identical from a passing suite's point of view, and running it
red before the code exists is the only way to tell them apart. If the test passes
immediately, it is not testing the behavior you meant to add — it is already satisfied by
existing code, or not exercising the path you think it is.

Fail for the right reason, too. A test that errors on a typo, a missing import, or a
misconfigured fixture has told you the harness is broken, not anything about the behavior.
Fix the harness, rerun, and confirm the failure is now your assertion failing, not something
upstream of it.

**Green.** Write the smallest amount of code that makes the failing test pass. Smallest is
not a style preference — it is what keeps the test meaningful: code written to satisfy a
test you can see is shaped by that test; code written for a feature you're imagining several
steps ahead is code no test has yet earned the right to require. Resist handling inputs the
current test doesn't exercise, generalizing a single case into a configurable one, or
building the abstraction you're sure the third case will need. Let the next test demand
that, and write it then.

**Refactor.** With the test green, clean up — rename, remove duplication, restructure —
while the suite tells you, after every change, whether you preserved behavior. Refactoring
without a green suite in front of you is not refactoring; it is rewriting on faith. Take
steps small enough that if the suite goes red you know which edit did it, and run the suite
after each one rather than batching changes and finding out which broke something only once
all are done.

## One behavior per cycle

A cycle earns its name by covering one behavior — not one function, not one file, one
observable thing the code now does that it didn't before. Multiple behaviors in a single
red-green pass hide which one the passing test actually proves; if the test fails later,
you're back to guessing which of the several things you built broke. When a behavior feels
too large to write one test for, that is usually a sign it's actually several behaviors
wearing one description — split the test first, not the implementation. `tests.md`,
alongside this file, covers what "one behavior" means in practice: shaping the test itself,
naming it so the failure message says what broke, and keeping it from depending on any
other test's state.

Collaborators the code under test depends on are a separate decision from how many
behaviors the test covers. `mocking.md`, alongside this file, covers when replacing a
collaborator with a stand-in makes the test more honest and when it just makes the test
lie about what was actually proven.

## Boundary: tdd builds, test-hardening hardens

This skill and test-hardening (`conducting-test-hardening`) both produce tests and
neither replaces the other. This skill runs *during* implementation, one behavior at a time,
before the code that satisfies each behavior exists. Test-hardening runs *after* implementation
is believed finished: it audits a diff for behavior nothing pins down and writes tests to
close what it finds. TDD without test-hardening leaves the seams between behaviors unguarded;
test-hardening without TDD retrofits tests onto code no test shaped. Run this skill while
building; expect `conducting-test-hardening` to run again before the branch ships.

## What this does not do

- It does not **decide what to build.** The behavior a cycle tests comes from a plan or
  spec already settled upstream. This skill starts once there's one testable behavior in
  front of it; it does not weigh in on which behavior to build next or whether the feature
  is worth building at all.
- It does not **design the interface.** Shaping a module's boundary — what it exposes, what
  it hides — is `codebase-design`, and belongs before or alongside the first cycle, not
  inside it. A cycle can reveal that an interface is awkward; fixing that is a refactor
  step or a trip back to `codebase-design`, not a reason to skip watching a test fail.
- It does not **audit finished work for gaps.** That is test-hardening's job — see the
  boundary above.
- It does not **skip the watch.** Writing a test and the code together and running the
  suite once, green, is not this skill's cycle. If a test has never been seen to fail, this
  skill has not run yet, however much code already exists.
