---
type: tool_used
tool: Skill
input_match: '"skill":\s*"(?:[\w-]+:)?(documenting|using-documentation)"'
min: 1
arm: both
---
Outcome, scored in BOTH arms — carries the delta. Reflecting a user-visible behavior change in
the feature docs is what the `documenting` phase (via the `using-documentation` producer) owns.
With the plugin one of them fires; without it neither exists and neither can fire. No base skill
shares these names, so the optional namespace is safe.
