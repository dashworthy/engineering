#!/bin/sh
# verity run-context.sh argument handling: the usage guard, the slug sanitiser, and the
# empty-slug default — the branches the happy-path run-context.sh test never exercises
# (it only ever passes an already-clean slug, and its second call takes the join path).
# Each assertion is written to FAIL if the corresponding behaviour regressed, not merely
# to pass against today's script.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/verity/scripts/run-context.sh"
[ -f "$SCRIPT" ] || { echo "FAIL: $SCRIPT missing"; exit 1; }

# 1. Missing <name> is a usage error: exit 2, nothing created.
#    (Drop the guard and the script proceeds with an empty phase and exits 0 — so a
#     non-2 exit here catches that regression.)
d1=$(mktemp -d); cd "$d1"
sh "$SCRIPT" >/dev/null 2>&1 && rc=0 || rc=$?
[ "$rc" -eq 2 ] || { echo "FAIL: missing <name> must exit 2, got $rc"; exit 1; }
[ -d "$d1/.verity" ] && { echo "FAIL: missing <name> must not create .verity/"; exit 1; }

# 2. A messy slug on a FRESH run is sanitised to kebab: lower-cased, every run of
#    non-alnum collapsed to one '-', leading/trailing '-' trimmed. "My Feature!" -> "my-feature".
#    (Drop the sanitiser and the run id keeps the spaces/caps/'!', so the suffix match fails.)
d2=$(mktemp -d); cd "$d2"
out2=$(sh "$SCRIPT" test-hardening "My Feature!")
run2=$(basename "$(dirname "$out2")")
#    An unsanitised slug would yield "...-My Feature!", which does not end in "-my-feature",
#    so the suffix match alone catches the regression (caps, space, and '!' all fail it).
case "$run2" in
  *-my-feature) : ;;
  *) echo "FAIL: slug not sanitised to 'my-feature': got run id '$run2'"; exit 1 ;;
esac

# 3. No slug at all defaults the run id's slug portion to 'run'.
d3=$(mktemp -d); cd "$d3"
out3=$(sh "$SCRIPT" test-hardening)
run3=$(basename "$(dirname "$out3")")
case "$run3" in
  *-run) : ;;
  *) echo "FAIL: absent slug must default to 'run': got run id '$run3'"; exit 1 ;;
esac

echo "PASS run-context-args.sh"
