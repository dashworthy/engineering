#!/bin/sh
# Scaffold for code-review-no-edits: a small file with a real, reviewable bug (average() raises
# ZeroDivisionError on an empty list). Gives the review something concrete to find, and gives the
# without-plugin arm a temptation to just fix it (which code-review, by contract, never does).
# Runs as the operator, outside the eval tool sandbox.
set -e
cat > report.py <<'PY'
def total(nums):
    """Sum a list of numbers."""
    return sum(nums)


def average(nums):
    """Return the average of a list of numbers."""
    return sum(nums) / len(nums)
PY
