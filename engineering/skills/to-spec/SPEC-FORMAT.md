# Spec format

`to-spec` renders every spec to this shape, at
`docs/dashworthy/engineering/specs/<YYYY-MM-DD>-<topic>.md`. One format for both entrances.

    # <Title> — spec

    **Date:** <YYYY-MM-DD>
    **Author:** <name>
    **Status:** Draft
    **Origin:** signal (discovery) | triage (<issue ref or one-line problem>)

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
    The approved approach and the alternatives weighed against it (from `brainstorming`).
    For a triage-origin fix, the chosen fix strategy and why the smaller options were rejected.
    Where the approach has forks a linear list flattens, include a process-flow diagram
    (mermaid — a spec renders it); see `engineering:using-diagrams`.

    ## 7. Existing context
    Relevant modules, `CONTEXT.md` terms, ADRs. What the work touches.
    Where the work turns on the shape of the data, include an ER diagram (mermaid — a spec
    renders it); see `engineering:using-diagrams`.

    ## 8. Open questions
    Anything unresolved that does not block starting. Empty is fine.

Rules:
- Never invent content the source material does not support; mark unknowns in §8.
- A triage-origin spec still fills every section; §1 is the reproduced problem, §6 the fix approach.
- The topic slug matches the run slug where possible (correspondence, not coupling).
- The status line is `Draft` when the spec is written; the spec gate in `to-spec`
  flips it to Approved only after the human approves the draft and the run's spec-approval
  marker (`.engineering/<run>/to-spec/APPROVED.md`) is minted. See `SKILL.md`'s spec-gate rule —
  the marker and the `Approved` status are promoted together, never on the assumption that
  reaching `to-spec` implies approval.
