# The defect taxonomy

The fixed set of nine defects a written test is ruled against. `verifying-test-integrity` classifies
by it; `writing-tests-from-brief` writes past it. Each defect produces a **green run**, which is why
a passing test is never evidence on its own.

| Defect | What it looks like |
|---|---|
| Tautology | Assertion cannot fail — asserts a literal, or asserts a mock returned what it was configured to return |
| Vacuous act | Code under test never invoked, or invoked and its result never asserted on |
| Over-mocked | The unit under test is itself stubbed — or its dependencies are mocked so thoroughly that nothing real executes. The second form is the common one: each mock looks reasonable alone, but stacked they leave the test exercising the mock framework rather than the code |
| Misnamed intent | Name or description claims X, assertions check Y |
| Loose assertion | Presence check where the brief specified a boundary value — passes for wrong answers |
| Brief drift | The gap the brief specified is not the gap this test covers |
| False green | Passes for an unrelated reason — swallowed exception, early return before the interesting branch |
| Order dependence | Passes only within suite order or shared state |
| Never ran | Present but not collected by the runner — wrong convention, directory, or missing annotation |

Every one is something a writer could have avoided while writing — none require hindsight to see
coming. All nine produce a green run, so green is the baseline a review starts from, not the finding.
