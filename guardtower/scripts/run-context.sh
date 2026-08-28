#!/bin/sh
# Resolve (creating if needed) the scratch dir for one facet/phase of the current guardtower run.
#
# Usage: run-context.sh <name> [slug]
#   <name>  phase/facet subdir, e.g. reviewing | reviewing-security
#   [slug]  short kebab name for a NEW run; ignored if a run is already active.
#
# The active run id lives in .guardtower/.current-run as "<YYYY-MM-DD>-<slug>".
# The first caller in a session creates it; later callers join it. Prints the
# absolute path of .guardtower/<run>/<name>/ and ensures it exists.
set -e

name=$1
slug=$2
[ -n "$name" ] || { echo "run-context.sh: missing <name>" >&2; exit 2; }

root=".guardtower"
pointer="$root/.current-run"
mkdir -p "$root"

if [ -f "$pointer" ]; then
  run=$(cat "$pointer")
else
  date_part=$(date +%Y-%m-%d)
  if [ -z "$slug" ]; then slug="run"; fi
  # sanitise slug to kebab: lowercase, non-alnum -> '-', squeeze, trim.
  slug=$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-//; s/-$//')
  [ -n "$slug" ] || slug="run"
  run="$date_part-$slug"
  printf '%s' "$run" > "$pointer"
fi

dir="$root/$run/$name"
mkdir -p "$dir"
# Print absolute path.
CDPATH= cd "$dir" && pwd
