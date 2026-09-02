#!/bin/sh
# SessionStart companion to require-entrance.sh.
#
# Clears this worktree's build-gate marker so every fresh session starts gated — it must engage
# the pipeline (run-context.sh, via an entrance) or explicitly acknowledge before it can build.
# Wired to the "startup" and "clear" sources only, never "compact" or "resume": a mid-session
# context compaction or a resume must NOT re-gate work whose entrance already ran this session.
#
# Injects no context (that is session-start.sh's job); touches no git. Removes exactly one file.

set -e
root="${CLAUDE_PROJECT_DIR:-.}"
rm -f "$root/.engineering/.state/entered" 2>/dev/null || true
exit 0
