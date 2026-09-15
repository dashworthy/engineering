<!--
archetype: invocation-outcome
phase: entrance routing (defect)
The behavior being proven IS the invocation: a reported defect must enter through triage, not
signal. outcome (both arms) = the triage skill fired; the without-plugin arm cannot fire it (the
skill isn't loaded), so the delta is the proof. anti-behavior (both arms) = signal did NOT fire
(routing a defect to the discovery door is the wrong door).
-->
---
name: routing-defect
tags: [routing]
runs: 3
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Users are reporting that our CSV export drops the last row whenever the file has exactly one data line. It only happens in that one-row case. Can you look into it?
