---
name: domain-modeling
description: "[Discovery] Crystallize how the project names things: maintain CONTEXT.md, the domain glossary that ties each term to where it shows up in code. Use when a new domain term appears or an existing name needs pinning down, so a later skill reads what something is called instead of re-deriving it. Writes CONTEXT.md at repo root; does not record decisions (recording-adrs), design interfaces (codebase-design), or write specs (to-spec)."
---

# Domain Modeling

Say this first, plainly: `Using the domain-modeling skill to update the project's domain model.`

This skill is the glossary application of the first-class-artifact doctrine —
[../recording-adrs/references/first-class-artifact.md](../recording-adrs/references/first-class-artifact.md).
`CONTEXT.md` follows the **lookup** profile: a living, current-state view, edited in place as
the domain's names settle and change. Its consumers resolve the *current* meaning of a term
from it — they do not cite a point-in-time entry the way an ADR is cited.

## What this guarantees

One thing: when a domain term needs a name, this skill writes it down in one place —
`CONTEXT.md` at the repo root — so the next skill that needs to know what something is called
can read it instead of re-deriving it or guessing.

## CONTEXT.md: the glossary

`CONTEXT.md` is a living list of the terms this project's domain actually uses, each one
tied to where it shows up in code — so a new contributor, or a later skill reading the
codebase cold, shouldn't have to guess whether "order" and "purchase" mean the same thing
here.

Write an entry when a term earns its place: it recurs, in conversation or in code, and
getting it wrong would cause real confusion — not every noun that turns up in a commit
message. Follow `CONTEXT-FORMAT.md`, in this same directory, for the file's shape; that
file is the source of truth for what a row needs, not this one.

**Intake at the term-introduction point.** The trigger is the moment a domain term first
earns its place — a new concept named in conversation or introduced in code. Update
`CONTEXT.md` then, in the same pass, not on a later cleanup that never comes. **Active
consumption** is the other half: a phase that needs to know what a term means resolves it
from `CONTEXT.md` (the lookup profile), rather than treating the file as something to read
only if it happens to exist.

## What this does not do

- It does not **record decisions.** An architecture decision with real alternatives is an ADR,
  and `recording-adrs` is its single writer. This skill names things; it does not record why a
  choice was made. When a naming choice was itself a decision worth recording, hand it to
  `recording-adrs`.
- It does not **design interfaces.** Shaping a module's boundary — what a caller has to
  know, what stays hidden — is `codebase-design`'s job. This skill may name the concepts an
  interface uses; it never designs the interface.
- It does not **write specs.** Turning accumulated material into the one Tier-1 document
  is `to-spec`'s job alone. A glossary entry might feed a spec later; this skill never
  produces the spec.
- It does not **explore what to build.** That's `signal` — it interrogates a request until
  the requirements and their order are settled. This skill runs after, or alongside: signal
  decides the work, this skill decides what the work is called.
- It does not gate anything on its own output. `CONTEXT.md` is a convenience for the skills
  that come after; a project with no `CONTEXT.md` isn't missing a prerequisite, it just hasn't
  accumulated one yet.
