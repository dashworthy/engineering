---
name: routing-review-disagree
description: Review feedback the user is skeptical of still routes to receiving-code-review (to verify the claim) — NOT to triage. This is the trap case.
tags: [routing, receiving-code-review, entrances, trap]
runs: 3
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

The reviewer on my MR said my approach to the retry logic is fundamentally wrong and that I should use the existing backoff util instead. Before I just do what they said, I want to actually verify whether they're right.
