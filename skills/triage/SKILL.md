---
name: triage
description: "The defect entrance: verify a reported problem reproduces, isolate it to a domain concept, then hand it to the shared design dialogue. Use when a bug or defect is reported. One of three entrances; converges on brainstorming and never invokes another entrance (never hands off to signal)."
---

# triage

Say this first, plainly: `Using the triage skill to verify and isolate the defect.`

Triage a reported defect. triage is one of the three engineering entrances: it **shapes context**
from a defect report — verifying and isolating it — then hands that context to the shared design
dialogue. It runs the same beats every entrance does — establish a run, shape context, hand to the design
dialogue — and only how it shapes context is particular to triage.

Work the beats in order.

## 1. Establish or join a run

Before reading the report closely, get somewhere to put what you find:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" triage <slug>
```

This prints the absolute path of `.engineering/<run>/triage/` and creates it if it doesn't exist
yet. If a run is already active — started by `signal`, or by an earlier triage pass on the same
problem — this call joins it and the `<slug>` you pass is ignored. If nothing is active, it starts
one, seeded from a kebab-case slug you derive from the report in a couple of words.

Everything triage produces — reproduction notes, isolation, the routing decision and why — goes
into `.engineering/<run>/triage/` as it's found, not reconstructed afterward from memory.

## 2. Shape context — verify, reproduce, isolate

This is the beat particular to triage. Isolate only as far as the hand-off needs: enough to place
the problem at a domain concept and hand it on with confidence, and no more. Triage is not
diagnosis — finding the exact conditional is one step further than triage usually goes; when the
hand-off needs the root cause pinned down first, follow `references/diagnosing.md` (reproduce,
hypothesize, isolate, confirm with evidence) to shape it before handing off.

**Reproduce first.** Before isolating anything, get the failure to happen under your own control —
not just the reporter's word for it. Establish which of three outcomes is true, and write it down
before anything below this line starts:

- **Confirmed** — steps that produce the failure every time, or, for something intermittent, steps
  that make it show up often enough to study. Write the steps and the failing path down, on record
  rather than remembered.
- **Not reproducible** — the steps as given don't produce a failure. Don't round this up to
  "confirmed" because the report reads plausibly, and don't round it down to "closed" either. Note
  what was tried and what happened, and let the hand-off carry the actual uncertainty.
- **Under-specified** — there isn't enough in the report to try anything: no steps, no expected
  result, no way to tell success from failure. This is its own outcome, not a stalled attempt at
  "not reproducible."

**Bisect by domain concept.** Once a failure reproduces, narrow it — but only to where the problem
lives conceptually, not to a line of code. "The retry logic in the sync worker drops the second
failure" is isolation enough to hand off on; finding the exact conditional that drops it is one
step further than triage needs to go. Narrow from the reproduction itself — which file, which
function, which call path the failing steps actually exercise — to that same conceptual grain.

**Check for redundancy.** Before assuming the report still describes current behavior, read the
code it points at — a report accurate when written can be stale by the time triage reaches it. If
the failure no longer reproduces because the underlying behavior already changed, record that and
say so.

**Check for prior rejection.** A quick look, not a new investigation: has this exact ask already
been raised and turned down — a spec that considered the same change and rejected it, an earlier
run that closed it as out of scope? If so, say which prior decision is being followed rather than
re-litigating it. Finding nothing is the normal result.

**When expected behavior is unclear**, and only then, synthesize it with the user before handing
off: load the shared discovery reference (`${CLAUDE_PLUGIN_ROOT}/references/interrogating-requirements.md`) and drive it (it self-drives
the interrogation and writes the requirements, brief.md §1–§6, into this run's `triage/`
directory). This is triage's own discovery leg — it is **not** a hand-off to `signal`; the two
entrances are distinct and never invoke each other.

## 3. Hand to design

Once the defect is verified and isolated far enough to design a fix against, hand that context to
the shared design dialogue — invoke `engineering:brainstorming` now. Everything converges there;
there is no routing table and no quick-fix side door, and there is no gate at this seam. Approval
lives downstream — the spec gate in `spec`, the plan gate in `plan` — never in triage
and never in brainstorming. Reporting the isolation and asking whether to proceed is not a move
here: once the context is shaped and written into the run, invoke brainstorming.

A report that turns out **Not reproducible**, already fixed, or already rejected does not go to
design — record the disposition in `.engineering/<run>/triage/` and close it with the reason
on record. Either outcome — handed off, or closed with a written reason — leaves no report sitting
unexamined.

If the report in hand is unclear or empty, ask the user what's going wrong before proceeding.
