# Auditing — Runtime integrity check

Say this first, plainly: `Using the skillsmith runtime-integrity check to audit this skill.`

## What this guarantees

One thing: given a skill that ships executable parts — scripts, or frontmatter beyond `name`/
`description` — this check finds defects in those parts: a script that punts on foreseeable errors or
carries voodoo constants, a path that won't resolve, frontmatter keys that don't validate, a `name`
that doesn't match its directory, an unstated dependency, a bare MCP tool name. It returns a short,
ranked list. It is **report-only**: it proposes, the orchestrator applies — and it never edits a
script's behavior.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** This check applies only to a skill that **ships scripts or
   runtime-affecting frontmatter**. A pure-prose skill whose frontmatter is only `name` +
   `description` has no executable surface — return `relevance: { skipped: "no scripts or runtime
   frontmatter" }` immediately. (`name`/`description` quality is `auditing-discoverability`'s, not
   this check's.)

2. **Apply the lens.** Work [references/runtime-integrity-checklist.md](references/runtime-integrity-checklist.md)
   against the skill's scripts, frontmatter, and dependency declarations.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema.

## What this does not do

- It does not **change what a script does.** Verify any proposed fix leaves behavior intact — this
  check reports defects and proposes fixes the orchestrator applies to *prose and structure*; a
  behavior change to a script is a code edit the audit does not make on its own.
- It does not **judge the name or description as discovery** — it checks only that the `name`
  mechanically matches its directory and the frontmatter validates; the *quality* of the name and
  description is `auditing-discoverability`'s.
