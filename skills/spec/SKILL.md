---
name: spec
description: "The single writer of Tier-1 specs and holder of the spec-approval gate. Render the standard spec from an entrance's material (a signal brief or triage record) as a draft, present it, wait for approval, then stamp Approved and mint the spec-approval marker. Runs on a recommended design already handed off from the design phase; does not self-trigger on arbitrary requests."
---

# spec

Serialize the recommended design you are handed into the one Tier-1 spec, present it, and hold the
spec gate. The run-dir slug stays `to-spec` (`.engineering/<run>/to-spec/APPROVED.md`), which `plan`
reads as its precondition.

## Inputs

Accept either:
- a **path** to Tier-2 material — `.engineering/<run>/signal/brief.md`, or
  `.engineering/<run>/triage/…` — or
- the material **inline**, already sitting in context.

One of the two must be present. If neither is — no path resolves, and nothing has been
supplied inline — refuse and say so. Do not proceed on a guess about what was meant, and
do not go looking for material elsewhere. This skill starts only from what it is handed.

## Where it writes

Tier-1, and only Tier-1: `.engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md`. This is the only skill
permitted to write to the run's spec dir, and it writes exactly one spec there.

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

## Shaping the spec

Turn the material you were handed — a signal brief, or a triage isolation record, with the
recommended design from `brainstorming` — into the spec's content by filling **this skill's spec
template**:

- `references/templates/markdown/spec.md` — the Markdown form, which is also the Tier-1 **format
  contract**: it carries every section (§0 ELI5 → §8), the source mapping (how a signal brief and a
  triage record each land on the sections), and the rules. Follow it; do not restate it here.
- `references/templates/pdf/spec.pdf.tsx` — the PDF form, same sections.

Shape, don't transcribe: §0 ELI5 is a plain-language synthesis written last; §6 Approach is the
recommended design (the chosen approach, the alternatives it beat, any boundary named), not the
brief. Where the material is thin, the section says so and the gap goes to §8 — never invent.

## Presentation artifact

Hand the filled spec's path (`.engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md`) to
`engineering:using-doc-creation`.

## The spec gate — write a draft, then hold for approval

This is the pipeline's first human-approval gate, and it lives here, on the spec. This
skill does not stamp `Approved` on faith:

1. **Write it as a draft.** Set the status line to `Status: Draft` (see this skill's spec template,
   `references/templates/markdown/spec.md`).
2. **Present the draft, then put the verdict to the human as a structured choice** — `Approve` or
   `Request changes` — following `engineering:using-questions` for how to shape and ask it, and
   for its degraded-run fallback where no question tool exists. Show the
   finished spec and wait for the human's approval, the
   question holding the turn so this is a real stop: nothing is `Approved`, and no marker is
   written, until they pick Approve. Their edits ride the free-form escape or a `Request
   changes` reply; on that, revise the draft — or hand back to `brainstorming` for a rethink —
   and present again. Do not promote a spec the human has not approved. This is a gate, so its
   own semantics stay here: wait for an explicit typed approval, and **treat silence as
   not-approved**.
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
