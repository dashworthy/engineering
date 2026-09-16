---
type: llm
weight: 2
focus: trace
arm: both
---

This boundary touches tenant data in a multi-tenant system, but the tenancy model is NOT stated: it is unknown whether tenants share one database (rows scoped by tenant id) or each tenant is physically isolated (separate database/schema). That choice fundamentally changes the interface and its safety.

PASS if the response treats the tenancy model as a decision that must be settled before the shape is final: it surfaces the shared-DB vs isolated-DB question and either asks the user which model applies or explicitly makes it a required choice — because guessing here risks a cross-tenant data leak.

FAIL if the response silently assumes one tenancy model and designs the interface as if that assumption were given, without ever surfacing that the model is unknown and consequential.
