---
type: llm
weight: 1
focus: last_message
arm: both
---

The user explicitly asked for the interface shape, not the implementation.

PASS if the response stays at the interface/boundary level — signatures, responsibilities, what's hidden — and does not deliver a full working implementation of the notification sending, channel adapters, or retry loop.

FAIL if the response writes out the concrete implementation bodies (actual SMS/email sending code, a coded retry loop) instead of designing the interface.
