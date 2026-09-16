---
name: routing-bug-triage
description: A reported defect with a reproduction should route to the triage entrance, not to feature discovery.
tags: [routing, triage, entrances]
runs: 3
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

The room scheduler is double-booking study rooms. Two groups showed up to the same room at the Dallas branch yesterday morning. This started sometime last week. Repro: create two bookings with overlapping time windows and both get assigned room 4471.
