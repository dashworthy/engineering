# Spec format

Every spec renders to this shape, at
`.engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md`. One format for all three entrances.

    # <Title> — spec

    **Date:** <YYYY-MM-DD>
    **Author:** <name>
    **Status:** Draft
    **Origin:** signal (discovery) | triage (<issue ref or one-line problem>)

    ## 0. ELI5
    The whole spec in plain language — as if explaining to a smart friend with no context on
    this codebase. In a few sentences and no jargon: what's broken or missing, what we're
    going to do about it, and how we'll know it worked. A reader should grasp the point of the
    entire spec from this section alone, before deciding whether to read the rest. This is a
    synthesis of the sections below, written last but placed first for easy consumption.

    ## 1. Problem
    What we are solving and why now. From a signal brief §1, or a triage problem statement.

    ## 2. Users & stakeholders
    Who is affected; who decides.

    ## 3. Goals & success criteria
    Observable outcomes. Each criterion is checkable.

    ## 4. Constraints
    Hard limits: platforms, versions, dependencies, deadlines, must-not-break.

    ## 5. Scope
    **In:** the committed work. **Out (non-goals):** each with a one-line reason.
    **Deferred:** parked, with the trigger that would revive it.

    ## 6. Approach (from the design dialogue)
    The approved approach and the alternatives weighed against it.
    For a triage-origin fix, the chosen fix strategy and why the smaller options were rejected.
    Where the approach turned on a module boundary, name it at decision altitude: which
    boundary, the shape the shape lenses chose (Strategy, Facade, plain split), and what a
    caller must know to use it — the commitment, not its code. The concrete signatures,
    fields, and code sketches that realize this boundary belong in the plan, not here; §6
    records *which* boundary and *why*, `plan` records *exactly how it's typed*.
    Where the approach has forks a linear list flattens, include a process-flow diagram
    (mermaid — a spec renders it); see `engineering:using-diagrams`.
    When the design breaks the work into increments (from the design dialogue), lay them out
    here as one ordered list: each increment named, what it delivers, and why it falls where it
    does in the sequence. The increments structure this one approach — the spec stays a single
    document, and `plan` will plan each increment in turn within a single plan. A design that
    lands in one pass has no increments and this list is simply absent.

    ## 7. Existing context
    Relevant modules. What the work touches.
    Where the work turns on the shape of the data, include an ER diagram (mermaid — a spec
    renders it); see `engineering:using-diagrams`.

    ## 8. Open questions
    Anything unresolved that does not block starting. Empty is fine.

Rules:
- §0 ELI5 is required in every spec and is never omitted — it is the plain-language summary
  the whole format exists to make easy to consume. Write it last, from the finished sections,
  but place it first. Keep it jargon-free; if a term can't be avoided, it doesn't belong here.
- The **Deferred** bucket in §5 is the sanctioned home for parked work — and the only honest one.
  Work waits here in the open, with the trigger that revives it, where the human sees and owns the
  decision; it never becomes a silent `TODO` in the code or a "later" no one tracks. Parking work
  anywhere else is the deferral `engineering:refusing-deferral` refuses.
- Increments, when the design has them, live in §6 as one ordered list and structure this
  single spec; they never become several specs.
- Never invent content the source material does not support; mark unknowns in §8.
- A triage-origin spec still fills every section; §1 is the reproduced problem, §6 the fix approach.
- The topic slug matches the run slug where possible (correspondence, not coupling).
- The status line is `Draft` when written; the spec gate flips it to Approved after
  the human approves the draft, minting the approval marker alongside the flip.
