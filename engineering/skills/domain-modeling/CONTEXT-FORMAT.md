# CONTEXT.md Format

`CONTEXT.md` lives at the repo root. It is the one file where a person or a skill can
look up what this project calls things, without reading code to find out.

## Shape

```markdown
# <Project Name> — Domain Context

<One line: what this project's domain is, in the words its own team uses for it —
not a restatement of the tech stack.>

| Term | Meaning | Where in code |
|------|---------|----------------|
| <Term> | <What it means in this project, one or two sentences> | <Module, class, or file where the term is the primary, authoritative name> |
```

## How to keep it current

A glossary that drifts from the code misleads rather than staying silent, so update the row
in the same change as the code — when a rename lands, when a term's meaning narrows or splits
in two, when a term stops being used anywhere. A `Where in code` pointer that no longer
resolves flags a row due for a look before anyone trusts it again.
