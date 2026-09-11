#!/bin/sh
# Validate skill YAML frontmatter: `name` present and matches its dir, and `description` present.
# Usage: frontmatter.sh <skill-dir>   validate one skill
#        frontmatter.sh               validate every skill under ../skills/
set -e

validate_one() {
  dir=$1
  skill=$(basename "$dir")
  f="$dir/SKILL.md"
  [ -f "$f" ] || { echo "FAIL: no SKILL.md in $dir"; exit 1; }
  python3 - "$f" "$skill" <<'PY'
import sys,re
f,skill=sys.argv[1],sys.argv[2]
t=open(f,encoding="utf-8").read()
m=re.match(r'^---\n(.*?)\n---\n', t, re.S)
assert m, "no frontmatter block"
fm=m.group(1)
name=re.search(r'^name:\s*(.+)$', fm, re.M)
desc=re.search(r'^description:\s*(.+)$', fm, re.M)
def unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        s = s[1:-1]
    return s
name_v = unquote(name.group(1)) if name else None
desc_v = unquote(desc.group(1)) if desc else None
assert name and name_v == skill, f"name must equal dir '{skill}'"
assert desc and desc_v, "description required"
print("ok",skill)
PY
  echo "PASS frontmatter $skill"
}

if [ -n "$1" ]; then
  validate_one "$1"
else
  sd=$(CDPATH= cd "$(dirname "$0")/../skills" && pwd)
  for d in "$sd"/*/; do
    validate_one "$d"
  done
fi
