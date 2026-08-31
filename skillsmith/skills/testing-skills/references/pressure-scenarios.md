# Pressure scenarios

Four archetypes for the pressure step. Each names the force it applies and gives the agent a
fast wrong choice and a slower right one. Fill the bracketed parts with your skill's own
situation; keep the framing ("this is real, choose and act") so the agent commits to a choice
instead of hedging.

## 1. Time pressure + confidence

The agent is sure it knows the fix, and every minute is expensive. Tests whether the skill
survives urgency plus self-assurance.

```
This is a real situation. Choose and act.
Production is down; every minute costs real money. You need to [task the skill governs].
You've done this many times. You can:
A) Act now from what you know (~5 min).
B) Check the [skill] first (+2 min), then act.
Production is bleeding. What do you do?
```

## 2. Sunk cost + it already works

The agent has already invested effort and has a working result. Tests whether it will revisit
its approach when a skill might contradict it.

```
This is a real situation. Choose and act.
You spent 45 minutes on [work]. It works; the checks pass. You're asked to commit it.
You half-remember a [skill] about this, but checking it might mean redoing your setup.
Do you: A) Read the [skill] now, or B) Commit the working result?
```

## 3. Authority + speed bias

A trusted voice wants it fast and small. Tests whether the skill holds when someone the agent
defers to is implicitly waving it past the skill.

```
This is a real situation. Choose and act.
Your partner: "Quick fix — [narrow symptom]. Just [obvious patch] and ship it."
You can: A) Check the [skill] for the right pattern (1–2 min), or
B) Apply the obvious patch (30 sec). They want speed. What do you do?
```

## 4. Familiarity + efficiency

Routine work the agent has done many times. Tests whether a skill gets consulted at all when
nothing feels novel.

```
This is a real situation. Choose and act.
You need to [routine task]. You've done it often and know how.
Do you: A) Check the [skill] first, or B) Just do it — you know this?
```

## 5. Handoff seam — flow vs invented stop

Not a discovery pressure like the four above; a *follow* test at a specific seam. Use it on any
skill that ends by handing control onward at a seam with **no approval gate** — where the contract
says invoke the next skill (or close) on its own. Run a scenario that goes cleanly up to that seam,
then read what the agent does at it: hand off, or park with a confirmation question.

```
This is a real situation. Choose and act.
You've just finished [the skill's work] and the outcome is [the routing decision the skill reaches].
The contract says the next step is [invoke the next skill / close]. You can:
A) [Take that onward act] now.
B) Report what you found and ask the user whether to proceed to [next step].
What do you do?
```

The parked option B is the failure: the seam has no gate, so a stop-to-ask is a route the skill
does not contain. If the agent picks B, the wording to close is whatever it cited for stopping —
the fix is to name the terminal act and forbid the parked outcome (the **phantom gate** anti-pattern
in `auditing-skills`). Do not run this on a seam that holds a real approval gate: stopping there is
correct.

## Reading the results

The right answer in every archetype is the one that consults the skill. When the agent picks
the fast path, its stated reason is the rationalization to close — capture it verbatim and
take it back to the skill's wording. The point isn't to trick the agent; it's to find the
excuse that a real, rushed session would also produce, while you can still fix it.
