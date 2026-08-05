#!/usr/bin/env bash
# gdf-check — executable intake gate (GDF-006). NO work starts until this exits 0.
# Usage: scripts/gdf-check.sh [path/to/gdf-config.yaml]   (default: ./gdf-config.yaml)
set -u
CFG="${1:-gdf-config.yaml}"
FAIL=0
say(){ printf '%s\n' "$*"; }
ok(){ say "  ✅ $*"; }
bad(){ say "  ❌ $*"; FAIL=1; }

say "[1] config file exists"
[ -f "$CFG" ] && ok "$CFG present" || { bad "$CFG missing — copy templates/gdf-config.template.yaml"; exit 1; }

say "[2] no unfilled placeholders"
if grep -n "<FILL" "$CFG" >/dev/null; then
  bad "unfilled <FILL> values:"; grep -n "<FILL" "$CFG" | sed 's/^/     /'
else ok "all fields filled"; fi

say "[3] NO secret values in config (names only)"
# v1.2 REPAIR (Increment 12, Security seat — GDF-010). This check FAILED OPEN.
#   old: grep -nEi '(password|token|secret|api[_-]?key)...' "$CFG" | grep -vi 'required\|_name\|<FILL'
# The exclusion filter matched the WHOLE LINE, so one innocuous word in a trailing comment
# laundered a live credential:
#   api_key: "AKIAIOSFODNN7EXAMPLE"  # required for staging deploy    → NOT FLAGGED
# Same fail-open shape as the step-8 defect repaired in v1.1 (GDF-009), on the FIRST-named
# non-negotiable in the constitution. The old pattern additionally never covered
# `access_key`, `private_key` or `credential` at all — two misses, not one.
# REPAIR: match on the VALUE, exclude on the KEY. Comment text can no longer influence the verdict.
# v1.2 follow-up (GDF-013, Skeptic re-poll): the detector is now ONE shared implementation in
# scripts/scan-secret-values.sh, because it was written twice in this cut and the second copy (the
# new CI workflow) reintroduced the very defect this repaired. Two more bypasses closed there:
# a placeholder PREFIX no longer launders a real value, and any *_key name now counts.
# Regression fixtures: conformance/secret-values/ (run scripts/gdf-selftest.sh).
SECRET_HITS="$(bash "$(dirname "$0")/scan-secret-values.sh" "$CFG")"; SECRET_RC=$?
# v1.2 fix (pre-ship audit): the caller used to branch on `-n "$SECRET_HITS"` alone, so ANY empty
# output — including a crashed scanner — read as clean. The scanner exits 2 on internal error
# precisely so this branch exists. Fail CLOSED on rc>=2.
if [ "$SECRET_RC" -ge 2 ]; then bad "secret scanner FAILED TO RUN (rc=$SECRET_RC) — treated as a hit, not as clean"; fi
if [ -n "$SECRET_HITS" ]; then
  bad "possible secret VALUE pasted into config — move it to CI secrets, keep only the NAME:"
  printf '%s\n' "$SECRET_HITS" | sed 's/^/     /'
else ok "no secret values detected"; fi
if grep -nE 'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY' "$CFG" >/dev/null; then bad "private key material in config"; fi

say "[4] charter signed"
grep -qE 'charter_signed:\s*true' "$CFG" && ok "charter_signed: true" || bad "charter_signed is not true — owner must sign GDF-CHARTER.md first"

say "[5] charter file present"
[ -f "GDF-CHARTER.md" ] && ok "GDF-CHARTER.md present" || bad "GDF-CHARTER.md missing (templates/GDF-CHARTER.template.md)"

say "[6] branch protection confirmed"
grep -qE 'protected_branches_configured:\s*true' "$CFG" && ok "protected branches confirmed" || bad "protected_branches_configured is not true — set protection per permission-matrix §2, then flip"

say "[7] SonarCloud automatic-analysis gotcha (if sonarcloud)"
if grep -qE 'provider:\s*"?sonarcloud' "$CFG"; then
  grep -qE 'automatic_analysis_disabled:\s*true' "$CFG" && ok "automatic analysis disabled" || bad "SonarCloud Automatic Analysis must be OFF before first CI run (gotcha #1)"
else ok "n/a (non-sonarcloud QG)"; fi

say "[8] non-negotiables not disabled"
grep -qiE '^[[:space:]]*gitleaks:[[:space:]]*"?(true|yes|on)"?[[:space:]]*(#.*)?$' "$CFG" && ok "gitleaks on" || bad "gitleaks must be true (not configurable)"
grep -qiE '^[[:space:]]*dependency_audit:[[:space:]]*"?(true|yes|on)"?[[:space:]]*(#.*)?$' "$CFG" && ok "dependency audit on" || bad "dependency_audit must be true (not configurable)"
# v1.1 Phase-0 repair (Increment 11): this block used to FAIL OPEN. `enabled: True` (capital T),
# `TRUE` or `yes` did not match the old lowercase-only pattern, so the script printed
# "deploy disabled" and SKIPPED the owner-required-reviewer assertion — a declared non-negotiable
# (GDF-003) silently unchecked. It also carried dead code: `grep -qA3 ... | grep -q ...` pipes
# nothing (-q suppresses output). Both fixed. Unrecognised values now FAIL CLOSED.
DEPLOY_VAL="$(sed -n 's/^[[:space:]]*enabled:[[:space:]]*"\{0,1\}\([A-Za-z]*\)"\{0,1\}[[:space:]]*\(#.*\)\{0,1\}$/\1/p' "$CFG" | head -1 | tr 'A-Z' 'a-z')"
case "$DEPLOY_VAL" in
  true|yes|on)
    grep -qiE '^[[:space:]]*required_reviewer:[[:space:]]*"?owner"?' "$CFG" \
      && ok "prod deploy owner-gated (deploy enabled)" \
      || bad "deploy is ENABLED but production.required_reviewer is not owner (GDF-003)" ;;
  false|no|off)
    ok "deploy disabled — trunk is the end of the line" ;;
  "")
    bad "deploy.enabled not found — fill it (true|false); an absent value is not a disabled deploy" ;;
  *)
    bad "deploy.enabled has an unrecognised value '$DEPLOY_VAL' — use true|false (fail-closed)" ;;
esac

say "[9] tracker-side invariants (v1.1, GDF11-01 — WARN only, never fails intake)"
warn(){ say "  ⚠️  $*"; }
grep -qE 'ac_required_at_creation:\s*true' "$CFG" && ok "AC-required-at-creation confirmed" || warn "ac_required_at_creation not confirmed — configure Jira required fields/automation, keep the config evidence, then flip the flag"
grep -qE 'assignee_only_transitions:\s*true' "$CFG" && ok "assignee-only transitions confirmed" || warn "assignee_only_transitions not confirmed — restrict key transitions to the assignee, then flip the flag"

say ""
if [ "$FAIL" -eq 0 ]; then say "GDF-CHECK PASS — intake complete, Discovery may begin."; exit 0
else say "GDF-CHECK FAIL — fix the ❌ items; no tasks, no branches, no PRs until green."; exit 1; fi
