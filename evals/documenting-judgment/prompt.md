<!--
archetype: invocation-outcome
phase: documenting
The behavior proven IS the invocation: told a shipped change altered documented behavior, the
plugin reaches its documentation process (the documenting phase / using-documentation producer)
to write or update the feature doc — rather than hand-editing a doc ad hoc or skipping it.
outcome (both arms) = a documentation skill fired; without the plugin it cannot. No base skill of
these names exists, so the optional namespace is safe.
-->
---
name: documenting-judgment
tags: [documenting]
runs: 3
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
We just merged a change that adds a CSV-export option to the reports feature — it's a real, user-visible behavior change. Make sure our feature documentation reflects it.
