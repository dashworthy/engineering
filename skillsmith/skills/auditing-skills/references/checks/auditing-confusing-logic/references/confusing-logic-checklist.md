# Confusing-logic checklist — control flow an agent misreads under load

The lens for the confusing-logic check. The failure mode is a distracted agent reading fast and
taking the wrong branch, skipping a step, or missing a stop.

## The tells

- **An ordered task written as unordered prose** — steps that must run in sequence, with no numbers,
  so nothing signals the order matters.
- **An ambiguous conditional** — "when appropriate", "if needed", "as necessary" with no test for
  *when*. The agent has to invent the threshold.
- **A gate buried mid-paragraph** — a stop condition that reads as an aside, easy to slide past.
- **A forward dependency** — a step that relies on something defined several sections later, so the
  agent hits it before it has what it needs.
- **Two rules that appear to contradict** — with no stated precedence, so the agent can't tell which
  wins.
- **A pronoun or "it" with an ambiguous referent** across a step boundary, where the wrong binding
  changes the action.

## Fix shapes

- **Number an ordered sequence** — make the order explicit on the page.
- **Give a conditional a concrete test** — replace "when appropriate" with the observable that
  triggers it.
- **Pull a gate onto its own line or heading** — a stop condition should not be a clause inside a
  sentence about something else.
- **Move a dependency ahead of what needs it** — define first, use second.
- **State which of two rules wins** — name the precedence explicitly.

## Confirm before flagging

Read the passage as a rushed agent would, once, fast. If the wrong reading is plausible on that pass,
it is a finding. If the only misreading requires ignoring a nearby explicit signal, it is not — don't
manufacture ambiguity that isn't there.
