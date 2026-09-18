# Feature-doc template

Every feature doc renders to this shape at `docs/{domain}/{feature}/README.md`. Render it per the
shared conventions in `../../../references/consumable-markdown.md` — top-line hook, progressive
disclosure, **bold** key terms on first use, tables for enumerables, diagrams at the point of
introduction, worked examples. The shape below is genre-generic: it describes *how* to document
any feature, and carries no content from any one project. Fill every section that earns its place;
a small feature earns fewer, and OPTIONAL sections are dropped outright when they don't apply.

This is the markdown twin of the designed feature-doc PDF template
(`skills/using-pdf-creation/references/templates/feature-doc.pdf.tsx`): the **same
section set and order**, rendered in plain markdown instead of react-pdf components — a component
map becomes a ```mermaid``` fence, a callout becomes a blockquote, a comparison card becomes a
two-column table. The three emoji tiers are progressive disclosure made visible — a reader descends
only as far as they need. Keep them, in this order.

---

    # <Feature name>

    <One bold sentence: what this feature is, for a reader who has never seen it. The top-line
    hook — a reader could stop here and know whether to read on.>

    ---

    ## 🌟 Overview (plain-language)

    What the feature does and why it exists, in language a newcomer follows without the code open.
    Introduce the domain terms in **bold** on first use. Ground each behaviour in a short worked
    example — a concrete case walked through — rather than an abstract description.

    State the **two or three core concepts** the rest of the doc builds on, each in a sentence — the
    mental model the reader should leave this section with:

    - **<Core concept A>** — <the first idea the rest of the doc builds on>.
    - **<Core concept B>** — <the second idea; together these frame everything below>.

    ## 🛠 Technical reference

    The detail a reader who will change the code needs. Descend from the shape of the system to its
    data, its flow, its contract, its parts, and finally its edges.

    ### Architecture at a glance

    Narrate how the pieces fit: the entry point, the core, what it depends on, and where the
    boundaries are — in **bold**, the class/module names a maintainer will grep for. Where the shape
    is more than a list can carry, draw a component map here (via `engineering:using-diagrams`):

    ```mermaid
    flowchart LR
        Client[Caller] --> Entry[Entry point]
        Entry --> Core[Core service]
        Core --> Store[(Data store)]
        Core --> Ext[External dependency]
    ```

    ### Data model  *(OPTIONAL — omit when the feature owns no data)*

    Call out the aggregate root, the ownership edges, and any invariant a reader must know
    (unique-per-X keys, denormalized FKs, nullable columns). Where the shape carries the complexity,
    draw an ER diagram here (via `engineering:using-diagrams`).

    ### Process flow

    The ordered stages from trigger to result, as a numbered list, then — where a flow branches in a
    way a list flattens — a pipeline diagram at the point it is introduced:

    1. **<Stage 1>** — <what it does and hands to the next>.
    2. **<Stage 2>** — <what it does>.

    ### Interfaces & payloads

    The wire contract: what each endpoint/interface carries and any field whose role isn't obvious
    from its name. Show a payload as a fenced code block tagged with the project's language, and put
    the per-field roles in a table beside it:

    | Field / key | What it carries | How it is used |
    |---|---|---|
    | `<key>` | <meaning> | <consumer behaviour> |

    Where the feature is built around one or more **interfaces** (a contract with several concrete
    implementations), document each interface as its own subsection — show the contract as a fenced
    code block, then list its implementations as a table so a reader scans them row by row:

    #### <Interface name>

    ```<lang>
    interface <InterfaceName> {
        <method>(<args>): <return>
    }
    ```

    | Implementation | What it does | When to use |
    |---|---|---|
    | `<ConcreteClass>` | <what this implementation does> | <the case it is the right pick for> |

    Worked example — a report renderer with three implementations:

    #### Renderer

    ```php
    interface Renderer {
        public function render(Report $report): string;
    }
    ```

    | Implementation | What it does | When to use |
    |---|---|---|
    | `JsonRenderer` | Serializes the report to a JSON string | API responses and machine consumers |
    | `HtmlRenderer` | Renders the report as a styled HTML page | The web dashboard view |
    | `CsvRenderer` | Flattens the report rows into CSV | Spreadsheet export and bulk download |

    ### Components & responsibilities

    The classes/modules that do the work, one line each — the boundary each one hides:

    | Class / module | Responsibility |
    |---|---|
    | `<Name>` | <what it owns; the one boundary it hides> |

    ### Boundaries & invariants

    Any rule a caller must respect, any isolation the feature enforces — stated plainly, so the next
    reader does not learn it by breaking it.

    ### Edge cases & failure modes

    What goes wrong and how the system responds — the outcomes a maintainer must act on. A blockquote
    per outcome reads as a callout:

    > **<Failure — e.g. zero results>.** <the condition, what it means, and the signal it emits.>

    > **<Degraded — e.g. truncation>.** <the condition and the action an owner should take.>

    ### Limits & configuration  *(OPTIONAL — omit when there are none worth noting)*

    The hard numbers and where they live — caps, defaults, and which are configurable vs fixed. Where
    two modes behave differently, a two-column table distinguishes them:

    | | <Mode A> | <Mode B> |
    |---|---|---|
    | <trait> | <A> | <B> |

    ## 🚀 Development & testing

    How to work on the feature: how to run its tests, any setup or migration a change needs, and the
    commands that prove it works. Concrete commands, not prose about them.

    ## References

    Sub-documents under `docs/{domain}/{feature}/` that go deeper on one aspect, listed as a table
    per `REFERENCE-TABLE-FORMAT.md` so a reader (human or agent) jumps straight to the right file
    instead of grepping. Omit this section when the feature has no sub-docs.

---

Notes for the author:

- **Progressive disclosure is the spine.** Overview before technical reference before dev/testing —
  the newcomer's summary first, the schema and edge cases last. Never make a reader pass the hard
  material to reach the easy overview.
- **Same shape as the PDF.** The section set and order mirror the feature-doc PDF template, so
  a feature reads the same whether it is exported as a designed PDF or read as markdown in the repo.
  Drop the OPTIONAL sections a feature doesn't need rather than padding them.
- **Optimise for agents and humans both.** The reference table and the per-interface implementations
  tables exist so an agent can target its reading — cite the file that answers a question instead of
  forcing a codebase-wide grep. The doc is a guide to where to look; it never replaces the code.
- **Write like a person.** Plain, direct prose — no LLM-flavoured bloat, hedging, or filler. This is
  the anti-"claudish" bar the document phase's validation enforces.
