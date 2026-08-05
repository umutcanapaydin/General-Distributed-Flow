#!/usr/bin/env bash
# gdf-selftest — prove gdf-check.sh's checks actually FIRE (GDF-011, Increment 12).
#
# WHY THIS EXISTS. GDF shipped v1.0 and v1.1 with an intake gate that nothing tested. Two of its
# steps were found FAIL-OPEN by councils that read the code rather than the docs:
#   step 8 (v1.1, GDF-009) — `enabled: True` printed "deploy disabled" and skipped the
#                            owner-required-reviewer assertion, a declared non-negotiable
#   step 3 (v1.2, GDF-010) — one word in a trailing comment laundered a live credential
# Both repairs were verified by hand and left NO artifact in the tree, so a regression would have
# been silent. This is that artifact.
#
# V4C-50 (GP, Increment 12) is the governing rule: **a suite that bypasses the layer where the bug
# lives is correctly green and completely uninformative.** So this harness runs the REAL
# `gdf-check.sh` against each fixture. It does not re-implement a single pattern. If it re-implemented
# the detector, it would certify the copy and not the control.
#
# Usage: scripts/gdf-selftest.sh        Exit: 0 all fixtures behaved · 1 a check did not fire
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
CHECK="$HERE/gdf-check.sh"
CONF="$ROOT/conformance"
BAD=0

[ -x "$CHECK" ] || { echo "self-test FAIL: $CHECK not executable"; exit 1; }
[ -d "$CONF" ]  || { echo "self-test FAIL: conformance/ missing"; exit 1; }

# Each fixture declares its expectation on the FIRST line: `# expect: <STEP> <FLAG|CLEAN>`
for fx in "$CONF"/*/*.yaml; do
  [ -f "$fx" ] || continue
  name="$(basename "$(dirname "$fx")")/$(basename "$fx")"
  spec="$(head -1 "$fx" | sed -n 's/^#[[:space:]]*expect:[[:space:]]*//p')"
  if [ -z "$spec" ]; then
    echo "self-test FAIL: $name declares no '# expect: <STEP> <FLAG|CLEAN>' first line"; BAD=1; continue
  fi
  step="${spec%% *}"; want="${spec##* }"

  # the real entry point, in a scratch dir so the fixture is the config under test
  tmp="$(mktemp -d)"; cp "$fx" "$tmp/gdf-config.yaml"
  out="$(cd "$tmp" && bash "$CHECK" gdf-config.yaml 2>&1)"; rm -rf "$tmp"

  # the step's own verdict line: ❌ means the check fired, ✅ means it passed the input
  verdict="$(printf '%s\n' "$out" | awk -v s="[$step]" '
    index($0, s) == 1 {inblk = 1; next}
    /^\[[0-9]+\]/     {inblk = 0}
    inblk && /❌/     {print "FLAG"; exit}')"
  [ -n "$verdict" ] || verdict="CLEAN"

  if [ "$verdict" = "$want" ]; then
    echo "self-test ok: $name → step $step $want"
  else
    echo "self-test FAIL: $name → step $step expected $want, got $verdict"
    printf '%s\n' "$out" | sed -n "/\[$step\]/,/^\[/p" | sed 's/^/       /'
    BAD=1
  fi
done

if [ "$BAD" = "0" ]; then echo; echo "gdf-selftest PASS: every fixture behaved as declared"; exit 0; fi
echo; echo "gdf-selftest FAIL: a declared check did not fire — treat as a live defect, not a test bug"
exit 1
