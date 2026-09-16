---
type: tool_used
tool: Skill
input_match: '(?:[\w-]+:)?(signal|triage|receiving-code-review)'
min: 0
max: 0
arm: both
---

Anti-behavior indicator: none of the other three entrances (signal, triage, receiving-code-review) fired — a "nothing's broken, I just want to reshape this code" request must not be routed to the discovery, defect, or review-feedback entrance.
