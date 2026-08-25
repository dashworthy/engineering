# The Hardening Interrogation

Before any convention is written — on **every** path, since recording is the single writer —
a rough candidate is interrogated into a robust rule. A candidate arrives as a sentence
("controllers should use form requests"); a convention has to be sharp enough that a
subagent reading it months later applies it the same way the approver meant it. This file
fixes how that sharpening happens.

The interrogation pins three things and fills the matching fields of `STANDARDS-FORMAT.md`:
**What it is** (the positive boundary), **What it is not** (the negative boundary), and
**Robustness** — the edge cases, exceptions, and ambiguities that would otherwise let two
readers apply the rule two different ways.

## Method

Apply `interrogating-requirements`' method to a single convention: offer the conventional
default framing plus real alternatives plus an open option, invite a correction, ask **one
question per turn**, and mine each correction for the boundary it reveals rather than
accepting the reworded surface.

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
