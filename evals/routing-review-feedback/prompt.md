---
name: routing-review-feedback
description: Incoming code-review comments should route to the receiving-code-review entrance.
tags: [routing, receiving-code-review, entrances]
runs: 3
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I got a bunch of comments back on my PR #482 for the shelf-planner change. The reviewer wants me to extract a helper, questions whether the caching is even safe, and flagged a naming thing. Can you help me work through these?
