---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?signal"'
min: 0
max: 0
arm: both
---
The wrong-door guard, scored in both arms: a reported defect must NOT be routed to `signal`
(the discovery entrance for features/vague asks). Passes when `signal` never fired. Catches a
with-plugin run that picks the wrong entrance.
