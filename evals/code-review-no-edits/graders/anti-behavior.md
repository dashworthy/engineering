---
type: tool_used
tool: Edit
min: 0
max: 0
arm: both
---
The contract guard, scored in both arms: a review must NOT edit the source. `code-review` reports
findings and never fixes them, so with the plugin this passes. A without-plugin base model that
"reviews" by silently editing `report.py` to fix the bug trips this — the difference (when it
occurs) reinforces the delta; when it doesn't, this still guards the with-plugin contract.
