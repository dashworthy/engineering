---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?finishing-a-development-branch"'
min: 0
max: 0
arm: both
---
Guard, scored in both arms: the request is specifically about the stacked-PR mechanics, so the
run must not detour into the generic branch-finishing skill instead. Passes when it never fired
(the without-plugin arm can't fire it either, so this guards the with-plugin path).
