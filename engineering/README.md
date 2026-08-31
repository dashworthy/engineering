# engineering

The software-development pipeline plugin of the `dashworthy` marketplace.

Two entrances open the work — `/signal` (discovery, for a feature or vague ask) and
`/triage` (problem isolation, for a reported defect). Both pass through a design dialogue
that recommends an approach, then a spec approved at the pipeline's first human-approval
gate, and a plan approved at the second. From there the work flows through TDD build and
documentation hardening. All artifacts are files; there is no issue-tracker integration. The
pipeline ends at a green, documented branch — deployment and release are out of scope.

| Phase | Skill(s) |
|---|---|
| Discover | `signal` (interrogate → sequence → design gate) |
| Triage | `triage` (verify → isolate → route) |
| Design | `brainstorming` → `to-spec` |
| Build | `writing-plans` → `tdd` · `code-review` → docs |

The full pipeline diagram and phase-by-phase walk-through live in the
[root README](../README.md).

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install engineering@dashworthy
```

## License

MIT. See [LICENSE](../LICENSE).
