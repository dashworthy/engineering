---
name: routing-dislike-simplify
description: An "I dislike this existing code, help me reshape it to my liking" ask should route to the simplify entrance (refactor discovery), not to triage, signal, or receiving-code-review.
tags: [routing, simplify, entrances]
runs: 3
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I keep coming back to `ShelfPlanner` and I just don't like it. The retry logic is hand-rolled right there in the method, and the whole thing feels more tangled and clever than it needs to be. Nothing's broken — I just want to reshape it into something more to my liking. Can you help me clean it up?
