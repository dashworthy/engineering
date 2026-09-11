#!/bin/sh
# RETRO-FORMAT.md is the retro.md contract: the reference doc `documenting` composes to write
# docs/specs/{slug}/retro.md. It must exist and carry its whole shape — the front-matter spine, the
# Group-A per-section accuracy verdicts (mirroring the spec's own sections, with a closed verdict
# set), and the five Group-B cross-cutting axis sections. The producer/consumer boundary between the
# documenting phase (writer) and the future engineering-retro analyzer (reader) lives here.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
RF="$ROOT/skills/documenting/references/RETRO-FORMAT.md"

[ -f "$RF" ] || { echo "FAIL: $RF does not exist"; exit 1; }

flat() { tr '\n' ' ' < "$RF" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: RETRO-FORMAT.md missing anchor: $1"; exit 1; }; }

# --- front-matter spine: only facts stable & knowable at write time ---
flat "spec:"          # the paired spec slug (join key to docs/specs/<slug>/spec.md)
flat "shipped:"       # did the run ship (boolean)
flat "diff:"          # the shipped-diff reference (commit range / PR)

# --- Group A: per-section accuracy, body mirrors the spec's own sections ---
flat "mirror"         # the body mirrors the spec's own section structure
# the closed four-value verdict set (categories stay coarse on purpose)
flat "held"
flat "drifted"
flat "underspecified"
flat "n-a"

# --- Group B: the five cross-cutting axis section headings ---
flat "Process friction & cost"
flat "Rework & churn"
flat "Scope fidelity"
flat "Gate correction load"
flat "Assumption & open-question outcomes"

# --- format discipline ---
flat "terse"          # terse-by-default: an axis with nothing notable gets one line
flat "engineering-retro"  # names the downstream consumer whose job the format must not pre-empt

echo "PASS retro-format.sh"
