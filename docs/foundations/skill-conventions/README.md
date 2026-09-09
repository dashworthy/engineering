# Skill conventions

**The shared contract every skill in this plugin is authored to — a frontmatter block that lets a skill be discovered by its description, a fixed way of announcing itself, and a body that states plainly what it promises and what it refuses — anchored by `using-skills`, the meta-skill the others follow.**

---

## 🌟 Overview (plain-language)

A **skill** is a folder under `skills/` holding a `SKILL.md` file. The plugin loader scans that directory one level deep, reads each skill's frontmatter, and offers the skill to Claude by its **description**. Nothing about a skill is discovered by its filename or its prose — only by the description string — so the conventions here exist to make that description carry its weight and to make the body predictable once a skill is chosen.

`using-skills` is the **foundation skill**: it runs before any other, and its job is to pick the skill that owns a request before Claude asks a clarifying question, opens a file, or writes a first sentence back. Because it governs how every other skill is found and invoked, it is also the worked model of the conventions — read it and you have read the shape the rest follow.

A well-formed skill starts like this:

```
---
name: build
description: "The build phase: execute an approved plan task by task — each driven through the TDD loop and gated by an internal review. Runs to completion with no human checkpoints. Use to build out a plan that already exists under .engineering/<run>/plan/."
---

# Build

Say this first, plainly: `Using the build skill to execute the plan.`

## What this guarantees
...
```

Three things make it well-formed. The **`name` matches the directory** (`build`'s folder is `build/`), so a skill can never be misfiled under a name it doesn't answer to. The **description states what the skill does and when to reach for it** — "execute an approved plan", "Use to build out a plan that already exists" — so Claude matches a request against stated scope rather than a guess about what a name implies. And the body opens with a **"Say this first, plainly:"** preamble, a fixed announcement that surfaces, in the transcript, which skill is now driving.

**How a skill is discovered and invoked.** Suppose a request arrives to break an approved design into ordered tasks. `using-skills` reads the request for the kind of work it is, compares it against each skill's description, and lands on `plan` because `plan`'s description claims exactly that scope. Claude then invokes `plan` through the Skill tool by its `name`. The description did the discovery; the `name` did the invocation; the preamble made the hand-off visible. A skill whose description didn't cover the request would never have been offered for it, however close its name sounded.

## 🛠 Technical reference

The convention set is small and mostly enforced by one shell test.

**Architecture.**

| Area | Unit | Responsibility |
|---|---|---|
| Foundation skill | `skills/using-skills/SKILL.md` | Finds and invokes the skill that owns a request before the first move; models the conventions the others follow; reports a gap when no skill's scope covers the request rather than forcing a fit. |
| Frontmatter test | `tests/frontmatter.sh` | Asserts every `SKILL.md` has a frontmatter block, that `name` equals the skill's directory, and that a non-empty `description` is present. Runs over one skill dir or every skill under `skills/`. |
| Skill index | `skills/README.md` | Human map of which skill belongs to which process group; records that skills live flat (the loader scans one level deep) and that supporting detail lives under each skill's own `references/`. |

**The conventions.**

| Convention | What it requires | Enforced by |
|---|---|---|
| `name` matches directory | Frontmatter `name` equals the folder holding the `SKILL.md`. | `tests/frontmatter.sh` (asserts `name == dir`) |
| Trigger-bearing description | One `description` string that states **what** the skill does, **when** to use it, and the **triggers** that should reach for it — so it can be matched on scope, not name. | `tests/frontmatter.sh` checks presence; the what/when/triggers content is an authoring discipline, visible across the sibling skills |
| "Say this first, plainly:" preamble | The body opens with a fixed announcement naming the skill now in use, so the hand-off shows in the transcript. | Authoring convention |
| "What this guarantees" | A section stating the single promise the skill makes. | Authoring convention |
| "What this does not do" | A section naming the skill's non-goals, so its boundary is explicit rather than learned by overreach. | Authoring convention |
| References one level deep | Supporting material lives in a sibling `references/` directory, not nested further; the `SKILL.md` stays the entry point. | Layout convention (`skills/README.md`) |

**Boundaries & invariants.**

- **`name` must equal the directory.** A skill's frontmatter `name` is not a free label; it is the folder it lives in. `tests/frontmatter.sh` fails the suite if they diverge.
- **The description carries what, when, and triggers.** Discovery reads only the description. A description that names the scope but not the moment to invoke it, or the trigger but not the scope, leaves the skill discoverable by name alone — which is exactly the failure mode `using-skills` guards against.
- **References stay one level deep.** A skill's deeper material sits in its own `references/` directory, loaded by the skill when needed; it does not nest into a tree a reader has to walk. The `SKILL.md` is the single discoverable entry point.
- **No skill is a fallback.** When no skill's stated scope covers a request, that absence is the finding — the work proceeds on the project's own conventions rather than being forced under the nearest-named skill.

## 🚀 Development & testing

The conventions are checked by shell tests, not a build. The frontmatter contract is one script:

```bash
# Validate one skill's frontmatter (name matches dir, description present)
sh engineering/tests/frontmatter.sh engineering/skills/using-skills

# Validate every skill under engineering/skills/
sh engineering/tests/frontmatter.sh
```

`engineering/tests/suite.sh` is the full foundation suite CI runs; it calls `frontmatter.sh` over a fixed list of the pipeline's phase skills as part of that pass (the no-argument form above validates *every* skill, `using-skills` included). Run the whole suite before relying on a change:

```bash
sh engineering/tests/suite.sh
```

To add or change a skill, edit its `skills/<name>/SKILL.md` — keep the frontmatter `name` equal to `<name>`, give the description a what/when/triggers scope, open the body with the "Say this first, plainly:" preamble, and put any deeper material under `skills/<name>/references/`. Then run the suite to confirm the frontmatter contract still holds.
