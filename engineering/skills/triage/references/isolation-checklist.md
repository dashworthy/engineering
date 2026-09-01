# Isolation checklist

This is the checklist `triage`'s isolation step works through. It exists to keep
isolation as small as the routing decision needs — not a full diagnosis, just enough to
place a problem and pick a route with confidence.

## 1. Reproduce first

Before isolating anything, get the failure to happen under your own control — not just
the reporter's word for it. Three outcomes, and the route depends on which one is on the
table when this step ends:

- **Confirmed** — steps that produce the failure every time, or, for something
  intermittent, steps that make it show up often enough to study. Write the steps and
  the failing path down, on record rather than remembered.
- **Not reproducible** — the steps as given don't produce a failure. Don't round this up
  to "confirmed" because the report reads plausibly, and don't round it down to "closed"
  either. Note what was tried and what happened, and let the route carry the actual
  uncertainty.
- **Under-specified** — there isn't enough in the report to try anything. No steps, no
  expected result, no way to tell success from failure. This is its own outcome, not a
  stalled attempt at "not reproducible."

Nothing below this line starts until one of the three is written down.

## 2. Bisect by domain concept

Once a failure reproduces, narrow it — but only to where the problem lives conceptually,
not to a line of code. Use the names from the report and the code for the area the report
touches. "The retry logic in the sync
worker drops the second failure" is isolation enough to route on; finding the exact
conditional that drops it is one step further than triage needs to go.

Narrow from the reproduction itself — which file,
which function, which call path the failing steps actually exercise — to the same
conceptual grain.

## 3. Check for redundancy

Before assuming the report still describes current behavior, read the code it points at — a
report accurate when written can be stale by the time triage reaches it. If the failure no
longer reproduces because the underlying behavior already changed, that's the routing answer:
record the disposition and stop.

## 4. Check for prior rejection

A quick look, not a new investigation: has this exact ask already been raised and turned
down? A spec that considered the same change and rejected it, an earlier run in this same
project that closed it as out of scope — either one means the decision already exists and
doesn't need re-litigating from scratch. Found one? Route on it directly, and say which
prior decision is being followed. Found nothing is the normal result.

## When to stop

Stop isolating the moment the problem can be stated, in one sentence, as one row of
`references/spec-decision.md`. The row carries the route; picking it is that table's job,
not this checklist's. If no row can be stated at all, that is itself the finding — the
report is under-specified — and that answer, not more digging here, is what ends isolation.
