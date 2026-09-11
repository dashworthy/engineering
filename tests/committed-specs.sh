#!/bin/sh
# Committed specs: the `spec` skill, at the approval gate, writes the frozen approved spec to
# docs/specs/{slug}/spec.md and upserts its row into the dedicated ledger index docs/specs/toc.md
# (its own genre, kept separate from the feature-keyed docs/toc.md). This asserts the three moving
# parts: the row-format reference, the spec skill's approval-time write, and the ledger index scaffold.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

STF="$ROOT/skills/spec/references/SPECS-TOC-FORMAT.md"
SPEC="$ROOT/skills/spec/SKILL.md"
TOC="$ROOT/docs/specs/toc.md"

# (a) the ledger index row-format reference exists and defines its columns / upsert rule ----------
[ -f "$STF" ] || { echo "FAIL: $STF does not exist"; exit 1; }
stf() { tr '\n' ' ' < "$STF" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: SPECS-TOC-FORMAT.md missing anchor: $1"; exit 1; }; }
stf "Date"
stf "Shipped"
stf "spec.md"
stf "retro.md"
stf "upsert"        # rows are upserted (not appended blindly)
stf "full run id"   # keyed by the FULL dated run id, not the bare slug (collision-free)

# (b) the spec skill writes the committed copy + index row at the approval gate --------------------
sp() { tr '\n' ' ' < "$SPEC" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: spec SKILL.md missing anchor: $1"; exit 1; }; }
sp "docs/specs/"          # writes docs/specs/{slug}/spec.md
sp "same approval"        # the write is tied to the approval gate (unique to the new step)
sp "frozen"               # a frozen/immutable committed copy
sp "docs/specs/toc.md"    # upserts the ledger index row
sp "SPECS-TOC-FORMAT.md"  # composes the row-format reference
sp "lands on"             # rides the branch; lands on the trunk only when the PR merges (no orphan)

# (c) the ledger index scaffold exists with its header -------------------------------------------
[ -f "$TOC" ] || { echo "FAIL: $TOC does not exist"; exit 1; }
grep -qiF "Shipped" "$TOC" || { echo "FAIL: docs/specs/toc.md missing its header row"; exit 1; }

# (d) the loop closes: documenting flips the run's Shipped column at ship -------------------------
# The spec skill writes the row with Shipped: — ; documenting must update it to yes when it ships,
# or the row-format's Shipped promise is dead. Guard that documenting owns that update.
DOC="$ROOT/skills/documenting/SKILL.md"
dp() { tr '\n' ' ' < "$DOC" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: documenting SKILL.md missing anchor: $1"; exit 1; }; }
dp "docs/specs/toc.md"     # documenting updates the ledger index row
dp "flip its"              # flips the Shipped column (unique to the row-update sentence)
dp "SPECS-TOC-FORMAT.md"   # per the row-format reference

# (e) the ledger directory key is the FULL dated run id, not the bare slug (collision-free) --------
# The bare <topic> slug can collide across days and silently overwrite spec.md; the resolved rule is
# the full <YYYY-MM-DD>-<slug> run id. Both writers AND the row-format reference must agree on it —
# a bare-slug key in the format ref would still satisfy an "slug" substring grep, so pin <run-id>.
grep -qiF "<run-id>" "$SPEC" || { echo "FAIL: spec SKILL.md must key the ledger dir on the full run id"; exit 1; }
grep -qiF "<run-id>" "$DOC"  || { echo "FAIL: documenting SKILL.md must key the ledger dir on the full run id"; exit 1; }
grep -qiF "<run-id>" "$STF"  || { echo "FAIL: SPECS-TOC-FORMAT.md must key the ledger row on the full run id"; exit 1; }

echo "PASS committed-specs.sh"
