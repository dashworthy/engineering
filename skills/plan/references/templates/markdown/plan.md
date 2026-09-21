<!--
  Plan — MARKDOWN SKELETON (plain portable GFM)
  ------------------------------------------------------------------------------------------------
  The Markdown twin of references/templates/pdf/plan.pdf.tsx. Plain GitHub-Flavored Markdown, no
  build step — copy, fill, done. One plan file per run; never a numbered set.

  TO USE:
    1. Copy to .engineering/<run>/plan/<YYYY-MM-DD>-<topic>.md.
    2. Open with **Global Constraints** copied verbatim from the spec's Constraints + binding
       decisions (PR strategy, Finish strategy, Isolation). Then one **Task** block per task, each a
       short run of `- [ ]` steps naming exact file paths, wired into the TDD loop where it changes
       behavior, carrying its own verification command. Close with **Done when**.
    3. Keep the **Global Constraints** and **Done when** headings — they are the parity contract with
       the PDF template (the repo validation in tests/validate.sh checks them) and every downstream phase reads
       them.
  ------------------------------------------------------------------------------------------------
-->

# <Title> — plan

Turns the approved spec (`<path to spec>`) into ordered tasks.

## Global Constraints

<Copied verbatim from the spec's Constraints (§4) and any binding decision table.>

- **<constraint>** — <detail>.
- **PR strategy:** <single-branch | stacked (one PR per task, via engineering:using-stacked-pull-requests)>.
- **Finish strategy:** pull request.
- **Isolation:** <worktree | feature-branch>.

## Task 1 — <task title>

<One-line intent. Duplicate this block per task, in dependency order.>

- [ ] <Create|Modify>: `<path/to/file.ext>` — <the change>.
- [ ] Write the failing test first (where the task changes behavior): `<test path>`; run it, confirm it fails for the stated reason.
- [ ] Implement the minimum to pass; run the test, confirm green.
- [ ] Verify:
  ```bash
  <command that must pass>   # expect: <the output that counts as passing>
  ```
- [ ] Commit: `<type(scope): message>`.

## Done when

<The observable end state: every task's box checked, verification green, and the concrete checks
that confirm the plan is complete.>
