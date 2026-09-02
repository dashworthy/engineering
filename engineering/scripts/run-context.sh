#!/bin/sh
# Resolve (creating if needed) the Tier-2 scratch dir for one phase of the current run.
#
# Usage: run-context.sh <name> [slug] [--fresh]
#   <name>   phase subdir, e.g. signal | triage | test-hardening | vernacular | implement
#   [slug]   short kebab name for a NEW run; ignored if a run is already active.
#   --fresh  return a fresh per-invocation leaf .engineering/<run>/<name>/<NNN>/ instead of
#            the shared phase dir. For a phase invoked more than once in one run whose scratch
#            describes a single invocation (vernacular: before/ + receipts/ + report.md are one
#            proof cycle). Without it, repeat invocations share .engineering/<run>/<name>/ and a
#            later invocation's reconcile re-checks an earlier one's receipts against a file that
#            has since moved on. The leaf is the next zero-padded integer above the existing ones,
#            so invocations stay ordered and never collide, and each keeps its own history.
#
# The active run id lives in .engineering/.current-run as "<YYYY-MM-DD>-<slug>".
# The first caller in a session creates it; later callers join it. Prints the
# absolute path of .engineering/<run>/<name>/ (or its fresh leaf) and ensures it exists.
set -e

name=""
slug=""
fresh=0
for arg in "$@"; do
  case "$arg" in
    --fresh) fresh=1 ;;
    *)
      if [ -z "$name" ]; then name="$arg"
      elif [ -z "$slug" ]; then slug="$arg"
      fi
      ;;
  esac
done
[ -n "$name" ] || { echo "run-context.sh: missing <name>" >&2; exit 2; }

root=".engineering"
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

if [ "$fresh" = 1 ]; then
  # Next leaf = one above the highest numeric child already present. Strip leading
  # zeros before any arithmetic so a padded name like 008 is not read as octal.
  max=0
  for existing in "$dir"/*/; do
    [ -d "$existing" ] || continue          # no match: the literal glob, skip it
    b=$(basename "$existing")
    case "$b" in *[!0-9]*) continue ;; esac  # numeric leaves only
    n=$(printf '%s' "$b" | sed 's/^0*//'); [ -n "$n" ] || n=0
    [ "$n" -gt "$max" ] && max="$n"
  done
  leaf=$(printf '%03d' "$((max + 1))")
  dir="$dir/$leaf"
  mkdir -p "$dir"
fi

# Print absolute path.
CDPATH= cd "$dir" && pwd
