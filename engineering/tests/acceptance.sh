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

# 2. No slash-commands remain — every entry point is a skill now (decoupling from Claude-specific
#    command syntax). The three entrances carried real content and resolve as skills.
#    implement/vernacular never got a skill: they were shallow wrappers adding nothing over
#    engineering:build and engineering:document, invoked directly instead.
#    handoff/wait-what are deprecated and removed outright — no skill, no command.
cmds=$(find "$eng/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$cmds" = 0 ] || { echo "FAIL: engineering/commands must hold no command files (all commands are skills now); found $cmds"; fail=1; }
for s in signal triage receiving-code-review; do
  test -f "$eng/skills/$s/SKILL.md" || { echo "FAIL: missing skill engineering:$s"; fail=1; }
  test ! -e "$eng/commands/$s.md" || { echo "FAIL: $s must be a skill, not a command"; fail=1; }
done
for wrapper in implement vernacular; do
  test ! -e "$eng/skills/$wrapper" || { echo "FAIL: skills/$wrapper must not exist (was a shallow wrapper; invoke the underlying skill directly)"; fail=1; }
done
for deprecated in handoff wait-what; do
  test ! -e "$eng/skills/$deprecated" || { echo "FAIL: skills/$deprecated must not exist (deprecated)"; fail=1; }
  test ! -e "$eng/commands/$deprecated.md" || { echo "FAIL: commands/$deprecated.md must not exist (deprecated)"; fail=1; }
done

# 3. Every skill's frontmatter is valid: `name` matches its dir and `description` is present.
for skdir in "$eng"/skills/*/; do
  name=$(basename "$skdir")
  sh "$d/frontmatter.sh" "$skdir" >/dev/null || { echo "FAIL: $name frontmatter"; fail=1; }
done

# 4. skills/README.md lists every skill dir.
for skdir in "$eng"/skills/*/; do
  n=$(basename "$skdir")
  grep -q "\`$n\`" "$eng/skills/README.md" || { echo "FAIL: skills/README.md missing $n"; fail=1; }
done

# 5. Entrance-bootstrap hook fires and names all three entrances (and no verity reminder).
sh "$d/hook.sh" >/dev/null || { echo "FAIL: hook"; fail=1; }
if grep -rq "Verity applies once implementation work is finished" "$eng/hooks" 2>/dev/null; then echo "FAIL: retired verity reminder present"; fail=1; fi

# 6. The design conductor's spec-writing stage is the sole Tier-1 writer; all three entrances reach
# the design conductor. to-spec folded into design/references/spec-writing.md (the run-dir slug stays
# `to-spec`); the spec is still written under .engineering/<run>/spec/.
SPECWRITE="$eng/skills/design/references/spec-writing.md"
SPECFMT="$eng/skills/design/references/SPEC-FORMAT.md"
grep -q ".engineering/<run>/spec/" "$SPECWRITE" || { echo "FAIL: spec-writing stage spec path"; fail=1; }
grep -q "engineering:design" "$eng/skills/signal/SKILL.md" || { echo "FAIL: signal skill must hand the brief to the design phase"; fail=1; }
grep -q "engineering:design" "$eng/skills/triage/SKILL.md" || { echo "FAIL: triage entrance must reach the design phase"; fail=1; }
grep -q "engineering:design" "$eng/skills/receiving-code-review/SKILL.md" || { echo "FAIL: receiving-code-review entrance must reach the design phase"; fail=1; }

# 6b. The spec-writing stage stamps Approved (post-gate) and carries no stale section-for-section claim.
grep -q "Status: Approved" "$SPECWRITE" || { echo "FAIL: spec-writing stage must name the Approved status it flips to at the spec gate"; fail=1; }
grep -q "flips it to Approved" "$SPECFMT" || { echo "FAIL: SPEC-FORMAT must document the Draft-then-Approved flip at the spec gate"; fail=1; }
if grep -q "section for section" "$SPECWRITE"; then echo "FAIL: stale section-for-section mapping claim"; fail=1; fi

# 6c. to-spec is no longer a skill — no skill or reference may invoke engineering:to-spec (the
# design conductor loads references/spec-writing.md internally instead). A lingering
# engineering:to-spec invocation would mean the fold left a dangling dispatch that bypasses the
# design conductor's own spec stage.
if grep -rn 'engineering:to-spec' "$eng/skills" --include='*.md'; then
  echo "FAIL: engineering:to-spec must not be invoked anywhere (to-spec folded into the design conductor)"; fail=1; fi

# 6d. The design conductor must actually route into its spec-writing stage (else the spec is never
# written); the SPEC-FORMAT template stamps **Status:** Draft (flipped to Approved at the gate); and
# the root README's signal sub-diagram routes interrogate → design.
grep -q 'references/spec-writing.md' "$eng/skills/design/SKILL.md" || { echo "FAIL: design conductor must load its spec-writing stage"; fail=1; }
grep -qF '**Status:** Draft' "$SPECFMT" || { echo "FAIL: SPEC-FORMAT template must stamp **Status:** Draft (written first, flipped to Approved at the spec gate)"; fail=1; }
grep -qF 'dimensions"| BR["design' "$root/README.md" && grep -qF 'BR --> SP' "$root/README.md" || { echo "FAIL: root README signal sub-diagram must route interrogate -> design"; fail=1; }

# 6e. The gated seams must chain FORWARD past their approval gate, not park. Once the human approves
# there is no second gate, so each stage must invoke the next act rather than wait to be re-launched.
# Flatten newlines: the invoke phrase wraps.
tr '\n' ' ' < "$SPECWRITE" | grep -qiE "invoke[^.]*plan[^.]*now" || { echo "FAIL: spec-writing stage must invoke plan on spec approval (forward seam must not park)"; fail=1; }
tr '\n' ' ' < "$eng/skills/plan/SKILL.md" | grep -qiE "invoke[^.]*build[^.]*now" || { echo "FAIL: plan must invoke build on plan approval (forward seam must not park)"; fail=1; }

# 7. The test-hardening discipline has moved to the standalone verity plugin: engineering no
# longer bakes a hardening step into its planning or finish skills.
if grep -rq "conducting-test-hardening" "$eng/skills"; then echo "FAIL: engineering still references the moved conducting-test-hardening skill"; fail=1; fi

# 7b. build must hand off to finish when the plan completes. The plan
# gate pre-authorizes the finish strategy so finishing carries it out unattended (plan gate = last human
# stop); a handoff that stops at the last checked box without reaching finishing re-opens the
# phantom-gate the pre-authorization was meant to close. Flatten newlines: the phrase wraps.
tr '\n' ' ' < "$eng/skills/build/SKILL.md" | grep -qiE "hand[^.]*engineering:finish" || { echo "FAIL: build must hand off to finish on plan completion"; fail=1; }

# 8. No dangling cross-plugin namespaces or Tier-2 paths anywhere in the plugin's content.
# Scans every content surface — skills, commands, hooks, scripts, and the plugin README; tests/ is
# excluded deliberately (these detection scripts hold the pattern literals and would self-match, same
# rationale as check 10).
# Word-form namespace match only: the bare pattern "signal:" false-fails on legit prose such as
# writing-tests-from-brief "...that is the signal: it almost always means...". Requiring a lowercase
# letter after the colon matches real namespaced refs (signal:foo) but not sentence punctuation.
if grep -rnE '(signal|verity|vernacular):[a-z]|\.signal/|\.verity\b|\.vernacular\b' "$eng/skills" "$eng/hooks" "$eng/scripts" "$eng/README.md"; then echo "FAIL: dangling refs"; fail=1; fi

# 9. .engineering/ gitignored.
grep -qxF '.engineering/' "$root/.gitignore" || { echo "FAIL: .engineering not gitignored"; fail=1; }

# 10. No NOTICE / attribution anywhere in the plugin.
# --exclude-dir=tests: these detection scripts hold the very phrases as grep patterns and would
# otherwise self-match. Plugin content (skills/commands/hooks/scripts/README) is what must stay clean.
test ! -f "$eng/NOTICE" || { echo "FAIL: NOTICE file exists"; fail=1; }
if grep -rIn --exclude-dir=tests "reproduced from" "$eng" 2>/dev/null; then echo "FAIL: attribution leak"; fail=1; fi

# 11. Old codename directories are gone. (verity is intentionally NOT here: it is now a
# standalone sibling plugin at the marketplace root, not a retired engineering codename dir.)
for old in signal vernacular; do test ! -d "$root/$old" || { echo "FAIL: $old/ still present"; fail=1; }; done

[ "$fail" = 0 ] && echo "ENGINEERING ACCEPTANCE: ALL CHECKS PASS" || { echo "ACCEPTANCE FAILED"; exit 1; }
