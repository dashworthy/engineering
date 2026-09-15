---
type: tool_used
tool: Skill
input_match: '"skill":\s*"engineering:code-review"'
min: 1
arm: both
---
Outcome, scored in BOTH arms — carries the delta. A deep-review request must reach the
plugin's `engineering:code-review` skill (which fans out specialized reviewers and reconciles one
report). The namespace is REQUIRED here, unlike routing's optional `(?:[\w-]+:)?`: a base
`code-review` skill exists independent of the plugin, so the without-plugin arm can fire *that*
one — matching a bare pattern and destroying the delta. Requiring `engineering:` scopes the
outcome to the plugin's skill, which only the with-plugin arm can fire.
