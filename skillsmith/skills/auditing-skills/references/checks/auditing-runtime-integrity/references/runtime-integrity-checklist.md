# Runtime-integrity checklist — the executable parts, sound and portable

The lens for the runtime-integrity check. A skill's scripts and frontmatter are the parts that *run*,
so their defects fail deterministically rather than degrading gracefully. Grounded in writing-skills'
scripts-and-runtime doctrine. Contents:

- Scripts: solve, don't punt
- Scripts: no voodoo constants
- Scripts: execute vs. read intent
- Dependencies and the runtime
- Frontmatter and identity

## Scripts: solve, don't punt

A script should handle the error conditions it can foresee, not fail and leave the agent to
improvise. Flag a script that lets a foreseeable condition throw — a missing file, a denied
permission — with no fallback or clear message. **Fix (proposed, not silently applied):** handle the
condition (create/fall back) or emit a message that names the problem and the valid options. A
behavior change to a script is a code edit — propose it, don't apply it unasked.

## Scripts: no voodoo constants

Every magic number needs a reason in a comment. Flag `TIMEOUT = 47  # ?` and its kin — a value with
no justification the agent (or the next reader) can trust. **Fix:** add the one-line reason, or
replace the value if it's wrong; if neither is possible, that's a finding to surface, not paper over.

## Scripts: execute vs. read intent

Each script should say whether the agent **runs** it (the common case — reliable, its source never
enters context) or **reads** it as reference (only when the agent needs the logic, not the result).
Flag a script the skill invokes with no statement of which. **Fix:** state the intent at the call site.

## Dependencies and the runtime

- **Unstated dependency.** A script or command that assumes a package or binary is installed, with no
  statement of the dependency or its install command. **Fix:** state it before first use; note that
  some environments have no network, so anything needed must be declared.
- **Bare MCP tool name.** An MCP tool named as `tool` rather than fully-qualified `Server:tool`
  (e.g. `GitHub:create_issue`), which may not resolve when several servers are connected. **Fix:**
  fully-qualify it.

## Frontmatter and identity

- **Invalid or unknown frontmatter key.** A key the skill format doesn't define, or a malformed value.
  **Fix:** correct or remove it. (Verify the executable keys are byte-for-byte intact when proposing.)
- **`name` doesn't match its directory.** The frontmatter `name` and the skill's directory name
  disagree, which breaks how the skill is addressed. **Fix:** align them — and because the directory
  name is an identity, name the inbound references (`plugin.json`, `README.md`, callers) that must
  move with it, so the orchestrator's apply step scrubs them together.

This last item is *mechanical* identity — that the name matches and resolves. Whether the name is a
*good* name (gerund, names the activity) is `auditing-discoverability`'s call, not this one.
