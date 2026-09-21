#!/bin/sh
# Guard: every mermaid diagram in the docs must actually render on GitHub.
#
# GitHub draws mermaid only from a fence that is exactly ```mermaid, flush at column 0,
# opened with three backticks, and closed again. A fence that carries trailing text on the
# info line, sits indented, or is never closed is printed as source (and an unclosed fence
# swallows the rest of the document). This check enforces those structural rules across every
# tracked Markdown file — it is static (python3 stdlib only, no browser), matching the suite's
# no-extra-setup contract. The grammar rules inside a block live in using-diagrams/DIAGRAM-FORMAT.md.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

python3 - "$ROOT" <<'PY'
import os, re, sys

root = sys.argv[1]
DIAGRAM_TYPES = (
    "flowchart", "graph", "sequenceDiagram", "erDiagram", "stateDiagram",
    "stateDiagram-v2", "classDiagram", "gitGraph", "journey", "pie",
    "gantt", "mindmap", "timeline", "quadrantChart", "requirementDiagram",
)
FENCE = re.compile(r'^(\s*)(`{3,}|~{3,})(.*)$')

failures = []

def scan(path, rel):
    lines = open(path, encoding="utf-8").read().split("\n")
    open_fence = None  # (char, ticks, info, line_no, indent)
    for n, line in enumerate(lines, 1):
        m = FENCE.match(line)
        if not m:
            continue
        indent, ticks, info = m.group(1), m.group(2), m.group(3).strip()
        if open_fence is None:
            open_fence = (ticks[0], len(ticks), info, n, len(indent))
        else:
            oc, olen, oinfo, oline, oindent = open_fence
            # A fence closes only with the same char, >= as many marks, and no info string.
            if ticks[0] == oc and len(ticks) >= olen and info == "":
                open_fence = None
            # else: it is content inside the open block (e.g. a ```mermaid shown as source
            # inside a ```` outer fence) — leave the outer fence open.

    # Re-walk to inspect the mermaid openers themselves, tracking the same fence state so a
    # ```mermaid that is merely *content* of a longer outer fence is not judged as an opener.
    open_fence = None
    for n, line in enumerate(lines, 1):
        m = FENCE.match(line)
        if not m:
            continue
        indent, ticks, info = m.group(1), m.group(2), m.group(3).strip()
        if open_fence is None:
            first = info.split()[0] if info else ""
            if first == "mermaid":
                if len(ticks) != 3:
                    failures.append(f"{rel}:{n}: mermaid fence must use exactly three backticks")
                if ticks[0] != "`":
                    failures.append(f"{rel}:{n}: mermaid fence must use backticks, not tildes")
                if len(indent) != 0:
                    failures.append(f"{rel}:{n}: mermaid fence must sit at column 0 (GitHub prints an indented fence as text)")
                if info != "mermaid":
                    failures.append(f"{rel}:{n}: mermaid info string must be exactly 'mermaid', got '{info}'")
                # Capture the body to check it is non-empty and names a diagram type.
                body = []
                j = n
                while j < len(lines):
                    bm = FENCE.match(lines[j])
                    if bm and bm.group(2)[0] == ticks[0] and len(bm.group(2)) >= len(ticks) and bm.group(3).strip() == "":
                        break
                    body.append(lines[j])
                    j += 1
                text = "\n".join(l for l in body).strip()
                if not text:
                    failures.append(f"{rel}:{n}: mermaid block is empty")
                else:
                    head = text.split()[0].rstrip(";")
                    if head not in DIAGRAM_TYPES:
                        failures.append(f"{rel}:{n}: mermaid block does not start with a known diagram type (got '{head}')")
            open_fence = (ticks[0], len(ticks), info, n, len(indent))
        else:
            oc, olen, oinfo, oline, oindent = open_fence
            if ticks[0] == oc and len(ticks) >= olen and info == "":
                open_fence = None

    if open_fence is not None:
        oc, olen, oinfo, oline, oindent = open_fence
        label = (oinfo or (oc * olen))
        failures.append(f"{rel}:{oline}: fence opened with '{oc*olen}{oinfo}' is never closed (swallows the rest of the document)")

for dp, dn, fn in os.walk(root):
    if "node_modules" in dp or f"{os.sep}.git" in dp or ".claude" + os.sep + "worktrees" in dp:
        # prune noisy / vendored trees
        dn[:] = [d for d in dn if d not in ("node_modules", ".git")]
        continue
    dn[:] = [d for d in dn if d not in ("node_modules", ".git")]
    for f in fn:
        if f.endswith(".md"):
            p = os.path.join(dp, f)
            scan(p, os.path.relpath(p, root))

if failures:
    print("FAIL: broken mermaid / fences found:")
    for x in sorted(failures):
        print("  " + x)
    sys.exit(1)
print("PASS mermaid.sh")
PY
