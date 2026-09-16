---
type: llm
weight: 2
focus: trace
arm: both
---

The sketched `MemberManager` interface has several deliberate shape defects:
- It does too much / violates single responsibility (create+validate+persist+email in one method; an "update AND notify AND recalc fees" method).
- It takes dependencies (`\PDO`, `Logger`, `Mailer`) as method parameters instead of holding them, and uses boolean flag parameters (`$sendWelcome`, `$skipValidation`, `$notify`) that switch behavior.
- `getRawDbHandle(): \PDO` leaks the underlying database connection, breaking encapsulation (a shallow, leaky boundary).

PASS if the review identifies at least TWO of these distinct shape problems by substance — e.g. the single-responsibility overload, the flag/dependency parameters, or the leaked DB handle — judging the interface against sound design principles.

FAIL if the review misses these and only comments on surface matters (naming, formatting, PHP version) or pronounces the interface fine.
