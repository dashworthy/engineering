# Interfaces block — shaping the sketch

The rule that a boundary-reshaping task carries a code sketch — its **Interfaces block** — lives
in `plan`'s "Show the code, not just the intent". This is how to shape that sketch.

A sketch is an illustration, not the finished code: name the signature and the fields, elide
the body with a comment (`# walk the rule set once, return the Decision`) rather than writing
it out. Show the surface a reader needs to judge the change — the signature a caller will
type, the type a caller will hold, the assertion that proves the behavior — and stop there.

Fence every sketch as a code block so it survives the review phase and the human read intact:

```
check(user, resource, action) -> Decision
# Decision.allowed: bool
# Decision.reason: str | None   — populated only when allowed is False
```
