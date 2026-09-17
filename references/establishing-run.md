# Establishing or joining a run

Every entrance and phase works inside a run directory under `.engineering/`. The run-context script
is the one way to obtain it:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" <phase> <slug>
```

- It prints the absolute path of `.engineering/<run>/<phase>/` and creates the directory if needed.
- If a run is already active, the call **joins that run** and the `<slug>` you pass is ignored; only
  when nothing is active does it start a new run seeded from the slug.
- `<slug>` is a 2–4 word kebab-case handle you derive from the request (or the target under work).

Each caller passes its own `<phase>` and adds its own skill-specific steps after the call (seeding a
request file, a resume guard, and so on).
