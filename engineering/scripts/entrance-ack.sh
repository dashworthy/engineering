#!/bin/sh
# Explicit acknowledgement that lifts the build gate (see hooks/require-entrance.sh) for the
# current session WITHOUT running an entrance.
#
# This is the only sanctioned bypass, and it is deliberately narrow. Use it only to:
#   - continue work whose entrance already ran and whose spec/plan is already approved, or
#   - record an explicit authorization the user gave to skip the entrance.
# It is NOT for self-certifying that a change is "too small" or "trivial" — that is the exact
# rationalization the gate exists to defeat. The agent has no authority to grant itself the
# bypass; only an entrance or an explicit human decision does.
#
# A reason is required and is appended to an audit log so every bypass is visible after the fact.
# Running this is what the PreToolUse hook detects to lift the gate; the log is the paper trail.

set -e
reason="$*"
if [ -z "$reason" ]; then
  echo "entrance-ack.sh: a reason is required (why is building proceeding without an entrance?)" >&2
  echo "usage: entrance-ack.sh \"continuing approved plan <run>\" | \"user authorized: <verbatim>\"" >&2
  exit 2
fi

root="${CLAUDE_PROJECT_DIR:-.}"
state_dir="$root/.engineering/.state"
mkdir -p "$state_dir"
printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$reason" >> "$state_dir/entrance-ack.log"

echo "Entrance gate acknowledged for this session."
echo "Reason: $reason"
echo "Logged to .engineering/.state/entrance-ack.log"
