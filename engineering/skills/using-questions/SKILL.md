---
name: using-questions
description: "Put a question to a human as a clear, structured choice — a short menu with the recommended answer first, an always-open free-form escape, and a plain-text fallback when no question tool is available — and hold it to the seven clarity guardrails so the question increases clarity rather than confusion. Cross-cutting; invoke from any phase that asks a human to decide."
---

# Using Questions

Say this first, plainly: `Using the using-questions skill to put a clear question to the human.`

## What this guarantees

One thing: any question this pipeline puts to a human is asked the same way — a structured
choice with the conventional answer marked, a way for the human to say something the menu did
not anticipate, and a stated fallback when the harness (the agentic coding tool the pipeline is
running inside — Claude Code, Codex, and the like) has no question tool — and it is worded so
the human can answer it without decoding it. The mechanics live here once; a calling skill
names *what* it is asking and points here for *how* to ask it.

## The mechanics — how every question is shaped

- **Render it as a structured choice, using a tool to ask it where one is available.** The
  options are pickable, not a wall of prose the human has to answer freehand. See the harness
  table below for which tool each harness offers.
- **Put the conventional answer first and mark it `(Recommended)`,** with its rationale carried
  alongside the option, so the human is choosing against a reasoned default rather than refereeing
  a pile of equal-looking options.
- **Always leave a free-form escape.** Every question lets the human type their own answer instead
  of picking — a correction, a hybrid, or "keep talking." The pick is never a trap: a closed list
  of your guesses, offered as the only choices, would encode your framing as the answer.
- **Degraded-run fallback.** Where no question tool is available (a headless or non-interactive
  run), present the same menu as plain text and say the run is degraded — still a structured menu
  to pick from, never open prose — then wait for an explicit answer.

**What stays with the caller — the boundary.** This skill owns the mechanics above and the
guardrails below. It does **not** own what the question is about, the option set, or the calling
site's own semantics. In particular, a **gate** — a human-approval checkpoint in the pipeline,
such as the spec-approval or plan-approval step — has its own rule that **silence is not
approval**: wait for an explicit, typed approval, treat no answer as not-approved. That is gate
behavior, not question mechanics; it stays at the gate. Point here for how to ask; keep your
site's meaning at your site.

## The seven guardrails — so the question increases clarity

Apply this checklist before asking. Each rule removes a specific way a question breeds confusion:

1. **No double negatives.** No negated options and no negatively-framed question. Ask "Enable X?"
   with options `Enable` / `Leave disabled`, never "Don't you want to not disable X?" A human should
   never have to unwind a negation to work out what "yes" means.
2. **Mutually exclusive options.** In a single-select question the options must not overlap or
   nest — no option is a subset of another, and no two can both be true. Overlap makes the pick
   ambiguous and the answer unreadable.
3. **No leading or loaded framing.** The wording does not push an answer. The recommended default
   carries its reasoning openly, as a stated rationale the human can reject — never a nudge hidden
   in how the other options are phrased.
4. **One decision per question.** Each question isolates a single decision. Never bundle
   "A and B?" into one prompt: the answer to a two-part question is unreadable when the human
   agrees with one part and not the other. Split it into two questions.
5. **Cap the options at 2-4.** A menu of two to four choices is one a human can weigh at a glance;
   more than four is a wall to read past. If a decision has more than four live answers, it is
   usually two decisions (see rule 4) or wants a free-form answer.
6. **Concrete over vague.** Options and the question itself are specific and checkable, not
   hand-wavy: "p95 under 200ms" not "fast", "delete the row" not "handle it". A vague option can
   be picked and still leave everyone unsure what was chosen.
7. **Default at the field-default.** Set the recommended option to conventional practice for the
   domain, not tuned to what the human already told you. When the human departs from a
   conventional default, that departure is real information about their situation; when they
   merely agree with a default you copied back from their own earlier words, you have learned
   nothing except that you were listening. Always leave the open escape (from the mechanics
   above) so the default is never the only way out.

## Question tools by harness

A picked option costs the human less than a composed one, so ask with the harness's structured
tool wherever it has one. This table maps common agentic harnesses to their mechanism; where a
harness has none, the degraded-run plain-text fallback above is the honest path.

| Harness | Question mechanism |
|---|---|
| Claude Code (`claude`) | `AskUserQuestion` — single- or multi-select options, each question carrying a free-form "Other" escape. |
| OpenCode (`opencode`) | `askquestion` — a TUI wizard offering single- or multi-select; suspends the agent until the human answers. |
| Hermes Agent (`hermes`) | Its ask-the-user tool — single-select (up to 4 choices), multi-select, or open-ended free-form. |
| Codex CLI (`codex`) | No dedicated structured-question tool; use the plain-text menu fallback (interactive input / queued follow-up prompts). |
| Any other harness | A structured question tool if the harness exposes one; otherwise the plain-text menu fallback. |

Names and availability drift as harnesses change — treat the row as a starting point, and fall
back to the plain-text menu rather than forcing a tool that is not actually there.

## A worked example

One decision, four capped options, recommended first with its reason, and the escape the tool
appends:

> **header:** `Auth` · **question:** "Auth approach?"
> - **SSO (Recommended)** — kills the password-reset support load, the usual driver here.
> - **Magic links** — no passwords, but every login waits on email delivery.
> - **Password + 2FA** — familiar, but keeps the reset burden you have today.
> - *(Other — the human types their own)*

The degraded-run form of the same question is that menu as plain text, prefixed with a line that
the run is degraded because no question tool was available, then a wait for an explicit pick.

## What this does not do

- It does not **decide what to ask.** The decision a question puts to the human comes from the
  calling skill; this skill shapes the asking, it does not source the question.
- It does not **hold gates.** A gate's approval semantics — silence is not approval, wait for a
  typed answer — belong to the gate that owns them, not here.
- It does not **build or require a specific tool.** It governs the use of whatever question tool a
  harness already provides, and falls back to plain text where there is none.
