---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?signal"'
min: 1
arm: both
---
Outcome, scored in BOTH arms — carries the delta. A vague feature ask must be routed through the
`signal` discovery entrance. With the plugin, `signal` fires; without it, the skill does not exist
and cannot fire — the with-arm scores and the without-arm does not.
