#!/bin/sh
# Final acceptance for the engineering plugin — the spec's §13.16 checklist.
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
eng=$(CDPATH= cd "$d/.." && pwd)
root=$(CDPATH= cd "$eng/.." && pwd)
fail=0

# 1. Prior gates all green (non-live).
sh "$d/suite.sh"
sh "$d/plan02.sh"
sh "$d/plan03.sh"

# 2. Ten commands resolve.
for c in signal triage vernacular improve-codebase-architecture implement handoff to-signal wait-what conventions-init record-convention; do
  test -f "$eng/commands/$c.md" || { echo "FAIL: missing command /$c"; fail=1; }
done

# 3. Every skill frontmatter valid; process-tied ones carry a [Group] tag, cross-cutting ones do not.
# One "name:[Group]" per line: a tag containing a space ("[Test hardening]") would be word-split by
# `for pair in $list`, producing bogus entries. The heredoc feeds the loop without a pipe, so it runs
# in the current shell and `fail=1` set inside survives. name/tag split on the first colon.
tagged="conducting-discovery:[Discovery]
interrogating-requirements:[Discovery]
expanding-scope:[Discovery]
sequencing-requirements:[Discovery]
to-spec:[Discovery]
domain-modeling:[Discovery]
identifying-code-conventions:[Discovery]
recording-code-conventions:[Discovery]
triage:[Triage]
brainstorming:[Design]
codebase-design:[Design]
improve-codebase-architecture:[Design]
prototype:[Design]
writing-plans:[Planning]
executing-plans:[Planning]
tdd:[Build]
diagnosing-bugs:[Build]
code-review:[Build]
using-code-conventions:[Build]
conducting-test-hardening:[Test hardening]
auditing-test-gaps:[Test hardening]
verifying-test-integrity:[Test hardening]
writing-tests-from-brief:[Test hardening]
clarifying-docblocks:[Docs]
rewriting-docblock-prose:[Docs]
verifying-docblock-claims:[Docs]
using-git-worktrees:[Foundation]
using-stacked-pull-requests:[Foundation]
finishing-a-development-branch:[Foundation]
verification-before-completion:[Foundation]
dispatching-parallel-agents:[Foundation]
using-skills:[Foundation]"
while IFS= read -r pair; do
  [ -n "$pair" ] || continue
  name=${pair%%:*}; tag=${pair#*:}
  sh "$d/frontmatter.sh" "$eng/skills/$name" "$tag" >/dev/null || { echo "FAIL: $name frontmatter/tag"; fail=1; }
done <<EOF
$tagged
EOF
for name in research resolving-merge-conflicts; do
  sh "$d/frontmatter.sh" "$eng/skills/$name" >/dev/null || { echo "FAIL: $name frontmatter"; fail=1; }
  python3 -c "import re,sys;t=open(sys.argv[1]).read();m=re.search(r'^description:\s*\"?(.)',t,re.M);assert m and m.group(1)!='[',sys.argv[1]" "$eng/skills/$name/SKILL.md" || { echo "FAIL: $name must not be tagged"; fail=1; }
done

# 4. skills/README.md lists every skill dir.
for skdir in "$eng"/skills/*/; do
  n=$(basename "$skdir")
  grep -q "\`$n\`" "$eng/skills/README.md" || { echo "FAIL: skills/README.md missing $n"; fail=1; }
done

# 5. Entrance-bootstrap hook fires and names both entrances (and no verity reminder).
sh "$d/hook.sh" >/dev/null || { echo "FAIL: hook"; fail=1; }
if grep -rq "Verity applies once implementation work is finished" "$eng/hooks" 2>/dev/null; then echo "FAIL: retired verity reminder present"; fail=1; fi

# 6. to-spec is the sole Tier-1 writer; both entrances reach it.
grep -q "docs/dashworthy/engineering/specs/" "$eng/skills/to-spec/SKILL.md" || { echo "FAIL: to-spec spec path"; fail=1; }
grep -qE "Hand off to .*engineering:brainstorming" "$eng/skills/conducting-discovery/SKILL.md" || { echo "FAIL: signal's release must hand off to the brainstorming design gate"; fail=1; }
grep -rq "to-spec" "$eng/skills/triage" || { echo "FAIL: triage must reach to-spec"; fail=1; }

# 6b. to-spec is single-caller via brainstorming, stamps Approved (post-gate input), and carries no
# stale section-for-section mapping claim.
grep -q "engineering:brainstorming" "$eng/skills/to-spec/SKILL.md" || { echo "FAIL: to-spec must name brainstorming as its caller"; fail=1; }
if grep -qE 'invoked by .*(conducting-discovery|triage)' "$eng/skills/to-spec/SKILL.md"; then echo "FAIL: to-spec names a stale caller (conducting-discovery/triage)"; fail=1; fi
grep -q "Status: Approved" "$eng/skills/to-spec/SKILL.md" || { echo "FAIL: to-spec must name the Approved status it flips to at the spec gate"; fail=1; }
grep -q "flips it to Approved" "$eng/skills/to-spec/SPEC-FORMAT.md" || { echo "FAIL: SPEC-FORMAT must document the Draft-then-Approved flip at the spec gate"; fail=1; }
if grep -q "section for section" "$eng/skills/to-spec/SKILL.md"; then echo "FAIL: stale section-for-section mapping claim"; fail=1; fi

# 6c. to-spec has exactly one imperative caller: engineering:brainstorming. Scan every skill and command
# for an imperative invocation of engineering:to-spec (verbs dispatch / hand ... to / invoke), which is
# distinct from the legitimate third-person PROSE mentions ("Brainstorming calls engineering:to-spec",
# "does it call engineering:to-spec") that describe the wiring without performing it. brainstorming/SKILL.md
# is the one allowed caller and is excluded. Any other hit means a second caller has crept in — the exact
# regression (a conductor/command re-dispatching to-spec, bypassing the design gate) this branch removed.
callers=$(grep -rnEi '(dispatch|hand[^.]*to|invoke|route[^.]*to|send[^.]*to|pass[^.]*to|delegate[^.]*to|run)[^.]*engineering:to-spec' "$eng/commands" "$eng/skills" --include='*.md' | grep -v '/skills/brainstorming/SKILL.md:' || true)
if [ -n "$callers" ]; then echo "FAIL: only engineering:brainstorming may imperatively invoke to-spec; found other caller(s):"; echo "$callers"; fail=1; fi

# 6d. The single-caller wiring's other half and the two doc surfaces the earlier tasks left unguarded:
# (a) brainstorming must actually hand off to to-spec (else to-spec has no caller at all); (b) under the
# spec-gate model the SPEC-FORMAT template stamps **Status:** Draft — the spec is written as a draft and
# the spec gate in to-spec flips it to Approved, so a stale template hard-coding Approved (pre-gate) must
# fail here; (c) the root README's signal sub-diagram routes sequence → brainstorming → to-spec.
grep -qiE "hand[^.]*engineering:to-spec" "$eng/skills/brainstorming/SKILL.md" || { echo "FAIL: brainstorming must hand off to to-spec (single-caller's other half)"; fail=1; }
grep -qF '**Status:** Draft' "$eng/skills/to-spec/SPEC-FORMAT.md" || { echo "FAIL: SPEC-FORMAT template must stamp **Status:** Draft (written first, flipped to Approved at the spec gate)"; fail=1; }
grep -qF 'S2 --> BR' "$root/README.md" && grep -qF 'BR --> SP' "$root/README.md" || { echo "FAIL: root README signal sub-diagram must route sequence -> brainstorming -> to-spec"; fail=1; }

# 7. verity is a planned step, not a session-start hook.
grep -q "conducting-test-hardening" "$eng/skills/writing-plans/SKILL.md" || { echo "FAIL: writing-plans must bake hardening"; fail=1; }
grep -q "conducting-test-hardening" "$eng/skills/finishing-a-development-branch/SKILL.md" || { echo "FAIL: finish-time hardening net missing"; fail=1; }

# 8. No dangling cross-plugin namespaces or Tier-2 paths anywhere in the plugin's content.
# Scans every content surface — skills, commands, hooks, scripts, and the plugin README; tests/ is
# excluded deliberately (these detection scripts hold the pattern literals and would self-match, same
# rationale as check 10).
# Word-form namespace match only: the bare pattern "signal:" false-fails on legit prose such as
# writing-tests-from-brief "...that is the signal: it almost always means...". Requiring a lowercase
# letter after the colon matches real namespaced refs (signal:foo) but not sentence punctuation.
if grep -rnE '(signal|verity|vernacular):[a-z]|\.signal/|\.verity\b|\.vernacular\b' "$eng/skills" "$eng/commands" "$eng/hooks" "$eng/scripts" "$eng/README.md"; then echo "FAIL: dangling refs"; fail=1; fi

# 9. .engineering/ gitignored.
grep -qxF '.engineering/' "$root/.gitignore" || { echo "FAIL: .engineering not gitignored"; fail=1; }

# 10. No NOTICE / attribution anywhere in the plugin.
# --exclude-dir=tests: these detection scripts hold the very phrases as grep patterns and would
# otherwise self-match. Plugin content (skills/commands/hooks/scripts/README) is what must stay clean.
test ! -f "$eng/NOTICE" || { echo "FAIL: NOTICE file exists"; fail=1; }
if grep -rIn --exclude-dir=tests "reproduced from" "$eng" 2>/dev/null; then echo "FAIL: attribution leak"; fail=1; fi

# 11. Old directories are gone.
for old in signal verity vernacular; do test ! -d "$root/$old" || { echo "FAIL: $old/ still present"; fail=1; }; done

[ "$fail" = 0 ] && echo "ENGINEERING ACCEPTANCE: ALL CHECKS PASS" || { echo "ACCEPTANCE FAILED"; exit 1; }
