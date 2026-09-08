#!/bin/sh
# skillsmith foundation suite. Run from anywhere:
#   sh skillsmith/tests/suite.sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/validate.sh"
