#!/bin/sh
# guardtower foundation suite: every non-live check. Run from anywhere:
#   sh guardtower/tests/suite.sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/validate.sh"
sh "$d/run-context.sh"
echo "ALL GUARDTOWER CHECKS PASS"
