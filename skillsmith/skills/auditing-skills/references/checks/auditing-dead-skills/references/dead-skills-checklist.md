# Dead-skills checklist — a whole skill no task ever reaches

The lens for the dead-skills check. A dead skill is one the selection never picks and nothing
dispatches; its always-loaded `description` costs tokens on every turn and returns nothing. This is a
whole-skill judgment — make it once per skill, across the plugin. Contents:

- The tells
- Confirm before proposing a fate
- The three fates

## The tells

- **Unreachable description.** The `description` names no case a real task in the plugin's domain
  would contain, or every case it names a sibling's description also names and states more sharply — so
  the sibling always wins and this one never loads. (Where both descriptions still earn a place, that
  is a duplication collision for `auditing-cross-skill-duplication` to sharpen, not a dead skill.)
- **No inbound reference.** Grep the plugin — `plugin.json`, `commands/`, `README.md`, every sibling
  `SKILL.md` and reference — for the skill's name. A callee dispatched by a conductor is reached only
  by a caller naming it (a *forward* reference); zero inbound references means nothing routes work
  here. A skill discovered purely by its `description` is exempt from this tell — it needs a reachable
  description, not an inbound link.
- **Subsumed capability.** Everything the skill does, a sibling already does; there is no task for
  which this skill is the better choice.
- **Orphaned by a change.** A rename or split left the skill behind — superseded by its replacement,
  still on disk.

## Confirm before proposing a fate

Name a concrete task the skill is the best choice for. If you can't — none its description would win,
none a caller routes to it — it is dead. This confirmation is the gate against proposing the deletion
of a skill that is merely quiet, not dead.

## The three fates

A dead skill's fix is its fate, not a reword. Return all three as the candidate `fix`, recommendation
first, each naming what it keeps and what it deletes; the orchestrator puts them to the user.

- **Wire it in.** The skill is worth keeping but can't be reached. Repair discovery: sharpen the
  `description` and its trigger terms, rename to the activity it supports, or add the missing forward
  reference from the caller, command, or `plugin.json` that should route to it. Keeps the skill; fixes
  why nothing found it.
- **Fold into a sibling.** Its unique content is small and a sibling is where a task would look. Merge
  that content into the sibling, extend the sibling's `description` to carry the folded triggers, then
  delete the dead skill and every inbound reference.
- **Remove.** Nothing unique is lost. Delete the skill directory and scrub its name from
  `plugin.json`, `README.md`, and any caller or command that named it.

Name the inbound references a fold or remove would have to scrub, so the orchestrator's apply step
does not leave a dangling name behind.
