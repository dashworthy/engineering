# Scope lens

Review the doc for whether it covers the right ground — what this run changed — without spilling
past it. Its ground truth is the run's spec and plan (what the work was) read against the doc.

Look for:

- **Under-coverage.** Behavior this run shipped that a reader would expect documented and the doc
  does not mention.
- **Over-reach.** The doc ballooning into territory this run did not touch — long passages about
  adjacent systems, re-documenting the whole subsystem when the change was narrow. Documentation is
  judged and surgical; a doc that grew past the change is a finding.
- **Duplication.** Content that repeats what another feature's doc already owns, rather than linking
  to it. The same fact documented in two places drifts out of sync.

Do **not** verify claims against the code (accuracy lens), check prose or template conformance
(structure lens), or test links (links lens). Stay on: is the doc's coverage matched to the change?

Return each finding in the shared grammar: file and location, what's wrong, why it bites. An empty
return means the doc's scope matches what shipped.
