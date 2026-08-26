# Scripts and runtime

Some skills ship executable scripts alongside their instructions. A script is more reliable
than code the agent regenerates each time, spends no context on its own source, and behaves
the same on every run. This file covers authoring them well.

## Solve, don't punt

A script should handle the error conditions it can foresee, not fail and leave the agent to
improvise. If a file might be missing, create it or fall back; if a permission might be
denied, say so and offer an alternative. Punting ("just let it throw and the agent will
figure it out") turns a deterministic tool back into a guess.

```python
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"{path} not found, creating empty")
        open(path, "w").close()
        return ""
```

## No voodoo constants

Every magic number needs a reason in a comment. If you can't justify a value, the agent
can't either, and neither of you should be trusting it.

```python
# HTTP calls usually finish within 30s; the margin covers slow links.
REQUEST_TIMEOUT = 30
# Most transient failures clear by the second retry.
MAX_RETRIES = 3
```

`TIMEOUT = 47  # ?` is a liability, not a setting.

## Say whether to run it or read it

Make the intent explicit for each script:

- **Execute** (the common case): "Run `analyze_form.py` to extract the fields." Reliable,
  cheap, and its source never enters context.
- **Read as reference**: "See `analyze_form.py` for the extraction algorithm." Only when the
  agent needs the logic, not the result.

## Plan, validate, execute

For batch, destructive, or high-stakes work, have the agent write its plan to a structured
file, validate that file with a script, and only then execute. The intermediate artifact is
inspectable and reversible: errors surface before anything is touched, and the validator's
messages should name the specific problem and the valid options.

## Dependencies and the runtime

- **Don't assume packages are installed.** State them and the install command; note that some
  execution environments have no network access, so anything needed must be declared.
- **Fully-qualify MCP tool names** as `Server:tool` (e.g. `GitHub:create_issue`). A bare tool
  name may not resolve when several servers are connected.
- **The filesystem model is what makes progressive disclosure work.** Only skill metadata is
  preloaded; `SKILL.md` and reference files are read on demand; scripts run without their
  source entering context, so only their output costs tokens. Large reference files and
  datasets cost nothing until something reads them — bundle generously, but keep `SKILL.md`
  itself lean.
