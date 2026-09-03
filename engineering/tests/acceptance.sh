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
#    command syntax). The seven former commands all resolve as skills.
cmds=$(find "$eng/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$cmds" = 0 ] || { echo "FAIL: engineering/commands must hold no command files (all commands are skills now); found $cmds"; fail=1; }
for s in signal triage receiving-code-review implement vernacular handoff wait-what; do
  test -f "$eng/skills/$s/SKILL.md" || { echo "FAIL: missing skill engineering:$s"; fail=1; }
  test ! -e "$eng/commands/$s.md" || { echo "FAIL: $s must be a skill, not a command"; fail=1; }
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

# 6. to-spec is the sole Tier-1 writer; all three entrances reach it (via brainstorming).
grep -q ".engineering/<run>/spec/" "$eng/skills/to-spec/SKILL.md" || { echo "FAIL: to-spec spec path"; fail=1; }
grep -q "engineering:brainstorming" "$eng/skills/signal/SKILL.md" || { echo "FAIL: signal skill must hand the brief to the brainstorming design gate"; fail=1; }
grep -q "engineering:brainstorming" "$eng/skills/triage/SKILL.md" || { echo "FAIL: triage (skill entrance) must reach to-spec via brainstorming"; fail=1; }

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
callers=$(grep -rnEi '(dispatch|hand[^.]*to|invoke|route[^.]*to|send[^.]*to|pass[^.]*to|delegate[^.]*to|run)[^.]*engineering:to-spec' "$eng/skills" --include='*.md' | grep -v '/skills/brainstorming/SKILL.md:' || true)
if [ -n "$callers" ]; then echo "FAIL: only engineering:brainstorming may imperatively invoke to-spec; found other caller(s):"; echo "$callers"; fail=1; fi

# 6d. The single-caller wiring's other half and the two doc surfaces the earlier tasks left unguarded:
# (a) brainstorming must actually hand off to to-spec (else to-spec has no caller at all); (b) under the
# spec-gate model the SPEC-FORMAT template stamps **Status:** Draft — the spec is written as a draft and
# the spec gate in to-spec flips it to Approved, so a stale template hard-coding Approved (pre-gate) must
# fail here; (c) the root README's signal sub-diagram routes interrogate → brainstorming → to-spec.
# Flatten newlines first: the handoff sentence wraps ("Hand the recommended design to" /
# "engineering:to-spec"), and a line-based grep would miss a phrase that straddles the wrap.
tr '\n' ' ' < "$eng/skills/brainstorming/SKILL.md" | grep -qiE "hand[^.]*engineering:to-spec" || { echo "FAIL: brainstorming must hand off to to-spec (single-caller's other half)"; fail=1; }
grep -qF '**Status:** Draft' "$eng/skills/to-spec/SPEC-FORMAT.md" || { echo "FAIL: SPEC-FORMAT template must stamp **Status:** Draft (written first, flipped to Approved at the spec gate)"; fail=1; }
grep -qF 'dimensions"| BR["brainstorming' "$root/README.md" && grep -qF 'BR --> SP' "$root/README.md" || { echo "FAIL: root README signal sub-diagram must route interrogate -> brainstorming -> to-spec"; fail=1; }

# 6e. The two gated seams must chain FORWARD past their approval gate, not park. Under the gate
# model the "stop" on to-spec / writing-plans is the gate *before* approval; once the human approves
# there is no second gate, so each skill must invoke the next act rather than wait for the user to
# re-launch it. This is exactly the failure of a handoff that says "print the path and stop" without
# the "now continue" half. Flatten newlines: the invoke phrase wraps.
tr '\n' ' ' < "$eng/skills/to-spec/SKILL.md" | grep -qiE "invoke[^.]*writing-plans[^.]*now" || { echo "FAIL: to-spec must invoke writing-plans on spec approval (forward seam must not park)"; fail=1; }
tr '\n' ' ' < "$eng/skills/writing-plans/SKILL.md" | grep -qiE "invoke[^.]*executing-plans[^.]*now" || { echo "FAIL: writing-plans must invoke executing-plans on plan approval (forward seam must not park)"; fail=1; }

# 7. The test-hardening discipline has moved to the standalone verity plugin: engineering no
# longer bakes a hardening step into its planning or finish skills.
if grep -rq "conducting-test-hardening" "$eng/skills"; then echo "FAIL: engineering still references the moved conducting-test-hardening skill"; fail=1; fi

# 7b. executing-plans must hand off to finishing-a-development-branch when the plan completes. The plan
# gate pre-authorizes the finish strategy so finishing carries it out unattended (plan gate = last human
# stop); a handoff that stops at the last checked box without reaching finishing re-opens the
# phantom-gate the pre-authorization was meant to close. Flatten newlines: the phrase wraps.
tr '\n' ' ' < "$eng/skills/executing-plans/SKILL.md" | grep -qiE "hand[^.]*engineering:finishing-a-development-branch" || { echo "FAIL: executing-plans must hand off to finishing-a-development-branch on plan completion"; fail=1; }

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
