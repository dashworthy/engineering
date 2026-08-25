---
name: triage
description: "[Triage] Problem-isolation entrance: given a reported defect, isolate the workspace in a worktree, establish or join a run, verify/reproduce the claim, isolate the cause with minimal effort, then take the smallest next step — quick fix (diagnosing-bugs), a discovery leg of its own for an under-specified report (the shared interrogating-requirements primitive, then brainstorming), or spec it (brainstorming then to-spec). A distinct entrance from signal — the two never hand off to each other. User-invoked via /triage. Logs disposition to .engineering/<run>/triage/; file-based, no tracker."
---

# Triage

Say this first, plainly: `Using the triage skill to isolate the problem.`

## What this guarantees

Given a reported defect, this skill decides what the smallest next step is, and starts
it — never more work than that decision requires. It verifies the report is real before
anything runs against it, isolates it only as far as a routing decision needs, and then
hands off to whichever skill is actually the right size: a quick fix, an interrogation
leg of its own, a design conversation, or nothing at all because the file already says why.

Every report that reaches it either gets routed correctly on the first pass, or gets closed
with a reason written down. Neither outcome leaves a report to sit unexamined.

## Isolate first

Before the run directory, before reading the report closely, before reproducing anything: establish an isolated worktree by invoking `engineering:using-git-worktrees`. Triage is an **entrance** — the base case is always a worktree, so everything a triaged defect leads to (a quick fix, an interrogation leg, a design conversation) happens off the base branch from the first step. Create it first so `run-context.sh` writes `.engineering/<run>/` **inside** that isolation; establish the run first and a later worktree switch orphans it on the base branch.

This step is safe to run unconditionally. `engineering:using-git-worktrees` detects existing isolation and no-ops when a worktree this session already entered is in place — so if signal established the run and its worktree first and the user then reached triage, triage joins that same worktree rather than stacking a second one. The shared worktree is substrate both entrances attach to, not a hand-off between them: triage never invokes signal, and signal never invokes triage.

## Establish or join a run

Before reading the report closely, get somewhere to put what you find:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" triage <slug>
```

This prints the absolute path of `.engineering/<run>/triage/` and creates it if it
doesn't exist yet. If a run is already active — started by `signal`, or by an earlier
triage pass on the same problem — this call joins it, and the `<slug>` you pass is
ignored. If nothing is active, it starts one, seeded from a kebab-case slug you derive
from the report in a couple of words.

Everything triage produces — reproduction notes, isolation, the routing decision and
why — goes into `.engineering/<run>/triage/` as it's found, not reconstructed afterward
from memory. A triage pass that routes correctly but leaves no trace of why is only half
done: the next report against the same area starts from zero instead of from what this
one already learned.

## Verify and reproduce, before anything else

A report is a claim, not yet a fact. Before isolating anything, before touching any
route, find out which of three things is actually true:

- **Confirmed** — you made the failure happen, on a path you can point to. Write down the
  steps and the failing path; everything downstream reasons from this, not from the
  report's original wording.
- **Not reproducible** — you tried, following the report as given, and nothing failed.
  This is not automatically "closed": the report might be stale, the environment might
  differ, or the steps might be incomplete. It is also not "confirmed." Say what you
  tried and what happened, and let the route reflect the actual uncertainty rather than
  rounding it either direction.
- **Under-specified** — there isn't enough here to try. No steps, no expected-versus-
  actual, no way to tell what "wrong" would even look like.

Acting before you know which of the three you have wastes the isolation that follows on the
wrong thing, and the few minutes it takes is smaller than that waste.

## Isolate — only as far as routing needs

Triage is not diagnosis: it needs enough to place the problem at a domain concept and pick a
route with confidence, and no more than that.

Work through `references/isolation-checklist.md` for the mechanics. In outline:

1. **Bisect by domain concept**, not by line number. Read `CONTEXT.md` and any ADRs the
   project keeps, when they exist, for the names and boundaries already in use.
   "The retry logic in the sync worker drops the second failure" is isolation enough to
   route on; finding the exact conditional that drops it is `diagnosing-bugs`' job, one
   step further than triage goes.
2. **Check for redundancy.** Read the code the report points at before assuming it's
   still broken — behavior changing out from under a report is common enough to check for
   first. If it's already fixed, that is the routing answer by itself: record the
   disposition and stop. Nothing downstream needs to run against something that isn't
   broken anymore.
3. **Check for prior rejection**, lightly. If this exact ask was already raised and
   turned down — a spec that considered it and rejected it, an earlier run that closed it
   as out of scope — say so and route on that decision instead of re-opening something
   nobody asked to revisit. This is a quick look at what the project's own history holds,
   not a new investigation.

## Route — the smallest next step

Once verification and isolation are done, `references/spec-decision.md` is the table:
given what was found, which route fits, and whether that route needs a spec written
before anyone builds against it. Read it before routing rather than reasoning the
mapping out fresh each time — it exists so the same shape of problem lands in the same
place every time triage sees it.

In outline, the four destinations:

- **Quick fix** — cause is obvious, the change is small and localized, risk is low. Hand
  off to `diagnosing-bugs` directly; there's no design decision here worth a spec.
- **Under-specified, or a feature request wearing a bug report's clothes** — the report
  lacks the requirements to act on. Triage runs a **discovery leg of its own**: invoke the
  shared discovery primitive `engineering:interrogating-requirements` (it self-drives the
  interrogation and its expansion beat, and writes the requirements — brief.md §1–§6 — into
  this run's `triage/` directory), then hand to `brainstorming`, the design dialogue both
  entrances converge on. This is **not** a hand-off to `signal`: triage never invokes the
  other entrance, it composes the same interrogation primitive signal does. Triage's leg
  stops at the requirements and lets `brainstorming` → `to-spec` → `writing-plans` order and
  spec the work downstream — it does not run the sequencing stage (§7–§8) itself. Approval
  comes downstream — the spec gate in `to-spec` — not here.
- **A real fix, but not a small one** — several call sites, a design choice, something
  risky or cross-cutting, work that needs sequencing, or work headed for an AFK agent to
  build unattended. Hand off straight to `brainstorming` — the shared design dialogue —
  then `to-spec`, then `writing-plans`. (This route needs no interrogation: the requirements
  are already clear enough from the isolated defect; what's missing is the fix approach,
  which is `brainstorming`'s to settle. Approval comes downstream — at the spec gate in
  `to-spec` and the plan gate in `writing-plans` — not in `brainstorming`.)
- **Not reproducible, already fixed, or out of scope** — nothing to hand off. Record the
  disposition and the reason in `.engineering/<run>/triage/`, and stop there.

## What this does not do

- It does not **find a root cause.** Diagnosing why a confirmed bug happens, with
  evidence, is `diagnosing-bugs`' guarantee. Triage isolates only as far as picking a
  route, and stops there even when curiosity wants to keep going.
- It does not **design a fix.** A route that needs a design decision goes to
  `brainstorming`; triage does not weigh approaches itself.
- It does not **own a private interrogator.** The under-specified leg drives the shared
  `engineering:interrogating-requirements` primitive — the same one signal uses — rather
  than a triage-local copy, so the extraction logic lives in one place and cannot drift.
  Triage conducts the leg; it does not reimplement the interrogation.
- It does not **hand off to `signal`.** The two entrances are distinct and never invoke
  each other. Where an under-specified report needs discovery, triage runs its own leg on
  the shared primitive; it does not route into the other entrance.
- It does not **write specs.** `to-spec` is the plugin's only writer of Tier-1 specs;
  triage hands it material and never drafts one itself.
- It does not **keep any record outside the run directory.** No board, no queue, no
  external system — everything is a file under `.engineering/<run>/triage/`, and nowhere
  else.
