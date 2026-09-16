---
type: llm
weight: 2
focus: trace
arm: both
---

The task is to design the interface for a notifications module (multiple channels now and later, with retry on transient failure), shaping the boundary before implementation.

PASS if the response designs the boundary deliberately: it sketches at least TWO genuinely different interface shapes (not one shape plus trivial variations) and then recommends one, and the recommended interface is deep/narrow — a small surface (e.g. a single `notify(...)`-style entry point) that hides the channel/retry complexity behind it, rather than leaking channels, retry counts, and transport details into the caller's face.

FAIL if the response offers only a single shape with no alternative considered, or proposes a wide/shallow interface that exposes per-channel methods and transport details to callers, or skips straight to writing the implementation.
