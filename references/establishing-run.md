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

Each caller passes its own `<phase>` and adds its own skill-specific steps after the call. Three of
those steps are the same across entrances and live here canonically; a caller keeps only its own slug
or nuance and links back to this block.

## After the call — the shared setup steps

- **Seed the request file.** Write `00-request.md` into the run directory yourself, with the request
  verbatim, before the first question — so the original ask is on record, not paraphrased later.
- **Resume-guard on an existing brief.** If the directory already holds a `brief.md`, do not overwrite
  it — ask the user whether to resume that run.
- **Persist findings as found.** Everything the entrance produces goes into `.engineering/<run>/<phase>/`
  as it is found, not reconstructed afterward from memory.
