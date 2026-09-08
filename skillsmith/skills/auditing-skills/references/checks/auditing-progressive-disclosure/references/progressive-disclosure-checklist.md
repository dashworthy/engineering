# Progressive-disclosure checklist — content in the layer that loads it when needed

The lens for the progressive-disclosure check. `SKILL.md` is a table of contents that orients the
agent and points to depth it loads only when the task needs it; references hold the depth. Content in
the wrong layer is paid too often, or hidden where a partial read misses it. Contents:

- Reference-depth detail in SKILL.md
- Monolithic SKILL.md
- References deeper than one level
- Missing table of contents
- Eager where lazy would do

## Reference-depth detail in SKILL.md

A long procedure, an exhaustive rule table, or a rarely-needed edge case sitting in `SKILL.md`, which
loads whenever the skill is used. The tell: a section a task reaches only occasionally, paid on every
load. **Fix:** extract it to a `references/<name>.md` linked from `SKILL.md`; the body keeps a
one-line pointer, the depth costs nothing until reached.

## Monolithic SKILL.md

A `SKILL.md` that never splits — hundreds of lines carrying everything, so the whole weight loads up
front. **Fix:** keep the overview and the high-frequency path in `SKILL.md`; move each self-contained
deep topic into its own reference.

## References deeper than one level

A reference that links to *another* reference, so a file is two hops from `SKILL.md`. Agents preview
nested files with partial reads and miss content. **Fix:** flatten — link the deep file directly from
`SKILL.md`, or inline it into the reference that pointed at it. (A dispatched sub-skill whose own
entry file is handed to a subagent is a different case: from that subagent, the entry file *is* the
root, so its own `references/` are one level deep. Confirm which case you're in before flagging.)

## Missing table of contents

A reference file over ~100 lines with no short contents list at the top. A partial read then reveals
only the first section, hiding the file's real scope. **Fix:** add a short bulleted table of contents
so a partial read shows the whole shape.

## Eager where lazy would do

Content the skill loads on every use that a task needs only sometimes — the inverse of a well-placed
reference. Includes a large example, a full checklist, or a dataset inlined into `SKILL.md`. **Fix:**
push it into a reference or a bundled file that costs nothing until something reads it; keep
`SKILL.md` lean.

## Confirm before flagging

A relayer earns its place only if the moved content is genuinely lower-frequency than what stays. Do
not extract a rule the skill needs on every run into a reference the agent then has to chase — that
trades load cost for a round-trip. Move what is *occasionally* needed; keep what is *always* needed in
the body.
