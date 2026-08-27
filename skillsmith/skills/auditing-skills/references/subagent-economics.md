# Subagent economics

When a skill tells the agent to dispatch a subagent, that dispatch has a fixed cost the skill pays
whether or not the work needed isolating. This reference is how to decide, during an audit, whether a
skill's subagent usage earns that cost — and what to propose when it doesn't.

## The two sides of the ledger

**Fixed cost of a dispatch** — paid up front, before the subagent does any useful work:

- **The subagent's system prompt.** A fresh agent boots with the full harness preamble and its tool
  schemas — a large constant, on the order of thousands of tokens, before it reads a single line of
  the task. Measure it for your harness rather than trusting a number here; it is the dominant term.
- **Re-injected instructions.** Whatever the skill tells the subagent to load — the skill itself, a
  reference, a long dispatch prompt — is spent again inside the subagent, on top of the copy already
  in the main thread.
- **Rediscovery.** A subagent starts cold. Any grep, directory read, or file open the main thread
  already did and the subagent must repeat to orient itself is paid a second time.

**What dispatch buys** — the only things on the other side:

- **Payload kept out of the main context.** The tokens the work would otherwise leave in the main
  thread — the source read, the intermediate reasoning, the scratch output — that instead stay in the
  subagent and never come back.
- **Compression.** The subagent processes a lot and returns a little. A reader that consumes 20 KB of
  source and returns a one-paragraph verdict compressed heavily; one that returns everything it read
  compressed nothing.
- **Parallelism.** Many independent items dispatched at once collapse wall-clock the main thread would
  otherwise spend serially. This buys time, not tokens.

## The break-even test

Dispatch pays only when **payload kept out of context, plus what compression saves, exceeds the fixed
cost** — or when parallelism across many items is the point and the token cost is accepted for speed.

The practical consequence: a subagent that reads one small file and returns most of it **loses**. The
fixed overhead — a system prompt measured in thousands of tokens — dwarfs the little that moved out of
context, and nothing was compressed. Isolation that small should be inline.

A rough anchor, to be replaced by a measurement of your own harness: if the payload a subagent would
move out of the main context is smaller than its fixed overhead, inline it. Dispatch earns its cost
when the payload is large, the return is much smaller than the input, or many items run at once.

## What to flag in a skill

- **Sub-scale dispatch.** The skill spawns a subagent for a single small file, a one-shot lookup, or
  any task whose payload is plainly under the fixed overhead.
- **No compression.** The subagent's result is returned to the main thread in full and used there —
  the work left context and came right back, saving nothing.
- **Fat re-injection.** Every subagent re-loads the whole skill (or a long reference) when a one-line
  instruction would carry the task.
- **Repeated discovery.** Each subagent re-runs the same grep or directory read the main thread — or a
  sibling subagent — already did.
- **Serial dispatch with no parallelism gain.** Subagents run one after another, so the wall-clock
  win that justifies token cost never materializes; inline would be cheaper and no slower.

## What to propose

- **Inline it** when the payload is below the fixed cost.
- **Pass discovery in** — run the grep/read once in the main thread and hand the result to the
  dispatch, instead of each subagent rediscovering it.
- **Slim the dispatch** to the one instruction the subagent needs; don't re-inject the whole skill.
- **Batch** many small items into one subagent, or fan out across subagents only where parallelism
  turns real serial wall-clock into concurrent work.
- **Keep it** when the numbers already favor dispatch — a large payload, a heavily compressed return,
  or a genuine parallel fan-out. Not every subagent is waste; the audit confirms the ones that pay.
