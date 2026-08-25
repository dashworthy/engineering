# Degrees of freedom

How tightly to constrain the agent, and how forceful your language should be. Both follow
from one question: how fragile is the task?

## The ladder

Picture the agent as a robot crossing terrain. Some terrain is an open field where many
paths reach the goal; some is a narrow bridge with cliffs on either side where exactly one
path is safe. Match your instructions to the terrain.

**High freedom — describe the goal, trust the path.** Use when many approaches are valid and
the right one depends on context the agent can read better than you can predict.

```
## Code review
1. Analyze structure and organization.
2. Check for bugs and edge cases.
3. Suggest readability and maintainability improvements.
4. Verify adherence to project conventions.
```

**Medium freedom — a pattern with room to adapt.** Use when a preferred shape exists but
details vary. Give a template or a parameterized script and say what may change.

```
Use this template, adjusting sections to the analysis:
def generate_report(data, format="markdown", include_charts=True): ...
```

**Low freedom — exact steps, no improvisation.** Use when the operation is fragile,
consistency is critical, or one wrong move is expensive.

```
Run exactly this, and do not add flags:
python scripts/migrate.py --verify --backup
```

Most skills mix levels: a high-freedom overall approach with one low-freedom step where the
cliffs are. Set each step to its own terrain rather than the skill to one level.

## Templates and examples

- **Template pattern.** Provide an output skeleton. Make it strict ("use this exact
  structure") for machine-consumed formats; make it a labelled default ("a sensible
  starting point — adapt to the case") where judgment should win.
- **Examples pattern.** When quality depends on style the agent must see rather than be
  told, give a few input/output pairs. Two or three concrete examples teach a format better
  than a paragraph describing it.

## The rule on force

**Reserve imperative force for low-freedom, safety-critical, and discipline-enforcing
skills. Let guidance and reference skills stay light.**

Force is language that removes the agent's discretion: "YOU MUST", "Never", "Always", "No
exceptions", "Delete it and start over". It exists to close off rationalization on a rule
that must hold even under pressure — a test-first discipline, a migration that must back up
first, a safety gate. On a narrow bridge, that is exactly right.

In an open field it backfires twice. It's wrong on its face — there isn't one mandatory path
— so it teaches the agent the skill exaggerates, which discounts its genuine warnings. And
force does not stack: if every line of every skill shouts, nothing stands out, and the two
rules that truly must not be broken drown in the noise. This is banner blindness. Imperative
force is a scarce budget — spend it on the few rules that would cause real damage if skipped,
and phrase everything else as the plain guidance it is.

So before writing "YOU MUST", ask: is this a cliff, or just the busiest path across an open
field? Only the cliff earns the imperative.
