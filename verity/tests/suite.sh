#!/bin/sh
# verity foundation suite: every non-live check. Run from anywhere:
#   sh verity/tests/suite.sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/validate.sh"
sh "$d/run-context.sh"
sh "$d/run-context-args.sh"
echo "ALL VERITY CHECKS PASS"
