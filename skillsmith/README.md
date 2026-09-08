# skillsmith

A plugin for writing skills that other agents can actually discover and follow, and for
auditing the ones you already have. It carries the craft of skill authoring (what to write,
how much, and how to shape it) alongside a single audit that buys back the tokens a grown
skill or plugin is wasting, prunes a skill that no longer earns its place, and — when you
opt into it — pressure-tests whether a finished skill survives contact with a distracted
agent under time and authority pressure.

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install skillsmith@dashworthy
```

## Skills

- **writing-skills** — author and edit a skill so an agent reliably finds it and follows
  it: conciseness, gerund naming, trigger-bearing descriptions, progressive disclosure,
  matching instruction force to the task's degrees of freedom, and evaluation-first
  iteration.
- **auditing-skills** — audit an existing skill or a whole plugin by fanning each check out
  as an independent auditor over a shared read of the target — eleven seams: ten **static**
  lenses (anti-patterns, verbosity, confusing logic, discoverability, progressive
  disclosure, force calibration, cross-skill duplication, subagent economics, runtime
  integrity, and dead skills no task ever reaches) plus one **behavioral** seam,
  **pressure-test**, that runs the agent through the skill's real scenario under pressure to
  see whether it is actually discovered, read, and followed. It proposes each fix, or a dead
  skill's fate (wire it in, fold it into a sibling, or remove it), as an explicit choice put
  to the user, and applies the approved ones.

Each skill is a short `SKILL.md` overview that points to deeper `references/` files loaded
only when needed. `auditing-skills` goes one step further, in guardtower's shape: each seam
is its own file under `references/checks/<check>/`, dispatched as an independent auditor
under a uniform contract, self-limiting at the source (relevance gate, cap, floor). The
static seams *read* the artifact; the pressure-test seam *runs* it — the audit's one
expensive, opt-in track — and both report their findings on the same contract.

## License

MIT. See [LICENSE](../LICENSE).
