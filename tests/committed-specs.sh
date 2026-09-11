#!/bin/sh
# Committed specs: the `spec` skill, at the approval gate, writes the frozen approved spec to
# docs/specs/<run-id>/spec.md — a tracked, immutable snapshot beside the run's gitignored working
# copy. There is no ledger index file: the dated <run-id> directories are the ledger. This asserts
# the spec skill's approval-time write, that both writers key on the full dated run id, and that the
# once-built index stays removed.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

SPEC="$ROOT/skills/spec/SKILL.md"
DOC="$ROOT/skills/documenting/SKILL.md"

# (a) the spec skill writes the frozen committed copy at the approval gate -------------------------
sp() { tr '\n' ' ' < "$SPEC" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: spec SKILL.md missing anchor: $1"; exit 1; }; }
sp "docs/specs/"          # writes docs/specs/<run-id>/spec.md
sp "same approval"        # the write is tied to the approval gate (unique to the new step)
sp "frozen"               # a frozen/immutable committed copy
sp "lands on"             # rides the branch; lands on the trunk only when the PR merges (no orphan)

# (b) the ledger directory key is the FULL dated run id, not the bare slug (collision-free) --------
# The bare <topic> slug can collide across days and silently overwrite spec.md; the resolved rule is
# the full <YYYY-MM-DD>-<slug> run id. Both the spec writer and the documenting retro writer agree.
grep -qiF "<run-id>" "$SPEC" || { echo "FAIL: spec SKILL.md must key the ledger dir on the full run id"; exit 1; }
grep -qiF "<run-id>" "$DOC"  || { echo "FAIL: documenting SKILL.md must key the ledger dir on the full run id"; exit 1; }

# (c) there is no ledger index — the dated directories are the ledger ------------------------------
# The browsable toc index and its format reference were dropped; discovery is by listing the
# date-prefixed docs/specs/<run-id>/ directories. Guard that the index stays gone and that neither
# writer resurrects a toc row.
[ -e "$ROOT/skills/spec/references/SPECS-TOC-FORMAT.md" ] && { echo "FAIL: SPECS-TOC-FORMAT.md should have been removed with the index"; exit 1; }
[ -e "$ROOT/docs/specs/toc.md" ] && { echo "FAIL: docs/specs/toc.md should have been removed (no ledger index)"; exit 1; }
grep -qiF "docs/specs/toc.md" "$SPEC" && { echo "FAIL: spec SKILL.md still references the removed ledger index"; exit 1; }
grep -qiF "docs/specs/toc.md" "$DOC"  && { echo "FAIL: documenting SKILL.md still references the removed ledger index"; exit 1; }

echo "PASS committed-specs.sh"
