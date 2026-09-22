# open-threads.md — shape, thread kinds, obligations

Mechanics for the `open-threads.md` working-state file described in `SKILL.md` (`## Capturing As You Go`).

## Shape

```markdown
# Open Threads — <slug>
Working state for this run. Not the deliverable; `brief.md` is.

## Coverage So Far
| Dimension | Status | Established |
|---|---|---|
| 1. Problem | filled | Support load from password resets, ~40/wk, felt by the 2-person helpdesk |
| 2. Users & Stakeholders | thin | Admins named; nobody named as sign-off yet |
| 3. Success Criteria | empty | — |
| 4. Constraints | empty | — |
| 5. Scope | empty | — |
| 6. Existing Context | empty | — |

## Open Threads
- [ ] **reset-volume-baseline** — 40/wk was offered with low confidence and never checked
      *Opened:* 2026-08-18 · *Kind:* unchecked-baseline
- [ ] **sso-vs-magic-link** — corrected my SSO baseline, never said why magic links were ruled out
      *Opened:* 2026-08-18 · *Kind:* corrected-not-dug
```

`Status` is `filled`, `filled (baseline, agreed)`, `thin`, or `empty` (defined in `## The Advancement Gate`): plain `filled` for a dimension the user narrated in their own words, `filled (baseline, agreed)` for one that reached its answer only by agreeing to your offered baseline. `Established` holds what the user actually said in their own words wherever you have it; for a `filled (baseline, agreed)` row, the baseline they agreed to.

## The four thread kinds

| Kind | Means |
|---|---|
| `corrected-not-dug` | A baseline was corrected but the reason behind the correction was never mined |
| `unresolved-conflict` | Two requirements collide and no condition has been found that resolves them |
| `next-probe` | Something identified as worth pursuing but not pursued — the obviously-next probe when the session ran out of time |
| `unchecked-baseline` | A figure or assumption offered with low confidence and never checked |

## Obligations

- **Anything noticed and not pulled goes in before the session ends** — the single rule that makes a ten-minute session compound instead of accumulate.
- **Close a thread by checking it off and moving what it produced into the coverage table. Never delete it.** The record of what was dangling is what makes the next session cheap.
- **Never draft `brief.md` prose here, and never write threads into `brief.md`.** Two files, two jobs.
