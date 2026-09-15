<!--
archetype: invocation-outcome
phase: stacked pull requests
The behavior proven IS the invocation: asked to ship several dependent changes as a stack of
one-PR-per-change, the plugin reaches the using-stacked-pull-requests skill (which owns the
branch-and-PR mechanics). outcome (both arms) = that skill fired; without the plugin it cannot.
No base skill of this name exists, so the optional-namespace pattern is safe.
-->
---
name: stacked-pr
tags: [stacked-pr]
runs: 3
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
I've got three changes that build on each other — a schema migration, then the model that uses it, then the API endpoint on top. I want to ship them as a stack: one pull request per change, each based on the branch of the one before it, so they can be reviewed and landed in order. Set that up.
