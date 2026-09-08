# Cross-skill duplication checklist — the same content in more than one skill

The lens for the cross-skill-duplication check. Read the plugin's skills together and look for content
that repeats. The bar is the same as in code: abstract when the repetition is real and will drift, not
for its own sake. Contents:

- What to look for
- Judging whether it's worth removing
- Fix shapes

## What to look for

- **A shared procedure re-explained** — the same multi-step process written out in two skills.
- **An identical reference paragraph** — the same rule or definition copied verbatim across
  references.
- **The same worked example** — one input/output pair appearing in two places.
- **Overlapping descriptions** — two skills whose `description`s would both match the same task, so
  the agent can't tell which to load. This is a *discovery collision*: distinct from a single thin
  description (which `auditing-discoverability` owns), because the problem is the pair, not either one
  alone.

## Judging whether it's worth removing

Two skills briefly restating a shared principle in their own context is often fine — a sentence each,
tuned to its setting, that will not drift. A multi-paragraph procedure copied verbatim is not: it will
drift, and then the two copies disagree. Flag the duplication that is **real and will drift**; leave
the incidental restatement.

## Fix shapes

- **One canonical owner.** Make one skill the single place a rule lives; the others link to it. Use
  when one skill is clearly the rule's home.
- **Shared reference.** Extract the common content to a reference file the duplicating skills each
  link — kept one level deep from each `SKILL.md`. Use when no single skill owns it and both need it.
- **Sharpen overlapping descriptions.** Reword each so it names the case it owns, removing the
  collision — each description ends up firing on its own task and not the other's.

Weight these high: a consolidation that removes a copy from a `description` or `SKILL.md` is paid back
on every load of every skill that carried it.
