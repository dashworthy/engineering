---
name: spec
description: "The single writer of Tier-1 specs and holder of the spec-approval gate. Render the standard spec from an entrance's material (a signal brief or triage record) as a draft, present it, wait for approval, then stamp Approved and mint the spec-approval marker. Runs on a recommended design already handed off from the design phase; does not self-trigger on arbitrary requests. Run-dir slug stays `to-spec`."
---

# spec

Say this first, plainly: `Using the spec skill to write the spec.`

The spec phase is the single Tier-1 writer and the pipeline's first human-approval gate. It
serializes the recommended design it is handed into the one Tier-1 spec, presents it,
and holds the spec gate. Its run-dir slug stays `to-spec` (`.engineering/<run>/to-spec/APPROVED.md`),
which `plan` reads as its precondition.

## What this guarantees

One thing: given an entrance's finished material, this stage writes exactly one Tier-1
spec, in exactly one format, at exactly one path. It is the only skill in this plugin
permitted to write to the run's spec dir, `.engineering/<run>/spec/`.

## Inputs

Accept either:
- a **path** to Tier-2 material — `.engineering/<run>/signal/brief.md`, or
  `.engineering/<run>/triage/…` — or
- the material **inline**, already sitting in context.

One of the two must be present. If neither is — no path resolves, and nothing has been
supplied inline — refuse and say so. Do not proceed on a guess about what was meant, and
do not go looking for material elsewhere. This skill starts only from what it is handed.

## Where it writes

Tier-1, and only Tier-1: `.engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md`.

`<topic>` is the active run's slug when a run is available. The pointer
`.engineering/.current-run` holds the full run id in the form `<YYYY-MM-DD>-<slug>`; use only
the `<slug>` portion — everything after the leading `YYYY-MM-DD-` date prefix — not the whole
pointer value, or the date is duplicated in the filename. When no run is active, fall back to a
slug derived from the spec's own title. `<YYYY-MM-DD>` in the filename is today's date, not the
run's start date, if the two differ.

The spec is a run-scoped artifact: it lives under `.engineering/<run>/spec/`, alongside the
run's other working state, not in the repository's tracked docs tree — the run dir is the
single home for a run's spec, plan, markers, and scratch. Beside the spec this skill
also writes the run-scoped approval marker (`.engineering/<run>/to-spec/APPROVED.md`), minted at
the spec gate below — the marker is the trace that the spec cleared the gate.

## How it renders

Follow `references/SPEC-FORMAT.md` — do not restate its shape here or
reinvent it inline. Every section in that file gets filled; a section with nothing to
say gets a line explaining why, not silence.

Two source shapes map onto the one format — and the mapping is by meaning, not by
section number:
- a **signal** brief supplies §1–§5 in order, and its §6 (Existing Context) becomes
  the spec's §7; the brief ends at §6. The spec's §6 (Approach) does not come from
  the brief at all — it is transcribed from the recommended design `brainstorming` hands
  off: the chosen approach, the alternatives it beat, and — when the approach turned on a
  boundary — the boundary `using-codebase-design` shaped. Together these are §6's content.
- a **triage** isolation record maps onto the same eight sections with two repurposed:
  §1 becomes the reproduced problem, and §6 becomes the chosen fix approach — including
  why the smaller fixes on the table were rejected, not only the one that won.

When §6 Approach or §7 Existing context describes a data model, a flow, or a state machine,
consider a diagram via `engineering:using-diagrams` — the guard is *consider*, not *always
draw*; the skill's own earned-its-place test decides whether one is actually drawn.

## The spec gate — write a draft, then hold for approval

This is the pipeline's first human-approval gate, and it lives here, on the spec. This
skill does not stamp `Approved` on faith:

1. **Write it as a draft.** Set the status line to `Status: Draft` (see `references/SPEC-FORMAT.md`).
2. **Present the draft, then put the verdict to the human as a structured choice**, using a tool to
   ask it where one is available. Show the
   finished spec and wait for the human's approval — ask them to `Approve` or `Request changes`, the
   question holding the turn so this is a real stop: nothing is `Approved`, and no marker is
   written, until they pick Approve. Their edits ride the free-form escape or a `Request
   changes` reply; on that, revise the draft — or hand back to `brainstorming` for a rethink —
   and present again. Do not promote a spec the human has not approved. No such tool, or a headless
   run: present `Approve` / `Request changes` as plain text, say the run is degraded, and wait for
   an explicit typed approval — treat silence as not-approved.
3. **On approval, mint the marker and promote.** Create the run's to-spec phase directory
   with `run-context.sh to-spec <slug>` and write `.engineering/<run>/to-spec/APPROVED.md`
   into it — do this only on approval, never before — a Tier-2, run-scoped trace that the
   spec cleared the gate. Then flip the status line from `Status: Draft` to `Status: Approved`.
   The marker's existence *is* the approval; never write it on the assumption that reaching
   this skill implies one.

`plan` reads that marker as its precondition: an `Approved` status with no
`.engineering/<run>/to-spec/APPROVED.md` behind it is refused downstream, so the marker and
the status are only ever promoted together, here, at the moment the human approves.

## What this does not do

- It does not **design**. The §6 approach was argued out in `brainstorming` upstream; this
  skill transcribes that outcome, it does not weigh alternatives itself.
- It does not **plan**. Breaking the approved approach into steps is `plan`,
  downstream of the spec this skill produces.
- It does not **interrogate**. If the material handed to it is missing something a
  section needs, this skill does not go ask questions to fill the gap — that already
  happened, or should have, upstream in `signal` or `triage`.
- It does not invent. Where the source material is thin, the corresponding section says
  so, and the gap goes into §8 as an open question. A confident-sounding sentence with no
  source behind it is worse than an honest blank.

## Handoff

The only stop on this skill is the spec gate itself, and it sits *before* approval: a spec
still in `Draft` because the human has not approved it waits at the gate and is not handed
onward. Once the human approves — the marker written, the status flipped to `Approved` — that
approval *is* the go. There is no second gate at this seam, so print the spec's path and
**invoke `plan` now.** "Stop" here means stop *writing the spec*; it is not a stop to
ask the human whether to proceed. Parking an approved spec with a "want me to write the plan?"
is not an available move — the approval was the answer to that question; `plan` is
the next act, take it. This skill does not itself author the plan — that is `plan`'
one job — and does not summarize the spec beyond that one path; it hands off and lets
`plan` read the spec and the marker behind it.
