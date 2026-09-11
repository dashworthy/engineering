# Review protocol (reference)

Reviews a change through **three independent lenses** — Standards, Spec, and ELI5 — each looked
at by its own sub-reviewer dispatched in parallel, then reconciled into one report. This file is
the **orchestrator**: it resolves what to review, fans out one subagent per lens, and merges the
returns. The judgement each lens applies lives in its own reference doc, not here.

## What this guarantees

One thing: given a change — a diff, a branch, a PR, whatever the caller points at — this skill
reviews it through three separate lenses and returns findings organized by which lens raised each
one, produced by independent sub-reviewers dispatched in parallel and reconciled into a single
report. No lens is silently dropped because its sub-reviewer came back empty; an empty return is
reported as a clean lens, not an absent one.

## The three lenses

Each lens is a self-contained reference under `references/lenses/`. A sub-reviewer is handed
exactly one of them plus the change (and the matched spec); it reviews that axis and nothing else.

- **`lenses/standards.md`** — is the code good on its own terms, spec or no spec: correct, clear to
  the next reader, carrying tests that would catch a regression, free of the recurring security
  mistakes, and following the conventions already around it.
- **`lenses/spec.md`** — does the change do what was actually asked, against the approved spec if
  one exists or the stated request if not. Where the Spec lens looks for that document, and what it
  does when none is found, is the lens doc's own concern — it reviews Standards-only on its axis and
  says so plainly rather than inventing a spec to check against.
- **`lenses/eli5.md`** — could a reader outside the team understand the docblocks: it surfaces
  existing docblock prose that fails to explain its symbol, and public symbols missing a docblock
  that should carry one. It flags; it never rewrites, and it never touches structured tags.

Keep the three separate in the report. A caller reading only the Standards findings should be able
to trust that nothing about scope, intent, or docblock prose is hiding in them, and so on for each
lens — that separation is why they are reviewed by different sub-reviewers rather than one reviewer
switching hats, where the louder question crowds out the quieter ones.

## The inline floor

On a small diff — a single file, roughly twenty changed lines or fewer, one hunk — three subagent
spin-ups plus a reconcile cost more than the review itself does. Below that floor, **apply all
three lenses yourself, inline**, and skip the fan-out; every lens still gets its full review, just
in one pass. Read the three lens docs and judge the change against each. Above the floor, fan out.

## Dispatching the sub-reviewers

Above the floor, dispatch **one sub-reviewer per lens, in parallel**, following
`using-parallel-agents` for how the fan-out and the return are structured — that skill owns the
mechanics; this file supplies the split (one lens each) and what every sub-reviewer needs: the
change to review, its one lens doc (`references/lenses/<lens>.md`, named by absolute path so a cold
subagent can resolve it), and the matched spec document (or the plain statement that none was
found, for the Spec lens).

Each sub-reviewer returns findings scoped to its own lens and nothing else, in the shared finding
grammar the lens docs define — file and location, what's wrong, why it bites. A reviewer that
notices a problem belonging to another lens hands it across as that lens's observation rather than
folding it into its own findings.

## Reconciling

Merging the three returns into one report is this skill's job, not something pushed downstream:
group findings by the lens that raised them, drop no lens that came back empty (report it clean),
and carry no duplicate across lenses. The result is one report a caller reads by axis.

## What this does not do

- It does not **fix what it finds.** A finding on any lens is a statement of what's wrong and why,
  handed back to whoever asked for the review. Applying the fix, deciding whether to apply it, and
  deciding whether a finding is worth blocking on belong to the caller, not to this skill.
- It does not **write the spec it's missing.** When the Spec lens comes up empty, that's the end of
  this skill's involvement with the gap — it reports Standards- and ELI5-only for that change and
  stops. Getting a spec written, if one is warranted, is a separate decision made elsewhere.
- It does not **rewrite the docblocks the ELI5 lens flags.** The lens surfaces which docblocks need
  work; the fix lands in the change like any other finding, resolved by the caller (in the build
  loop, in the diff), not by this skill.
- It does not **decide when a review happens.** Something else — a person, or whatever is driving a
  larger piece of work — decides a change is ready and calls this skill at that moment. It does not
  watch for changes on its own.
- It does not **stand in for sign-off.** A clean report on all three lenses is information a human
  or a downstream process uses to decide whether to proceed, not a merge switch this skill throws.
