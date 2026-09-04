# engineering

The software-development pipeline plugin of the `dashworthy` marketplace.

Three entrances open the work — `engineering:signal` (discovery, for a feature or vague ask),
`engineering:triage` (problem isolation, for a reported defect), and
`engineering:receiving-code-review` (for received review feedback). Each is a skill, invoked
at the start of the work. All three pass through a design dialogue that recommends
an approach, then a spec approved at the pipeline's first human-approval gate, and a plan
approved at the second. From there the work flows through TDD build and documentation
hardening. All artifacts are files; there is no issue-tracker integration. The pipeline
ends at a green, documented branch — deployment and release are out of scope.

| Phase | Skill(s) |
|---|---|
| Discover | `signal` (interrogate → design dialogue) |
| Triage | `triage` (verify → isolate → design dialogue) |
| Receiving review | `receiving-code-review` (aggregate → verify → design dialogue) |
| Design | `design` → `to-spec` |
| Build | `plan` → `tdd` · `code-review` → docs |

The full pipeline diagram and phase-by-phase walk-through live in the
[root README](../README.md).

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install engineering@dashworthy
```

## License

MIT. See [LICENSE](../LICENSE).
