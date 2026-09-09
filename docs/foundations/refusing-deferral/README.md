# Refusing deferral

**A pipeline-wide rule that requested work can only end two ways — done in the diff, or surfaced as an explicit decision the human can see and revive — and never quietly slip into a third state that looks handled and isn't.**

---

## 🌟 Overview (plain-language)

Every phase of the pipeline is at some point tempted to **defer**: to notice a piece of committed work and, instead of finishing it, write it down somewhere and move on. A `TODO` in the code, a "next steps" bullet, a "follow-up PR" nobody has committed to, a finding waved off as "out of scope for now." Each of these converts an open task into something that *reads* as dealt with while no one actually owns it. That is the failure this foundation exists to stop.

The rule is simple. Committed work reaches one of exactly two honest ends:

| Fate | What it means |
|---|---|
| **Done and verified** | The work is closed in the change already in hand, and its verification output backs that up. |
| **Surfaced as a decision** | The work genuinely must wait, so it is named in a durable place the human reads — a spec's **Deferred** bucket, a spec's open questions, or an explicit choice put to the user — with the reason it waits and the **trigger** that revives it. |

There is no third fate. A task parked in a "later" with no owner and no date is not deferred on purpose — it is forgotten in slow motion, which is exactly the outcome the person relying on the session was trying to avoid. Deferring is a decision with a cost, and a decision with a cost belongs to the human, made where they can see it and reverse it — not made silently by the session and buried in a comment.

**Worked example.** Mid-build, a task's own review gate turns up a missing edge case — the change handles the happy path but drops an error branch the feature plainly needs. The tempting move is a `// TODO: handle the error case` and on to the next task; the task *feels* finished, the next one is more interesting. Refusing deferral rejects that. The gap is closed in the same task's diff, because it is small enough to log means it is small enough to just do. If — and only if — closing it genuinely can't happen here (a real dependency isn't ready), it doesn't become a `TODO`: it becomes a recorded decision in the spec's Deferred bucket, naming why it waits and what revives it, so the human owns the call. What never happens is the quiet drop.

## 🛠 Technical reference

Refusing deferral is a single skill that states the rule, cited by the phases where the temptation to punt actually arises. The skill owns the rule; each caller applies it to the specific work that phase can drop.

| Area | Unit | Responsibility |
|---|---|---|
| Rule | `skills/refusing-deferral/SKILL.md` | States the guarantee — work ends done-and-verified or surfaced-as-a-decision, never in a third "later" state — names what counts as surfacing (durable place, reason, revival trigger, a count of what was set aside), and lists the red-flag sentences that precede a punt. Owns the rule; does not do the citing skill's work. |
| Plan | `skills/plan/SKILL.md` | Forbids the plan reaching for deferral to make itself smaller: no requested item quietly moved to a Deferred bucket the spec didn't already carry, no gate that asks the user to defer in-scope work. Its coverage checks give requested work exactly two fates — a task, or a deferral the approved spec records — and restore any silently-missing one. |
| Build | `skills/build/SKILL.md` | Forbids punting a task's own gaps to "later." A finding from a task's review gate, a missing case, a follow-up the change plainly needs — each is closed in that task's diff or surfaced as an explicit decision, never left as a `TODO` or a hand-off nobody tracks. |
| Documenting | `skills/documenting/SKILL.md` | Treats the choice not to document a run as a visible decision — a recorded skip reason — never a silent pass. |
| Finish | `skills/finish/SKILL.md` | Refuses to let a branch integrate with work parked inside it. A whole-branch review finding is fixed before the branch re-enters the repository, not shipped as a stray `TODO` or a "follow-up PR" nobody committed to; anything that genuinely must wait is surfaced, not buried in the diff. |

**Boundaries & invariants.**

- **Two honest fates, and the third is refused.** Requested work is either done in the change or recorded visibly with a reason and a revival trigger. The third possibility — silently gone, whether as a `TODO`, a "next steps" bullet, an unwatched hand-off, or a quiet scope-down under time pressure — is the exact move this foundation forbids.
- **A deferral is the human's decision, not the session's.** The rule does not say "never defer." It says never defer *silently*, and never defer what you could just finish. A spec non-goal with a stated reason, a plan item ruled genuinely out of scope and written down as such, a human who says "not now" — these are decisions made in the open, which is the opposite of a punt. Authorization the human gave out loud is respected; the session inventing "later" on its own is not.
- **Surfacing has a definition.** It means visible to the human, in a durable place they will actually see, with a reason and a revival trigger — and, where the work was cut from a larger set, a count of what was set aside so its size is known. A capped list that reports how many findings wait behind the cap has surfaced them; one that looks complete has hidden them.
- **It is a rule, not a phase.** Refusing deferral is not a step in the pipeline that runs at a fixed point. It is a standing constraint the phases invoke whenever work is about to be parked, skipped, scoped down under pressure, or reported finished. It never does the owning skill's work — where the surfaced decision belongs in a spec, a plan, a review report, or a question to the user, it points there rather than restating what `spec`, `plan`, `build`, or `finish` already own.

## 🚀 Development & testing

The skill is prose, so its tests are structural assertions run by the shell suite.

```bash
# Run the full foundation suite (what CI runs)
sh engineering/tests/suite.sh
```

Two checks bear on this foundation:

- `engineering/tests/frontmatter.sh` validates the skill's YAML frontmatter — that `name:` equals its directory (`refusing-deferral`) and `description:` is present. `suite.sh` runs it against every skill, so the `refusing-deferral` skill is covered there.
- `engineering/tests/validate.sh` asserts the plan phase actually names `engineering:refusing-deferral`, so the citation from `skills/plan/SKILL.md` can't silently rot away.

To change the rule, edit `skills/refusing-deferral/SKILL.md`. To change how a phase applies it, edit that phase's `SKILL.md` — the callers cite the rule by its `engineering:refusing-deferral` name rather than restating it, so the wording lives in one place.
