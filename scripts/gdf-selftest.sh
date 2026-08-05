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

# ── PREFLIGHT (GDF-015): can the detector RUN on this machine at all? ──────────────────────────
# Added after the harness's first run on macOS. The scanner used `awk -v` with a multi-line value:
# legal in GNU awk (Linux, CI), rejected by BSD awk (macOS). It crashed, printed nothing, and the
# caller read nothing as clean. The fixture mismatch that followed was a CONFUSING symptom of a
# PLATFORM failure. "The detector cannot run here" now fails on its own terms, first, and loudly.
SCAN="$HERE/scan-secret-values.sh"
if [ -f "$SCAN" ]; then
  _pf="$(mktemp)"; printf 'probe_api_key: "F1XTUREPREFLIGHT0NOTREAL99"\n' > "$_pf"
  _out="$(bash "$SCAN" "$_pf" 2>&1)"; _rc=$?
  rm -f "$_pf"
  if [ "$_rc" -ge 2 ] || printf '%s' "$_out" | grep -qi 'awk:\|not found\|syntax error'; then
    echo "self-test FAIL [PREFLIGHT]: the secret detector CANNOT RUN on this machine (rc=$_rc)."
    printf '%s\n' "$_out" | sed 's/^/       /'
    echo "       This is a PLATFORM failure, not a fixture failure. awk dialect: $(awk --version 2>&1 | head -1)"
    exit 1
  fi
  if [ "$_rc" != "1" ]; then
    echo "self-test FAIL [PREFLIGHT]: the detector ran but did NOT flag an obvious planted secret (rc=$_rc)."
    exit 1
  fi
  echo "self-test ok: PREFLIGHT — detector runs here and flags a planted secret"
fi

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
