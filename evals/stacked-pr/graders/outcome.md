---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?using-stacked-pull-requests"'
min: 1
arm: both
---
Outcome, scored in BOTH arms — carries the delta. Shipping dependent changes as a linear stack of
one-PR-per-change is what `using-stacked-pull-requests` owns. With the plugin it fires; without it
the skill does not exist and cannot fire. No base skill shares this name, so the optional
namespace is safe.
