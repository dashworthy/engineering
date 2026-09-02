# skillsmith

A plugin for writing skills that other agents can actually discover and follow — for
proving they do, and for auditing the ones you already have. It carries the craft of skill
authoring (what to write, how much, and how to shape it) alongside a method for
pressure-testing whether a finished skill survives contact with a distracted agent under
time and authority pressure, and an efficiency audit that buys back the tokens a grown
skill or plugin is wasting — down to pruning a skill that no longer earns its place.

## Skills

- **writing-skills** — author and edit a skill so an agent reliably finds it and follows
  it: conciseness, gerund naming, trigger-bearing descriptions, progressive disclosure,
  matching instruction force to the task's degrees of freedom, and evaluation-first
  iteration.
- **testing-skills** — verify a skill is discovered, read, and obeyed before you ship it,
  by running its target scenario with and without the skill and under pressure, then
  closing the rationalizations that let an agent skip it.
- **auditing-skills** — audit an existing skill or a whole plugin for efficiency and
  quality problems (anti-patterns, verbosity, confusing logic, cross-skill duplication,
  subagent usage that costs more than it saves, and dead skills no task ever reaches),
  propose each fix — or a dead skill's fate: wire it in, fold it into a sibling, or remove
  it — as an explicit choice put to the user, and apply the approved ones.

Each skill is a short `SKILL.md` overview that points to deeper `references/` files loaded
only when needed.
