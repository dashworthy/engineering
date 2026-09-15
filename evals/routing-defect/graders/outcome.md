---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?triage"'
min: 1
arm: both
---
Outcome, scored in BOTH arms — carries the delta. The reported defect must be routed through
the `triage` entrance. With the plugin loaded, `triage` fires; without it, the skill does not
exist and cannot fire — so the with-arm scores and the without-arm does not. That gap is the
proof the plugin produced the routing.
