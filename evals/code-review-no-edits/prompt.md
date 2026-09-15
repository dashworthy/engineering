<!--
archetype: invocation-outcome
phase: code-review (deep, opt-in review)
The behavior proven IS the invocation plus a contract: a review request must reach the
code-review skill (which fans out reviewers and reports) and must NOT edit the source. outcome
(both arms) = the code-review skill fired; without the plugin it cannot. anti-behavior (both
arms) = the run edited no source file (code-review reports, it never fixes). Needs --scaffold.
-->
---
name: code-review-no-edits
tags: [code-review]
runs: 3
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---
I just wrote `report.py`. Give it a careful, thorough code review before I merge it — call out anything that could bite in production.
