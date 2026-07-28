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
if grep -nEi '(password|token|secret|api[_-]?key)[\"'"'"']?\s*[:=]\s*[\"'"'"']?[A-Za-z0-9_\-\.\+/]{12,}' "$CFG" | grep -vi 'required\|_name\|<FILL' >/dev/null; then
  bad "possible secret VALUE pasted into config — move it to CI secrets, keep only the NAME"
else ok "no secret values detected"; fi
if grep -nE 'BEGIN (RSA|OPENSSH|EC) PRIVATE KEY' "$CFG" >/dev/null; then bad "private key material in config"; fi

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
grep -qE 'gitleaks:\s*true' "$CFG" && ok "gitleaks on" || bad "gitleaks must be true (not configurable)"
grep -qE 'dependency_audit:\s*true' "$CFG" && ok "dependency audit on" || bad "dependency_audit must be true (not configurable)"
if grep -qE 'enabled:\s*"?true' "$CFG" && grep -qA3 'production:' "$CFG" | grep -q 'required_reviewer' ; then :; fi
if grep -qE '^\s*enabled:\s*"?true' "$CFG"; then
  grep -qE 'required_reviewer:\s*"?owner' "$CFG" && ok "prod deploy owner-gated" || bad "production.required_reviewer must be owner (GDF-003)"
else ok "deploy disabled — trunk is the end of the line"; fi

say ""
if [ "$FAIL" -eq 0 ]; then say "GDF-CHECK PASS — intake complete, Discovery may begin."; exit 0
else say "GDF-CHECK FAIL — fix the ❌ items; no tasks, no branches, no PRs until green."; exit 1; fi
