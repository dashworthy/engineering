---
name: using-documentation
description: "The producer primitive for durable feature documentation: given a run's spec, plan, and the shipped whole-branch diff, write or surgically patch the feature doc under docs/{domain}/{feature}/README.md and upsert its row in docs/toc.md — a doc shaped for humans and agents to consume, so later work reads the map before it greps. Use from the documenting phase to produce or update a feature's documentation; it writes docs, it does not validate them (that is the documenting phase's fan-out) and it does not decide whether documentation is warranted (that is the phase's judged call)."
---

# Using Documentation

Say this first, plainly: `Using the using-documentation skill to write the feature's documentation.`

This is the plugin's single writer of durable feature documentation. Given what a run produced,
it renders one feature doc a human and an agent can consume and keeps the central table of
contents pointing at it. It writes; it does not judge whether the run warranted a doc (the
`documenting` phase decides that) and it does not validate what it wrote (the phase's fan-out does).

## What this guarantees

One thing: given a run's spec, plan, and the shipped whole-branch diff — plus a `{domain}/{feature}`
identity a human has minted — this skill leaves exactly one feature doc at
`docs/{domain}/{feature}/README.md` and exactly one corresponding row in `docs/toc.md`, both
describing what actually shipped, rendered per the shared consumable-markdown conventions.

## The contract

```
Inputs:  spec path · plan path · shipped whole-branch diff · {domain}/{feature} identity (human-minted)
Effect:  write | surgically patch   docs/{domain}/{feature}/README.md      (the feature doc)
         upsert row                 docs/toc.md                            (Feature | Description | Domain)
Rules:   reached     — the documenting phase decides whether the run warranted a doc before
                       invoking here; this skill is reached only on "yes" and always produces
         surgical    — on an already-documented feature, touch only what changed, then verify the
                       rest of the doc still holds against the change and flag drift
         human-mint  — never invent a domain or feature name; propose each with a recommended
                       answer as a structured choice and let the human pick
         locate      — detect and honor an existing docs tree; default to docs/ only when none exists
         compose     — render diagrams (ER, flow, state) via engineering:using-diagrams, not by hand
```

## Where it writes

Repo-root, repo-relative `docs/`. **Detect an existing docs tree first** and honor its layout;
default to `docs/` only when the project has none. The unit is the feature, at
`docs/{domain}/{feature}/README.md` — the `README.md` is the feature doc itself (it renders as the
folder's landing page and is the predictable file an agent opens first). Deeper nuance lives in
sibling `docs/{domain}/{feature}/<aspect>.md` sub-docs, surfaced through the feature doc's own
reference table (see `references/REFERENCE-TABLE-FORMAT.md`); depth is handled by sub-docs, never by
a rigid path segment. `{domain}` is a coarse, stable bucket that mirrors the grouping in
`docs/toc.md`.

Render the feature doc from `references/FEATURE-DOC-TEMPLATE.md` and the toc row from
`references/TOC-FORMAT.md` — do not reinvent either shape inline.

## Mint names with the human, never alone

The agent **never invents** a domain or a feature name. When a new feature doc (or a new domain)
is needed, propose the name — with a recommended answer derived from the spec's topic and the
work's shape — as a structured choice, following `engineering:using-questions` for how to shape
and ask it and its degraded-run fallback; the free-form escape lets the human name it themselves. The same
holds for offering to document an adjacent
established-but-undocumented feature the change sat next to: it is a proposal the human opts into
per feature, never a doc written unasked. Minting a domain or a feature is a human decision.

## Surgical on an update

Whether the run warranted a doc at all is the `documenting` phase's **judged** call, settled before
this skill is invoked (see *The contract* above) — this skill is reached only to produce.

When the feature is **already documented** and this run changed it, the update is **surgical**:
patch only what the change touched, then run an accuracy check over the rest of the doc against
the shipped diff — where a section no longer matches the code, flag the drift rather than silently
rewriting it. A fresh feature gets a full doc from the template; an existing one gets the smallest
true edit plus the drift flags.

## Upsert the table of contents

`docs/toc.md` is the one central index — every feature as a row (`Feature | Description | Domain`),
the name linking to its `README.md`. Upsert idempotently: a new feature adds a row, an existing
one updates its row in place; running twice on the same feature never doubles it. Follow
`references/TOC-FORMAT.md` for the row shape and the domain grouping.

## What this does not do

- It does not **decide whether to document.** The judged call — did this run change documented
  behavior — belongs to the `documenting` phase, upstream; this skill produces the doc once that call
  says yes.
- It does not **validate what it wrote.** Checking the doc for accuracy, structure, links, and
  scope is the `documenting` phase's fan-out (`references/validation-protocol.md`), not this skill.
- It does not **invent a taxonomy.** Domain and feature names are minted by the human; this skill
  proposes and records, it does not name.
- It does not **open a pull request or commit.** It writes files; the `documenting` phase and `finish`
  own how those files reach the repository.
