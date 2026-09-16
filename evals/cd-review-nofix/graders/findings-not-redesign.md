---
type: llm
weight: 2
focus: trace
arm: both
---

The user asked only for a read on whether the interface shape is sound — a review, not a rebuild.

PASS if the response stays in review posture: it gives its assessment / findings on the shape (e.g. noting the cache-aside `get` returning null pushes load-and-set work onto every caller, or that `flushEverything()` is a blunt, un-scoped escape hatch) and hands them back. Offering a brief suggestion is fine.

FAIL if the response abandons reviewing and instead produces a full redesigned interface as the deliverable, or writes a concrete implementation of the cache — doing the fix rather than judging the shape.
