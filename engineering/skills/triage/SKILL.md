---
name: triage
description: "Problem-isolation entrance for a reported defect: verify it reproduces, isolate the cause only as far as routing needs, then take the smallest next step. User-invoked via /triage; file-based, no tracker."
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

This step is safe to run unconditionally. `engineering:using-git-worktrees` detects existing isolation and no-ops when a worktree this session already entered is in place — so if signal established the run and its worktree first and the user then reached triage, triage joins that same worktree rather than stacking a second one. The shared worktree is substrate both entrances attach to, not a hand-off between them.

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

A report is a claim, not yet a fact. Before isolating anything, before touching any route,
establish which of three things is true — **Confirmed**, **Not reproducible**, or
**Under-specified** — and write it down; `references/isolation-checklist.md` §1 has the
mechanics and what keeps the three from rounding into each other. Acting before you know which
you have wastes the isolation that follows on the wrong thing, and the few minutes it takes is
smaller than that waste.

## Isolate — only as far as routing needs

Triage is not diagnosis: it needs enough to place the problem at a domain concept and pick a
route with confidence, and no more than that.

Work through `references/isolation-checklist.md` for the mechanics — in outline, three checks:
**bisect by domain concept** (not by line number), **check for redundancy** (the reported
behavior may have changed out from under the report — if it's already fixed, that is the routing
answer), and **check for prior rejection** (a spec or earlier run that already turned this exact
ask down routes on that decision). Placing the problem at a domain concept is isolation enough;
finding the exact conditional is `diagnosing-bugs`' job, one step further than triage goes.

## Route — the smallest next step

Once verification and isolation are done, `references/spec-decision.md` is the table: given
what was found, which of four routes fits, and whether it needs a spec written before anyone
builds against it. Read it before routing rather than reasoning the mapping out fresh each time —
it exists so the same shape of problem lands in the same place every time triage sees it.

Two things the table can't carry on its own:

- The under-specified route is **triage's own discovery leg** — invoke the shared discovery
  primitive `engineering:interrogating-requirements` (it self-drives the interrogation and
  writes the requirements, brief.md §1–§6, into this run's `triage/` directory), then hand to
  `brainstorming`, the design dialogue both entrances converge on. This is **not** a hand-off to
  `signal` — triage never invokes the other entrance.
- Approval is never here. Every route that builds carries its approval downstream — the spec
  gate in `to-spec`, the plan gate in `writing-plans` — not in triage and not in `brainstorming`.

## Take the route — don't park it

The routing step ends in exactly one act: **invoke the next skill now**, or **close with a
written disposition**. Reporting the chosen route and asking whether to proceed is not one of
them — it leaves the report examined-but-sitting, the one outcome the guarantee above rules out.
"Triage stops here" means it stops *diagnosing and designing*; that same beat hands off. There is
no halt in between and no confirmation to collect — approval lives downstream (`to-spec`,
`writing-plans`), never at this seam. Once the route is written into the file, the next thing you
do is start it.

## What this does not do

- It does not **find a root cause.** Diagnosing why a confirmed bug happens, with
  evidence, is `diagnosing-bugs`' guarantee. Triage isolates only as far as picking a
  route, and stops there even when curiosity wants to keep going.
- It does not **design a fix.** A route that needs a design decision goes to
  `brainstorming`; triage does not weigh approaches itself.
- It does not **park a routed report.** Reporting the route and waiting for a "yes, go" is not
  one of triage's two outcomes — hand off or close. Once the route is picked, triage takes it.
- It does not **own a private interrogator.** The under-specified leg drives the shared
  `engineering:interrogating-requirements` primitive — the same one signal uses — rather
  than a triage-local copy, so the extraction logic lives in one place and cannot drift.
  Triage conducts the leg; it does not reimplement the interrogation.
- It does not **write specs.** `to-spec` is the plugin's only writer of Tier-1 specs;
  triage hands it material and never drafts one itself.
- It does not **keep any record outside the run directory.** No board, no queue, no
  external system — everything is a file under `.engineering/<run>/triage/`, and nowhere
  else.
