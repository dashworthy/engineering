# Feature-doc template

Every feature doc renders to this shape at `docs/{domain}/{feature}/README.md`. Render it per the
shared conventions in `../../../references/consumable-markdown.md` — top-line hook, progressive
disclosure, **bold** key terms on first use, tables for enumerables, diagrams at the point of
introduction, worked examples. The shape below is genre-generic: it describes *how* to document
any feature, and carries no content from any one project. Fill every tier that earns its place;
a small feature earns fewer.

The three emoji tiers below are progressive disclosure made visible — a reader descends only as
far as they need. Keep them, in this order.

---

    # <Feature name>

    <One bold sentence: what this feature is, for a reader who has never seen it. The top-line
    hook — a reader could stop here and know whether to read on.>

    ---

    ## 🌟 Overview (plain-language)

    What the feature does and why it exists, in language a newcomer follows without the code
    open. Introduce the domain terms in **bold** on first use. Ground each behaviour in a short
    worked example — a concrete case walked through — rather than an abstract description. Where a
    flow or a decision has branches a list flattens, place a process-flow diagram here, at the
    point the flow is introduced (via `engineering:using-diagrams`).

    ## 🛠 Technical reference

    The detail a reader who will change the code needs.

    - **Data model.** Where the feature owns data, describe it and — where the shape carries the
      complexity — draw an ER diagram here (via `engineering:using-diagrams`).
    - **Architecture.** The classes/modules that do the work, as a table so a reader scans
      responsibilities row by row:

      | Area | Unit | Responsibility |
      |---|---|---|
      | <concern> | <class/module/function> | <what it owns; what it must not> |

    - **Boundaries & invariants.** Any rule a caller must respect, any isolation the feature
      enforces — stated plainly, so the next reader does not learn it by breaking it.

    ## 🚀 Development & testing

    How to work on the feature: how to run its tests, any setup or migration a change needs, and
    the commands that prove it works. Concrete commands, not prose about them.

    ## References

    Sub-documents under `docs/{domain}/{feature}/` that go deeper on one aspect, listed as a table
    per `REFERENCE-TABLE-FORMAT.md` so a reader (human or agent) jumps straight to the right file
    instead of grepping. Omit this section when the feature has no sub-docs.

---

Notes for the author:

- **Progressive disclosure is the spine.** Overview before technical reference before dev/testing
  — the newcomer's summary first, the schema and edge cases last. Never make a reader pass the
  hard material to reach the easy overview.
- **Optimise for agents and humans both.** The reference table and the architecture table exist
  so an agent can target its reading — cite the file that answers a question instead of forcing a
  codebase-wide grep. The doc is a guide to where to look; it never replaces reading the code.
- **Write like a person.** Plain, direct prose — no LLM-flavoured bloat, hedging, or filler. This
  is the anti-"claudish" bar the document phase's validation enforces.
