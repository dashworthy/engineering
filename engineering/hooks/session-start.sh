#!/bin/sh
# SessionStart hook for the engineering plugin: the entrance bootstrap.
#
# Puts the three front doors in front of the model at the start of every conversation.
# Injects guidance only; it never blocks, never touches git, never reads or writes a
# file, and does not depend on jq.

message='Engineering pipeline is available. Before building from a request, pick the entrance:\n- A feature or a vague ask: run `/signal` (discovery to a brief).\n- A reported bug or defect: run `/triage` (isolate with minimal effort).\n- Received code-review feedback: run `/receiving-code-review` (aggregate, verify, and shape the comments).\nAll three shape context, then converge on the same design dialogue. Invoke the right entrance before acting (see the `using-skills` foundation). Do not jump straight to code on non-trivial work.\nThis is enforced, not advised: a PreToolUse gate blocks Edit/Write until this session has engaged the pipeline (any entrance does), so a fresh session starts unable to build. If you hit that block, do not try to work around it — run the right entrance. The narrow, logged bypass (`engineering/scripts/entrance-ack.sh`) is only for continuing already-approved work or a bypass the user explicitly authorized, never for self-certifying a change as trivial.'

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$message"

exit 0
