# Diagram width budget for docblocks

An ASCII diagram inside a docblock or comment has a hard width budget, because docblocks live
in a narrow gutter and IDEs fold them. (Whether a shape earns a diagram at all is the
earned-its-place test in `SKILL.md`; this file is only the width rule for the ASCII case.)

**72 columns including the comment leader.** Every line acquires a ` * ` prefix in the file.
Light box-drawing characters only.

```
 * request --> validate --> enrich --> persist
 *                |            |
 *                v            v
 *             reject      cache miss --> upstream
```

A diagram that overflows the budget wraps, and a wrapped diagram is unreadable in exactly the
place a reader most needed it.
