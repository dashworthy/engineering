<!--
archetype: invocation-outcome
phase: entrance routing (feature / vague ask)
The behavior being proven IS the invocation: a vague feature ask must enter through signal, not
triage. outcome (both arms) = the signal skill fired; the without-plugin arm cannot fire it, so
the delta is the proof. anti-behavior (both arms) = triage did NOT fire (a feature is not a defect).
-->
---
name: routing-feature
tags: [routing]
runs: 3
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
We want some kind of saved-views feature for the analytics dashboard — so people can come back to a filter setup they use a lot. I haven't thought through the details yet. Can you take this on?
