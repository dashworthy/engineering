# The comprehension gate

A description is rewritten **only** if it fails on at least one of the six modes below.
Anything that fails none of them is left exactly as it is.

## The untouchable rule

**Prose that already does its job survives a run unchanged; when in doubt, leave it.** This is
an invariant, not a preference — without it every run rewrites everything and the diff becomes
noise. The report's `left_alone` count is the user's evidence the rule still holds.

## The six failure modes

| Failure | What it looks like |
|---|---|
| **Restates the signature** | `Sets the user id.` on `setUserId(int $id)` |
| **Describes mechanism, not purpose** | `Loops the items, calls process() on each, flushes the buffer.` |
| **Assumes vocabulary it does not supply** | `Reconciles the tender against the drawer.` |
| **Machine-facing residue** | `Implements task 4 of the sync plan. See brief section 3.` |
| **Empty of consequence** | Never says what it assumes, what happens if you skip it, or what will bite you |
| **Prose absent** | A docblock that exists but is tags only - no prose description above them |

## What passes

This is left alone. It says what the thing is for, when to run it, and what will surprise you:

```php
/**
 * Reconciles what the payment processor thinks we charged against what
 * our own ledger says. Run it after settlement, not before - before
 * settlement the processor's figures are still provisional and every
 * row will look like a mismatch.
 */
```

## What a rewrite says

- What the thing is **for**, in a sentence someone outside the team would follow.
- When you would reach for it, and when you would not.
- What it assumes, and what happens when the assumption does not hold.
- **Never a restatement of the tags.** They are frozen and sitting directly below.
