#!/bin/sh
# receiving-code-review is a self-contained COMMAND entrance — no backing skill. It carries the
# shared four-beat skeleton (Isolate -> establish run -> shape context -> hand to brainstorming);
# its divergent third beat aggregates the review comments, verifies each against the codebase,
# checks whether an issue reaches beyond the commented area, and interrogates only when needed —
# carrying two standing instructions forward (reply to each ask; target each fix's PR at the
# original review branch, stacked). The forge mechanics are forge-agnostic: detect the forge, then
# use abstract review-thread operations backed by whichever CLI is present. The retired skill and
# the retired /to-signal command are both gone.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0

CMD=commands/receiving-code-review.md

# The receiving-code-review skill is gone; the entrance lives in the command. /to-signal is retired.
[ ! -e skills/receiving-code-review ] || { echo "FAIL: skills/receiving-code-review must be removed (it is now a command entrance)"; fail=1; }
[ ! -e commands/to-signal.md ] || { echo "FAIL: commands/to-signal.md must be removed (/to-signal is retired)"; fail=1; }
[ -f "$CMD" ] || { echo "FAIL: commands/receiving-code-review.md must exist"; fail=1; }

# Four-beat entrance skeleton, self-contained in the command.
grep -q "using-git-worktrees" "$CMD" || { echo "FAIL: entrance must carry the Isolate beat (using-git-worktrees)"; fail=1; }
grep -qE 'run-context\.sh" receiving-code-review|run-context\.sh receiving-code-review' "$CMD" || { echo "FAIL: entrance must establish/join a run via run-context.sh receiving-code-review"; fail=1; }
grep -q "\.engineering/" "$CMD" || { echo "FAIL: entrance must log to .engineering/<run>/receiving-code-review"; fail=1; }
grep -q "engineering:brainstorming" "$CMD" || { echo "FAIL: entrance must hand context to brainstorming"; fail=1; }

# Divergent shape-context beat: aggregate -> verify against codebase -> impact beyond the comment ->
# interrogate only when needed.
grep -qi "aggregate" "$CMD" || { echo "FAIL: beat 3 must aggregate the review comments"; fail=1; }
grep -qi "verify" "$CMD" || { echo "FAIL: beat 3 must verify each claim against the codebase"; fail=1; }
grep -qi "beyond the commented" "$CMD" || { echo "FAIL: beat 3 must check whether an issue reaches beyond the commented area"; fail=1; }
grep -q "interrogating-requirements" "$CMD" || { echo "FAIL: beat 3 must drive interrogating-requirements only when the user must be asked"; fail=1; }

# The technical-not-performative reception stance survives the move from skill to command.
grep -qi "verify before implementing" "$CMD" || { echo "FAIL: entrance must keep the verify-before-implementing stance"; fail=1; }
grep -qi "performative" "$CMD" || { echo "FAIL: entrance must keep the no-performative-agreement stance"; fail=1; }

# Two standing instructions carried forward into the design/build.
grep -qi "reply" "$CMD" || { echo "FAIL: entrance must carry the reply-to-each-ask instruction"; fail=1; }
grep -qi "original review branch" "$CMD" || { echo "FAIL: entrance must target each fix's PR at the original review branch"; fail=1; }
grep -qi "stack" "$CMD" || { echo "FAIL: entrance must state each fix's PR is stacked onto the review branch"; fail=1; }

# Forge-agnostic seam: detect the forge, use abstract thread operations, no GitHub-only API.
grep -qi "forge" "$CMD" || { echo "FAIL: entrance must be forge-agnostic (detect the forge)"; fail=1; }
grep -qi "resolve" "$CMD" || { echo "FAIL: entrance must name the resolve-a-thread operation"; fail=1; }
for f in gh glab gt; do
  grep -qE "\`$f\`|\b$f\b" "$CMD" || { echo "FAIL: forge-detection must name the $f CLI as one backing option"; fail=1; }
done
if grep -q "gh api" "$CMD"; then echo "FAIL: entrance must not hard-code a GitHub-only 'gh api' path (forge-agnostic)"; fail=1; fi

# Resolve flow: for each FIXED ask, AskUserQuestion shows the full comment + what was done, then asks
# whether to resolve the thread.
grep -q "AskUserQuestion" "$CMD" || { echo "FAIL: entrance must gate thread-resolution behind AskUserQuestion"; fail=1; }
grep -qi "full.*comment\|full original comment\|the full comment" "$CMD" || { echo "FAIL: resolve prompt must display the full original comment"; fail=1; }
grep -qi "what was done\|what we did\|what changed" "$CMD" || { echo "FAIL: resolve prompt must display what was done to resolve it"; fail=1; }

# Entrance-decoupling: never invoke another entrance.
if grep -qE "engineering:signal|/signal\b|engineering:triage|/triage\b" "$CMD"; then echo "FAIL: entrance must not invoke another entrance (entrances never invoke each other)"; fail=1; fi

[ "$fail" = 0 ] && echo "PASS code-review-entrance.sh" || exit 1
