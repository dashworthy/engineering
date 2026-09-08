# Anti-patterns checklist — the smells doctrine names, and the structural ones it doesn't

The lens for the anti-patterns check. Each entry: what it looks like on the page, how to confirm it,
and the fix to propose. Contents:

- Named writing-skills anti-patterns
- Caller back-reference
- Unresolvable reference
- Phantom gate
- Harness-specific tool naming

## Named writing-skills anti-patterns

Start from the list in `writing-skills` (`## Anti-patterns`) and flag each violation:

- **A menu of options.** Five libraries to choose from where one default with an escape hatch
  belongs. Choice is cognitive load the agent pays every time. **Fix:** name one default, park the
  rest in an "if you need X" aside or drop them.
- **Windows-style paths.** A `references\guide.md` where forward slashes work everywhere. **Fix:**
  forward slashes. Several instances may share one question — a mechanical fix.
- **Time-sensitive wording.** "The new API", "as of last month", "recently" — wording that rots.
  **Fix:** describe the current way plainly; park a deprecated approach in a labelled "old patterns"
  section.
- **Assuming tools are installed.** A script or command invoked with no statement of the dependency
  or how to get it. **Fix:** state the dependency and its install command before first use; note
  where the environment may have no network.

(The **description** and **name** anti-patterns — thin, wrong-voice, vague, bare-noun — belong to
`auditing-discoverability`. **Force inflation** belongs to `auditing-force-calibration`. **Nested
references** belong to `auditing-progressive-disclosure`. Do not double-report them here.)

## Caller back-reference

A skill (the callee) names, in its own text, the skill(s) that invoke it — "Dispatched by X",
"Invoked by Y", an enumerated list of the callers that hand work here. It is redundant (the caller
already names the callee to invoke it), brittle (the link now lives in two places and goes stale when
a caller is added or renamed), and in a `description` it is always-loaded cost for a fact the
selecting agent never needs.

**Fix:** replace the hardcoded name with the *role* — "the conductor", "the caller", "the phase that
reached it" — or drop the clause. A generic role carries the same meaning and survives a caller
changing. A *forward* reference (a caller naming the callee it dispatches) is correct and stays.

## Unresolvable reference

A link to a file that does not exist, or a relative path that resolves wrong from where the skill
actually runs — most often a `references/foo.md` citation in a skill dispatched as a subagent, which
stands in a directory it was never told, so the path resolves to nothing.

**Confirm** the target exists relative to the skill's own directory; for a dispatched worker, the fix
is an absolute path passed in the dispatch, or inlining the content and dropping the citation.

## Phantom gate

A skill that ends by handing control onward — invoke the next skill, or close with a written
disposition — but whose handoff prose leans on "stop", "job ends", or "no gate here" without stating
the seam ends in an *act* and without forbidding the "report the route, then ask whether to proceed"
non-outcome. The agent fills the vacuum with a generic confirm-before-continuing reflex and parks the
work — examined, routed, and left sitting.

**Confirm the seam carries no approval gate** before flagging: a seam that legitimately waits for
human sign-off (a spec gate, a plan gate) is a real stop, not this finding — the tell is a *no-gate*
seam where control is meant to flow on its own.

**Fix:** name the terminal act explicitly ("invoke X now" / "close with a disposition"), and state
that reporting the route and waiting for a "yes, go" is not one of the skill's outcomes.

## Harness-specific tool naming

A skill names a concrete tool — `AskUserQuestion`, `TodoWrite`, or any other tool that belongs to one
particular harness — as *the* way to meet a need every harness meets somehow (putting a structured
choice to the user, tracking a todo list). It breaks on any harness that names the capability
differently or doesn't carry that exact tool. A half-fix that only deletes the tool name and says
"ask the user" or "track progress" is not enough — that drops the instruction to actually look, and a
plain-prose question is exactly what this idiom exists to prevent (the user reads a wall of text
instead of picking off a menu).

**Fix — carry both halves of the idiom, phrased generically, never naming a sibling plugin's own
skill as the example:**

1. **Direct instruction to look.** Tell the agent to check what it has and use a fitting tool if one
   exists — "put it to the user as a structured choice, **using a tool** to ask it where one is
   available," or "track it in whatever todo list your harness provides." This is an instruction to
   search its own tool list, not a hedge that lets it skip straight to prose.
2. **A named fallback for when none exists.** State what happens when no such tool is available: fall
   back to the same content as plain text — still structured (a menu, not open prose) — and say the
   run is degraded rather than silently downgrading.

A concrete tool name may still appear once, parenthetically, anchored to "in this harness" — never as
the only instruction, with no capability-first fallback. When auditing a plugin that ships its own
skills side by side, citing one of its own sibling skills as a positive example of this idiom is
fine; a skill belonging to a *different* plugin is not a legitimate example to point to or depend on
— a plugin's doctrine must stand on its own if installed alone.
