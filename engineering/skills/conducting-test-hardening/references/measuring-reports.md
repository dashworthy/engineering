# Measuring Test Reports

## What you receive

One dispatch: `{suite, report_path, report_format, report_kind, changed_files}`. `report_kind`
is `coverage` or `mutation` — it tells you which shape of number to extract and which sanity
rules apply. You see exactly one suite's report; nothing here is compared or blended across
suites.

## Why this is a separate agent

You read the report file so the conductor stays small; only the numbers below come back. Never
echo the report's contents into your return value, at any point, for any reason.

## The percentage is pooled, not averaged

`percent = sum(covered) / sum(total) * 100`, computed once across every qualifying file
together — not the mean of each file's own percentage. The two formulas give materially
different answers from the same report: a mean weights a ten-line file the same as a
thousand-line one, so one small untested file can swing the average far more, or far less, than
its actual share of the diff warrants. This gate's authority rests on the same report producing
the same number every time it's read, so pool the raw counts first and divide once, at the end.

## The zero-coverage rule — read this before anything else

**A file in `changed_files` that does not appear in the report counts as ZERO coverage — never
treated as missing data, never dropped from the calculation.** An untested new file is the
single most important thing this measurement exists to surface. Averaging it away — by skipping
it, by excluding it as "not in the report," or by computing the percentage only over files the
report happens to mention — is the one mistake that makes the entire threshold meaningless: the
run would report a healthy percentage precisely because the worst file in the diff contributed
nothing to it.

Concretely: for every path in `changed_files`, either find it in the report and use its real
covered/total (or killed/total) numbers, or, if it is absent from the report entirely, record it
in `files` with `covered: 0` and a real, nonzero `total` (see the absent-file denominator
below). Do not write `total: 0` — a `0/0` entry contributes nothing to a
`sum(covered)/sum(total)` aggregate and makes the file invisible again, exactly the outcome this
rule exists to prevent. There is no third option where the file is quietly skipped.

## Scope to the changed files

The threshold this feeds is diff-scoped, not repo-scoped. Compute the percentage across only the
files in `changed_files` that appear in the report, plus every `changed_files` entry absent from
the report per the zero-coverage rule above. A file present in the report but **not** in
`changed_files` is ignored entirely — including it would dilute the number in the other
direction, hiding a weak changed file behind a well-tested unrelated one.

## Format is a hint, not a parser

`report_format` names the schema so you know roughly what to expect — test-hardening ships no parser and
no adapter list, and none is needed here. Read the file yourself and extract per-file numbers
regardless of whether its actual shape matches the label exactly; a mislabeled or
slightly-off-spec report is still readable by inspection.

For a **coverage** report (`report_kind: "coverage"`): locate each file's element and read its
line-level hit counts to get `covered` (lines actually hit) and `total` (lines counted as
coverable) for that file.

For a **mutation** report (`report_kind: "mutation"`): locate each file's element and read
`covered` as mutants killed and `total` as mutants generated for that file. In addition — and
this matters more than the score itself — collect **every surviving mutant**: its location and
its mutator name. Survivors are what seed the next iteration's audit brief; a mutation score with
no survivor list gives the next auditor nothing to act on.

**A survivor's location is `mutant_line` in `file:line` form, never a bare line number.**
Carry-forward passes surviving mutants on to the next `auditing-test-gaps` dispatch as `suite`,
`mutant_operator`, `mutant_line`, and that auditor is told to read the code at `mutant_line` to
turn it into a real finding. A bare line number, on its own, does not name a file — the auditor
would have nothing to open. Emit `mutant_line` as `<repo-relative path>:<line>`, matching the
`file:line` convention `prior_defect_location` already uses elsewhere in the brief schema, so the
file identity survives the hop from this dispatch into the next audit.

## Report parse failures honestly

If the report is missing, empty, truncated, or in a shape you genuinely cannot read after
looking, do not guess. Set `percent` to `null`, leave `files` empty (or as far as you got, if
partially readable), and set `parse_status` to a specific, factual description of what you found
— "file does not exist at report_path," "file exists but is zero bytes," "file exists but is not
well-formed and stops mid-record," not a vague "could not parse." Never estimate a number from a
stdout summary line, a partial read, or a prior iteration's figure. The conductor's response to a
null `percent` is to disable that threshold for this suite and say so plainly to the user — that
is the correct outcome. A guessed number instead silently gates a real decision on fiction, which
is strictly worse than admitting the report couldn't be read.

## An absent file's denominator: use its line count, and say so

A file in `changed_files` but missing from the report has no killed/covered or total you can read
off the report — that number has to come from somewhere else. Use the file's own line count. This
is not unit-consistent with the report's own `total` for files it does mention: a report's
"coverable lines" excludes blanks and comments, while a raw line count doesn't, so the absent
file's denominator is somewhat larger than a report-derived one would have been. State that
plainly rather than hiding it — note in your reasoning (not in `parse_status`, which is for
report-level failures) that this file's `total` is a line count, not a coverable-line count. The
direction of that bias is the safe one for a gate: a larger denominator makes the file's
contribution read as *less* covered, never more. A smaller invented denominator that flatters an
untested file is the failure mode to avoid; this one errs toward suspicion instead, the correct
default when nothing tested the file at all.

## Sanity-check yourself before returning

Before you return, verify all four:

- `percent`, if not `null`, is between 0 and 100.
- `files` is non-empty whenever `percent` is non-null — a non-null percentage with no files
  behind it cannot be justified.
- Every entry in `changed_files` is present in `files` — **but only whenever `percent` is
  non-null.** On a parse failure this check does not apply: a truncated report can legitimately
  yield a partial `files` list, and there is no way to "fix" a read a truncated file has already
  made impossible. Return whatever you got, with `percent: null` and a `parse_status` that says
  the report was incomplete — don't loop trying to complete an unreadable file.
- **`files` contains nothing outside `changed_files`.** This catches the opposite failure from
  the zero-coverage rule: a measurer that folds in every file the report happens to mention
  dilutes the number with unrelated, probably well-tested code, and would otherwise pass every
  check above. Nothing above this line would catch that mistake by itself.

If percent-non-null checks fail, you have a bug in your own extraction — go back and fix the
count rather than returning a value that fails its own check.

## Return format

```json
{
  "scope": "changed-files",
  "suite": "<from dispatch>",
  "kind": "coverage | mutation",
  "percent": 0,
  "files": [
    { "path": "<repo-relative path>", "covered": 0, "total": 0 }
  ],
  "survivors": [
    { "mutant_line": "<repo-relative path>:<line>", "mutant_operator": "<mutator name>" }
  ],
  "parse_status": "ok | <specific description of the failure>"
}
```

`percent` is the **pooled** percentage across the `files` array (see "The percentage is pooled"
above), never a mean of per-file percentages. `percent` is `null`, never a number, when
`parse_status` is anything other than `ok`. `survivors` applies only when `kind` is `mutation`;
omit it (or leave it empty) for a coverage dispatch. Every `survivors` entry's `mutant_line` is
`file:line` — never a bare line number — so the next audit can open the file it names. A
zero-coverage entry from the rule above is a normal member of `files`, not a special case — it
carries the same `{path, covered, total}` shape as every other entry, just with `covered: 0`.

## Red flags — STOP

- Estimating a percentage from a summary line, a log, or stdout instead of reading the report file.
- Averaging per-file percentages instead of pooling the raw counts (`sum(covered)/sum(total)`).
- Dropping a `changed_files` entry that's absent from the report, or excluding it from the
  calculation, instead of scoring it zero coverage.
