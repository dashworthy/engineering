# The Hardening Interrogation

Before any convention is written — on **every** path, since recording is the single writer —
a rough candidate is interrogated into a robust rule. A candidate arrives as a sentence
("controllers should use form requests"); a convention has to be sharp enough that a
subagent reading it months later applies it the same way the approver meant it. This file
fixes how that sharpening happens.

The interrogation pins three things, and its output fills the matching fields of
`STANDARDS-FORMAT.md`:

1. **What it is** — the positive boundary: the situations the rule governs and the form that
   satisfies it.
2. **What it is not** — the negative boundary: the adjacent cases it does *not* govern and
   the near-misses it is most likely to be over-applied to.
3. **Robustness** — the edge cases, exceptions, and ambiguities that would otherwise let two
   readers apply the rule two different ways.

## Method — offer a choice, then mine the correction

This is the same model `interrogating-requirements` uses, adapted to a single convention. Do
**not** ask open questions ("what is this convention?") — an open question gets a vague
answer and vague in is vague out. Instead, **offer the conventional default framing plus real
alternatives plus an open option, and invite a correction.**

- State a hypothesis as the **default**: what a competent practitioner would most likely mean
  by this candidate, with the reasoning visible.
- Give **real alternatives** — not strawmen — that a reasonable approver might actually pick.
- Always include an **open option** so the approver can say something neither of you framed.
- **One question per turn.** Never batch the three turns into one prompt; ten questions at
  once get a summary, one at a time gets a decision.
- **Mine the correction.** When the approver picks the default, that ground is standard and
  you move on cheaply. When they correct you, that is where the real boundary lives — dig
  into the reason, not just the corrected wording.
- **Reject non-answers.** "Whatever's typical," "you decide," "the usual" are not answers;
  restate the choice.
- When agreement arrives too fast on something that should have been hard, **ask what would
  make the rule wrong** — a plausible default waved through becomes a convention nobody
  actually chose.

## The three turns

**Turn 1 — what it is.** Offer the positive boundary as a default reading of the candidate.
> "I read this as: every controller action that accepts input binds to a dedicated form
> request class. Is that the rule, or is it narrower — say, only actions that write?"

**Turn 2 — what it is not.** Offer, as a default, the near-miss the rule is most likely to be
over-stretched to cover, and confirm it is out.
> "I'd assume this does *not* cover read-only actions with no input — those need no form
> request. Correct, or should it reach them too?"

**Turn 3 — robustness.** Probe the edges that would make the rule ambiguous or wrong: the
exception that has to be allowed, the boundary case two readers would split on, the
condition under which the rule does not apply. Offer default handling for each.
> "The likely exception is a webhook endpoint with framework-validated payloads. My default
> is to exempt those explicitly in the rule. Keep them in, or carve them out?"

The interrogation is done when all three are settled in the approver's own terms — at which
point the candidate, now with a sharp Rule / What it is / What it is not, goes to the
approval gate. A candidate that cannot survive this interrogation is not ready to be a
convention.
