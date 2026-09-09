# Pipeline entrances

**The three doors work enters the pipeline through — `signal` for a vague ask, `triage` for a
reported defect, `receiving-code-review` for review feedback — each of which shapes raw context into
something designable and hands it to the same design dialogue.**

---

## 🌟 Overview (plain-language)

Work does not arrive at the pipeline ready to design. A feature request is a sentence someone typed
in a hurry; a bug report is a symptom and a guess at its cause; a batch of review comments is a pile
of claims, some right and some not. An **entrance** is the skill that takes one of those raw inputs
and does the work of turning it into context a designer can act on — then gets out of the way. There
are exactly three, one per kind of input, and they share a spine: **establish a run**, **shape
context**, **hand to the design dialogue**. Only the middle beat differs, and that difference is the
whole reason there are three.

- **`signal`** is the discovery door. A vague or open-ended ask enters here, and signal
  **interrogates** it into a **brief** before anyone designs against it.
- **`triage`** is the defect door. A bug report enters here, and triage **reproduces** the failure
  under its own control and **isolates** it to a domain concept before anyone designs a fix.
- **`receiving-code-review`** is the review-feedback door. A set of review comments enters here, and
  the entrance **aggregates**, **verifies**, and **impact-checks** them before anyone designs the
  changes.

**Worked example.** Someone drops in: *"Admins keep asking for a way to pull the audit log out of the
system — can we add an export?"* That is a vague feature ask, so it goes to `signal`. Signal's first
move is not to sketch an export button. It runs `run-context.sh` to get a scratch directory
(`.engineering/<run>/signal/`), writes the request verbatim into `00-request.md`, then loads the
shared interrogation reference and starts asking one pointed question at a time — each posed as a
short menu with a recommended default and an open escape. *Export to what: CSV (recommended), JSON, a
scheduled email?* *Who signs off?* *What is explicitly out of scope — filtering, date ranges,
redaction of PII?* The user picks and corrects; the corrections are where the real requirements hide.
Once the gate is met — at least three rounds, and all six coverage dimensions filled — signal writes
`brief.md` §1–§6 (Problem, Users & Stakeholders, Success Criteria, Constraints, Scope, Existing
Context) to disk, and hands that brief's path to `engineering:brainstorming`. Signal never decides
*how* to build the export; it only makes sure the request is understood well enough that the design
dialogue is arguing about the right thing.

Had the same run arrived as *"the audit-log export throws on any log over 10k rows,"* it would have
gone to `triage` instead: reproduce the throw, narrow it to the concept that owns it ("the export's
in-memory buffering blows up past a threshold"), and hand that isolation to design. And a batch of
comments on the export's pull request would enter through `receiving-code-review`. Different middle
beat, same destination.

All three converge on the shared design dialogue — `engineering:brainstorming` — and nothing routes
sideways. An entrance never invokes another entrance; when `triage` finds it needs to pin down
expected behavior, it drives the *same* interrogation reference itself rather than handing off to
`signal`.

```mermaid
flowchart TD
    A[Vague ask / feature] --> S[signal<br/>interrogate into a brief]
    B[Reported defect] --> T[triage<br/>reproduce &amp; isolate]
    C[Review feedback] --> R[receiving-code-review<br/>aggregate, verify, impact-check]
    S --> D{{engineering:brainstorming<br/>the shared design dialogue}}
    T --> D
    R --> D
    D --> SP[spec &rarr; plan &rarr; build]
```

## 🛠 Technical reference

Each entrance is a self-contained skill with no backing command. They share a skeleton and diverge
only in how they shape context; two of them lean on a shared interrogation reference, and all of them
establish their run through one script.

| Area | Unit | Responsibility |
|---|---|---|
| Discovery entrance | `skills/signal/SKILL.md` | Interrogates a vague ask into `brief.md` §1–§6, then hands the brief path to design. Owns no design decision; always runs the interrogation beat. |
| Defect entrance | `skills/triage/SKILL.md` | Reproduces a reported failure, isolates it to a domain concept, records the disposition, and hands the isolation to design — or closes the report when it does not reproduce, is already fixed, or was already rejected. |
| Root-cause depth | `skills/triage/references/diagnosing.md` | Loaded by triage only when the hand-off needs the exact mechanism pinned: reproduce, hypothesize, isolate, confirm with evidence. Finds *why*; does not choose the fix's design. |
| Review-feedback entrance | `skills/receiving-code-review/SKILL.md` | Checks out the original review branch, aggregates the comments, verifies each against the codebase, impact-checks beyond the commented line, and carries two standing instructions (reply per thread; stack each fix's PR onto the review branch) into the shaped context. |
| Review-reply text | `skills/receiving-code-review/references/review-comment.md` | Phrases the reply for each thread in plain language — no performative agreement, no skill or process names, never signed. Phrases only; does not decide whether a comment is correct or whether to resolve its thread. |
| Shared interrogation | `references/interrogating-requirements.md` | The relentless requirement extractor both `signal` and (on demand) `triage` and `receiving-code-review` drive. Interactive, main-thread only; writes `brief.md` §1–§6 and `open-threads.md`. Cannot run as a dispatched subagent. |
| Run establishment | `scripts/run-context.sh` | Prints and creates `.engineering/<run>/<entrance>/`, creating the run on the first caller and joining it on later ones. The active run id lives in `.engineering/.current-run`. |

**Boundaries & invariants.**

- **Every entrance ends at the design dialogue.** Each shapes context and then invokes
  `engineering:brainstorming`; none designs, writes a spec, plans, or builds itself. "Stop" at the
  seam means stop shaping and hand off — not stop to ask whether to proceed.
- **The three converge on design, never on each other.** No entrance invokes another entrance.
  `triage` never hands off to `signal`; when it or `receiving-code-review` needs to synthesize
  expected behavior, it drives `references/interrogating-requirements.md` itself as its own discovery
  leg.
- **No gate at the entrance seam.** There is no approval to collect when handing to design. Approval
  lives downstream — the spec-approval gate in `spec`, the plan-approval gate in `plan`.
- **The run is established through `run-context.sh`, and artifacts are written as found.**
  Reproduction notes, verification notes, briefs, and routing decisions land in
  `.engineering/<run>/<entrance>/` as they are discovered, not reconstructed from memory afterward.
- **Isolation is build's job, not the entrance's.** Entrances run on the current branch.
  `receiving-code-review` is the one exception to touching the branch at all: it *checks out* the
  original review branch first, as a base for verification and stacking — not as a code change — so
  `build` later isolates off the right branch automatically.
- **The interrogation reference is main-thread only.** It is interactive and cannot run as a
  dispatched subagent; it hands control back to the entrance that invoked it and never routes onward
  itself.
- **The brief ends at §6.** `signal`'s deliverable is `brief.md` §1–§6, written the moment the
  advancement gate is met (3+ rounds, all six dimensions filled) so it is durable; there is no §7,
  and ordering the work by dependency is design work downstream.
- **A defect can exit without going to design.** `triage` closes a report that is not reproducible,
  already fixed, or already rejected — with the reason on record — rather than forcing it into the
  design dialogue.
- **A received review carries two standing instructions forward.** Reply on each comment's own
  thread; stack each fix's PR onto the original review branch. Resolving a thread stays the user's
  explicit call, made with the full comment and what was done both in view.

## 🚀 Development & testing

The entrances are skills, so their tests are structural assertions over the skill files — that each
entrance exists as a skill with no backing command, drives the shared skeleton, and never invokes
another entrance.

```bash
# Run the full foundation suite (what CI runs)
sh engineering/tests/suite.sh

# The checks specific to the three entrances
sh engineering/tests/absorb-signal.sh        # signal drives the interrogation and writes brief.md §1–§6
sh engineering/tests/triage.sh               # triage's reproduce/isolate beat; stays decoupled from signal
sh engineering/tests/code-review-entrance.sh # receiving-code-review's aggregate/verify/impact-check + forge tail
sh engineering/tests/entrances-parallel.sh   # all three share the establish-run → shape → hand-to-design skeleton
```

To change how an entrance shapes context, edit its `SKILL.md`. To change the interrogation the
discovery leg runs, edit `references/interrogating-requirements.md` (shared — a change there affects
all three). To change how a run's scratch directory is resolved, edit `scripts/run-context.sh`.
