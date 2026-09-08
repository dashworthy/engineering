# The check contract

The uniform interface between the `auditing-skills` orchestrator and every check. It is identical
for all checks, so the orchestrator knows nothing check-specific and a new check is "implement this
contract + add a menu row."

This is guardtower's facet contract adapted for an audit: a check is a **report-only reviewer** — it
finds problems and *proposes* fixes, but never edits. Applying an approved fix is the orchestrator's
job (its one-finding-one-question gate), so a Finding here carries the raw material that gate needs:
an estimated token saving and 2–3 concrete fix variants.

## Request — orchestrator → check

```
{
  check_file:  <absolute path to this check's check.md>,   // hand the path, not a copy — so its
                                                           // references/<checklist>.md and ../../*
                                                           // citations resolve from the check's own dir
  target:      <the skill dir(s) under audit>,             // one skill, or every skill in the plugin
  scope:       "skill" | "plugin",                         // a cross-skill check needs the whole plugin
  spec_ref:    writing-skills is the yardstick,            // the doctrine every check answers to
  caps: {
    top_n: <int>,                 // report at most this many findings, most severe first
    floor: "low" | "med" | "high" // drop findings weaker than this bar
  }
}
```

The orchestrator hands each check the **absolute path to its own `check.md`** (never a pasted copy):
a dispatched reviewer boots in a directory it was never told, so a `references/foo.md` citation only
resolves when the check knows where it stands. `caps` are passed in, not hardcoded per check, so the
discipline is tuned in one place. `target` and `scope` are a shared *read* — no check writes what
another reads, so parallel checks stay independent.

**One check is behavioral, not static: `auditing-pressure-test`.** It does not *read* `target` — it
*runs* the agent through the skill's real scenario under pressure (spawning its own fresh trial
subagents), so it is always dispatched, never inlined, and it is the audit's one expensive seam. It
still speaks this contract exactly: same Request, same Result, same Finding schema — its findings are
surviving rationalizations, and each `fix` is the wording change that closes one. The uniform contract
is what lets a behavioral seam ride the same reconcile-and-apply gate as the static ones.

## Result — check → orchestrator

```
{
  check:     <check name>,
  relevance: "ran" | { skipped: <one-line reason> },   // decided FIRST, before any lens work
  findings:  [ Finding, ... ],   // already floored and capped to <= top_n; [] is a valid clean result
  dropped:   <int>               // genuine above-floor findings the cap held back beyond top_n; 0 when
                                 // the cap wasn't hit — a count, never silently gone
}
```

There is no `artifact_path`: unlike guardtower, the audit does not write a durable per-check record.
Its findings feed the orchestrator's propose-and-apply gate in the same session, so the check returns
them in context and the orchestrator reconciles, ranks, and puts each to the user.

## Finding — the shared schema, every check

```
{
  severity:   "high" | "med" | "low",
  confidence: "high" | "med" | "low",   // the floor drops anything below caps.floor on the weaker of the two
  location:   <file:line, or skill/section — e.g. "auditing-skills/SKILL.md description">,
  claim:      <one sentence: what is wrong>,
  why:        <one sentence: the writing-skills rule broken, or the cost it carries>,
  saving:     <estimated token saving, weighted by load frequency: a description cut is worth more than
               a SKILL.md cut is worth more than a reference cut — see SKILL.md "Quantify and rank">,
  fix:        [ <2–3 concrete variants: reword / cut / extract-to-reference / merge-and-link>,
                recommendation first ]   // the raw material for the orchestrator's one-finding-one-question gate
}
```

`claim` and `why` must read on their own, for a user who did not write the skill and holds no shared
context. `fix` is a *proposal*, never applied by the check — the orchestrator owns the gate and the edit.

**Dead skills are the one exception.** A dead-skill finding's `fix` is not a reword but a **fate** —
wire it in / fold into a sibling / remove — and deleting or folding a skill rewrites inbound
references across the plugin. The orchestrator handles it as a question of fate, not a fix variant
(see `SKILL.md`), so the dead-skills check returns the candidate fate and its consequences, and the
orchestrator gates the deletion.
