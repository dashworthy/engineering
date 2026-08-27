# Audit checks

Detection cues and fix shapes for the six dimensions. Each entry: what it looks like on the page,
how to confirm it, and the fix to propose.

- [Anti-patterns](#anti-patterns)
- [Excessive verbosity](#excessive-verbosity)
- [Confusing logic](#confusing-logic)
- [Cross-skill duplication](#cross-skill-duplication)
- [Subagent economics](#subagent-economics)
- [Dead skills](#dead-skills)

## Anti-patterns

Start from the list in `writing-skills` (`## Anti-patterns` and the description/naming sections) and
flag each violation: a menu of libraries where one default belongs, references nested more than one
level deep, Windows-style paths, time-sensitive wording ("the new API", "as of last month"), a thin
or wrong-voice description, a bare-noun or vague name.

Structural anti-patterns that list does not name:

- **Caller back-reference.** A skill (the callee) names, in its own text, the skill(s) that invoke
  it — "Dispatched by X", "Invoked by Y", an enumerated list of the callers that hand work here. It
  is redundant (the caller already names the callee to invoke it), brittle (the link now lives in
  two places and goes stale when a caller is added or renamed), and in a `description` it is
  always-loaded cost for a fact the selecting agent never needs. **Fix:** replace the hardcoded name
  with the *role* — "the conductor", "the caller", "a discovery conductor", "the phase that reached
  it" — or drop the clause. A generic role carries the same meaning and survives a caller changing.
  A *forward* reference (a caller naming the callee it dispatches) is correct and stays.

- **Force inflation.** "YOU MUST" / "Never" / "Always" on more than the one or two rules that would
  cause real damage if skipped. Force that is everywhere is force nowhere — banner blindness. **Fix:**
  demote all but the genuine cliffs to plain guidance (see `writing-skills` degrees-of-freedom).

- **Unresolvable reference.** A link to a file that does not exist, or a relative path that resolves
  wrong from where the skill actually runs — most often a `references/foo.md` citation in a skill
  dispatched as a subagent, which stands in a directory it was never told, so the path resolves to
  nothing. Confirm the target exists relative to the skill's own directory; for a dispatched worker,
  the fix is an absolute path passed in the dispatch, or inlining the content and dropping the
  citation.

## Excessive verbosity

The tell is prose a capable agent didn't need: a paragraph defining an ordinary term, an explanation
of a common file format, a "why this matters" preamble, an example that repeats what the sentence
already said. A skill that reads like onboarding for a new hire is too long; a reference card for an
expert is the target.

Confirm before cutting: read the sentence and ask what the agent would do differently without it. If
nothing, it is verbosity. If it closes a specific failure — a rationalization, an easy-to-miss
constraint — it earns its place even when it reads as obvious.

**Fix shapes:** delete; compress two sentences to one; move a rarely-needed detail from `SKILL.md`
into a reference (progressive disclosure) so it costs nothing until reached; replace a described
format with a two-line example.

## Confusing logic

Look for control flow an agent can misread under load:

- An ordered task written as unordered prose — steps that must run in sequence with no numbers.
- An ambiguous conditional — "when appropriate", "if needed" with no test for *when*.
- A gate buried mid-paragraph, where a stop condition reads as an aside.
- A forward dependency — a step that relies on something defined several sections later.
- Two rules that appear to contradict without a stated precedence.

**Fix shapes:** number an ordered sequence; give a conditional a concrete test; pull a gate onto its
own line or heading; move a dependency ahead of what needs it; state which of two rules wins.

## Cross-skill duplication

Read the plugin's skills together and look for the same content in more than one: a shared procedure
re-explained, an identical reference paragraph, the same worked example, overlapping descriptions
that would both match the same task (a discovery collision — the agent can't tell which to load).

Judge whether the duplication is worth removing. Two skills briefly restating a shared principle in
their own context is often fine; a multi-paragraph procedure copied verbatim is not. The bar is the
same as in code: abstract when the repetition is real and will drift, not for its own sake.

**Fix shapes:**
- **One canonical owner.** Make one skill the single place a rule lives; the others link to it.
- **Shared reference.** Extract the common content to a reference file the duplicating skills each
  link (kept one level deep from each `SKILL.md`).
- **Sharpen overlapping descriptions** so each names the case it owns, removing the collision.

Weight these findings high: duplication removed from a `description` or a `SKILL.md` saves tokens on
every load of every skill that carried the copy.

## Subagent economics

Where a skill dispatches subagents, audit whether the dispatch pays for itself. The full model and
the break-even test are in [subagent-economics.md](subagent-economics.md). In short, flag:

- A subagent spawned for a single small file or a task whose payload is smaller than the subagent's
  fixed overhead.
- A subagent whose result the main thread needs in full anyway — no compression, so nothing was
  saved by moving it out.
- The whole skill re-injected into every subagent where a one-line instruction would do.
- Discovery (the same grep, the same directory read) repeated in every subagent when it could be run
  once and passed in.

**Fix shapes:** inline the work; pass the discovered context into the dispatch instead of re-running
it per subagent; slim the dispatch prompt to the one instruction the subagent needs; batch many
small items into one subagent, or across subagents only when parallelism collapses real wall-clock.

## Dead skills

A dead skill is one the selection never picks and nothing dispatches — its always-loaded
`description` costs tokens on every turn and returns nothing. This is a whole-skill judgment, one
altitude above the other five dimensions: make it once per skill, across the plugin.

Tells:

- **Unreachable description.** The `description` names no case a real task in the plugin's domain
  would contain, or every case it names a sibling's description also names and states more sharply —
  so the sibling always wins and this one never loads. (Where both descriptions still earn a place,
  that is a duplication collision to sharpen, not a dead skill.)
- **No inbound reference.** Grep the plugin — `plugin.json`, `commands/`, `README.md`, every sibling
  `SKILL.md` and reference — for the skill's name. A callee dispatched by a conductor is reached only
  by a caller naming it (a *forward* reference); zero inbound references means nothing routes work
  here. A skill discovered purely by its `description` is exempt from this tell — it needs a
  reachable description, not an inbound link.
- **Subsumed capability.** Everything the skill does, a sibling already does; there is no task for
  which this skill is the better choice.
- **Orphaned by a change.** A rename or split left the skill behind — superseded by its replacement,
  still on disk.

Confirm before proposing a fate: name a concrete task the skill is the best choice for. If you
can't — none its description would win, none a caller routes to it — it is dead.

**Fix shapes** — a dead skill's fix is its fate, not a reword. Put the three to the user through
`AskUserQuestion` (the propose step in `SKILL.md` covers the question shape):

- **Wire it in.** The skill is worth keeping but can't be reached. Repair discovery: sharpen the
  `description` and its trigger terms, rename to the activity it supports, or add the missing forward
  reference from the caller, command, or `plugin.json` that should route to it. Keeps the skill; fixes
  why nothing found it.
- **Fold into a sibling.** Its unique content is small and a sibling is where a task would look. Merge
  that content into the sibling, extend the sibling's `description` to carry the folded triggers, then
  delete the dead skill and every inbound reference.
- **Remove.** Nothing unique is lost. Delete the skill directory and scrub its name from `plugin.json`,
  `README.md`, and any caller or command that named it.

Weight a dead skill high: its `description` is always-loaded cost, so folding or removing it recovers
tokens on every turn — the same reason a `description` cut outranks a `SKILL.md` cut.
