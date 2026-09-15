---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?(signal|triage)"'
min: 0
max: 0
arm: both
---
Guard, scored in both arms: a documentation update is neither a new feature nor a defect, so the
run must not misroute into the `signal` or `triage` entrances. Passes when neither fired.
