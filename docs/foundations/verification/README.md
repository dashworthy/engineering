# Verification

**A branch is only "green" when a verification command has actually been run against the code as it stands now and its output has been read — never when green is claimed, remembered, or inferred from the diff looking right.**

---

## 🌟 Overview (plain-language)

**Verification** is the rule that separates a proven success from an asserted one. Before anyone reports that work is done, fixed, or passing, the relevant check — a test suite, a linter, a type check, a build, a manual reproduction of the bug — has to have been run against the current code, and its **output** has to have been read. A summary like an exit code is a claim somebody else already computed; the rule asks for the actual line of output that proves the claim, sitting next to the claim.

Two failure modes are what it exists to close. The first is the **asserted green**: a change looks obviously correct, so the report says "tests pass" before the command that would establish that has been run at all. Guessing well is still guessing — something not run has no output, and no output is not evidence. The second is the **stale green**: the check did pass, but the branch has moved since, so the old output no longer describes the code being reported on.

**Worked example.** A build task edits a parser and the surrounding code reads fine on inspection, so the branch is called green.

1. Verification refuses the claim on its own. Nothing was run this session, so there is no output to read — the "green" is asserted, not proven. It runs the task's own check and reads the result: `42 passed, 0 failed`. That line, quoted next to the claim, is what earns the word "passing"; "tests look good" would not, because it describes a feeling about the output rather than the output itself.
2. Later, `finish` picks up the branch to integrate it. In between, another task landed a commit on the branch. The earlier green now describes code that no longer exists at the tip, so it is a stale green. Verification re-runs the check against the branch's current state before any integration option is offered.
3. This time the suite comes back red. Integration stops there. `finish` does not fall through to the options list on the theory that the failure is probably unrelated — a red branch has nothing to integrate. The failure is reported and the decision handed back to the user.

The foundation defines what counts as verified; the phases that ship work compose it. `build` runs each task's own verification before the task is called done, and `finish` requires a verified green before it will offer any way to integrate the branch.

## 🛠 Technical reference

**Architecture.** The rule lives in one skill; two phases compose it at the points where a success claim would otherwise travel unproven.

| Area | Unit | Responsibility |
|---|---|---|
| Foundation | `skills/using-verification/SKILL.md` | Owns the rule: no "done/fixed/passing" claim leaves without a command run against current code and its output read. Runs the check, reads the output, quotes the decisive line. Does not decide what counts as verification for a project (reads that from how the project verifies itself), write or harden tests, fix a failing check, or decide what "done" means. |
| Consumer — build | `skills/build/SKILL.md` | Per-task verification: step 3 of the per-task loop runs the command the task's steps name and reads the output they say counts as passing. A task whose verification does not come back clean is not done, whatever the code looks like. |
| Consumer — finish | `skills/finish/SKILL.md` | Require-green-before-integrate: composes the foundation to confirm verification ran against the branch's current state — and re-runs it if the branch has moved — before offering any integration option. A red branch halts here; no option is offered. |

**Boundaries & invariants.**

- **Output, not a summary.** The evidence is the command's actual output read this session, not an exit code taken on trust and not a paraphrase of what the log probably said. If no single line of output can be found that proves the claim, that is the signal the check was never run, or was run against the wrong target.
- **Re-run on movement.** A green is bound to the exact code it ran against. If the branch has moved since verification last ran, the old output is stale and the check is re-run against the current tip rather than trusted.
- **Red halts.** A check that comes back red stops the flow. Nothing falls through to integration on the assumption the failure is unrelated — a red branch has nothing to integrate. The failure is reported and the decision handed back, rather than absorbed or worked around here.
- **Reads verification, does not invent it.** What command to run and what output counts as evidence come from how the project already verifies itself — its test runner, its CI config — not from a fresh judgment each time.

## 🚀 Development & testing

This plugin is skills and shell tests, so the checks are structural assertions over the skill files. The project's own verification command is the foundation suite — `suite.sh` is itself the thing that proves a change to the pipeline is green:

```bash
# Run the full foundation suite (what CI runs, and the project's own verification)
sh engineering/tests/suite.sh
```

There is no test file dedicated to `using-verification`, and no structural assertion checks the
rule directly — it is a discipline the composing phases carry in their own prose (`build`'s per-task
"Run the task's own verification" step and `finish`'s "Require green and verified before anything
else"), not something a shell test exercises. What the suite guarantees for verification is
indirect: it *is* the green it demands — a change to the pipeline is proven by `suite.sh` coming
back clean, which is the rule applied to this repo itself.

To change the rule itself, edit `engineering/skills/using-verification/SKILL.md`. To change how a phase composes it, edit that phase's `SKILL.md` (`build`, `finish`) where it names `engineering:using-verification`.
