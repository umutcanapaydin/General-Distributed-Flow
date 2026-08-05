#!/usr/bin/env bash
# scan-secret-values — ONE implementation of "is a secret VALUE pasted here?" (GDF-013, v1.2).
#
# WHY THIS FILE EXISTS. The detector was written twice in one cut and got it wrong the second time.
# `gdf-check.sh` step 3 was repaired (GDF-010: the exclusion matched the whole LINE, so a trailing
# comment laundered a live credential) — and then the brand-new CI workflow reintroduced **the exact
# same shape** in its own inline grep. The Skeptic seat found it by constructing
# `prod_api_key: "AKIA…"  # env_name reference`, which the CI step silently passed.
# Two copies of a security check is one copy too many. Both callers now source this.
#
# WHAT IT IS, STATED HONESTLY. This is a **config-hygiene heuristic**, not a secret scanner.
# `gitleaks` is the secret scanner and it is a non-negotiable (`gdf-check.sh` step 8, always on,
# including spike branches). This check exists because the config file is authored by hand at intake
# and a pasted credential there is a specific, recurring mistake. A complete detector is REFUSED by
# decision: gitleaks already exists, and a second half-good scanner invites trusting the wrong one.
# **"Zero false positives" is not the claim "cannot be bypassed."** The Skeptic seat made that
# distinction and it is recorded here rather than papered over.
#
# CONTRACT: prints `line:content` for each suspected secret VALUE; exits 0 always (the caller
# decides). Match on the VALUE. Exclude on the KEY. Comment text never influences the verdict.
#
# Usage: scripts/scan-secret-values.sh FILE [FILE...]
#
# EXIT CODES — and this matters more than it looks. The first version of this file exited 0
# unconditionally, "letting the caller decide". It then crashed on a stray apostrophe inside its own
# awk program (in a comment explaining a fail-open, no less) and both callers read the empty output
# as "no secrets found". **A crashed detector that reports clean is the fail-open, one level up.**
#   0 = ran, nothing found · 1 = ran, suspected secret VALUE(s) printed · 2 = could not run
set -u
set -o pipefail
trap 'echo "scan-secret-values: INTERNAL ERROR — treat as FAIL, not as clean" >&2; exit 2' ERR

# The allowlist: exact literals that appear in documentation. See .secret-scan-allow.
ALLOW_FILE="$(dirname "$0")/../.secret-scan-allow"
ALLOW=""
[ -f "$ALLOW_FILE" ] && ALLOW="$(sed 's/[[:space:]]*#.*$//' "$ALLOW_FILE" | grep -v '^[[:space:]]*$' || true)"

RC=0
for f in "$@"; do
  [ -f "$f" ] || continue
  awk -v FNAME="$f" -v ALLOW="$ALLOW" '
    BEGIN { n = split(ALLOW, A, "\n"); for (i = 1; i <= n; i++) { gsub(/^[ \t]+|[ \t]+$/, "", A[i]); if (A[i] != "") ALLOWED[A[i]] = 1 } }
    {
      # A comment line is not an assignment. Without this the scanner flags its own documentation:
      # `decisions.md` and `gdf-check.sh` both quote the GDF-010 defect input verbatim, using the
      # published AWS example key, so the next reader can see what got laundered. A scanner that
      # fails on the record of the bug it fixed is a scanner people switch off.
      if ($0 ~ /^[ \t]*#/) next
      p = index($0, ":"); q = index($0, "=")
      if (p == 0 || (q > 0 && q < p)) p = q
      if (p == 0) next
      key = substr($0, 1, p - 1); val = substr($0, p + 1)
      gsub(/^[ \t-]+|[ \t]+$/, "", key); gsub(/^[ \t]+/, "", val)
      # This detects a CONFIG ASSIGNMENT. A markdown sentence or table cell is not one. Without
      # this, lowering the length floor made the scanner flag 11 lines of its own prose ("...the
      # workflow-dispatch token is the soft underbelly: scope to..."). A key is a plain identifier.
      if (key !~ /^[A-Za-z_][A-Za-z0-9_.-]*$/) next
      if (val ~ /^#/) next                          # `key:   # comment` — the value is empty
      if (val ~ /[()]/) next                        # a call expression (`key = k.strip()`), not a literal
      # Isolate the VALUE. The comment must never reach the exclusion tests below — that was
      # GDF-010. An earlier guard here ("skip the strip if the value looks like an open quoted
      # string") matched ANY quoted value followed by a comment, so the comment survived and the
      # line was then discarded as prose. Latent until the prose filter was added; found by running
      # the harness. Quoted values are now read to their closing quote; unquoted ones cut at ` #`.
      q = substr(val, 1, 1)
      if (q == "\"" || q == "'"'"'") {
        rest = substr(val, 2); ci = index(rest, q)
        val = (ci > 0) ? substr(rest, 1, ci - 1) : rest
      } else {
        sub(/[ \t]+#.*$/, "", val); gsub(/[ \t]+$/, "", val)
      }

      lk = tolower(key)
      # ── does the KEY claim to hold a secret? ────────────────────────────────────────────
      # v1.2 widening (Skeptic re-poll): the first list missed `webhook_signing_key` and `bearer`.
      # Any key ending in `key`/`_key` now counts, plus explicit high-risk names.
      secretish = (lk ~ /password|passwd|passwd|[_-]pass$|^pass$|[_-]pwd|^pwd|token|secret|credential|bearer|signing[_-]?key|encryption[_-]?key|private[_-]?key|access[_-]?key|api[_-]?key|auth/) \
                  || (lk ~ /(^|[_-])key$/)
      if (!secretish) next

      # ── naming a secret is the POINT of this file — those keys are exempt ────────────────
      # v1.2 fix #3 (zero-context pre-ship audit): these suffixes used to exempt the row
      # UNCONDITIONALLY, so `api_key_ref: "AKIA…"` shipped a live credential through the gate. The
      # exemption exists for rows that name a CI secret — so it now requires the VALUE to actually
      # look like a name (SCREAMING_SNAKE or short), not merely the key to end in `_ref`.
      # A CI secret NAME is SCREAMING_SNAKE with at least one underscore — `SONAR_TOKEN`,
      # `DEPLOY_SSH_KEY`. `AKIA<20-char-key>` is also uppercase alphanumeric and is not a name.
      # Same discriminator as the standalone-value exemption below; kept identical on purpose.
      if (lk ~ /(_name|_names|_ref|_env|_var|_id|_registry|_label|_provider)$/) {
        if (val ~ /^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$/) next
        if (length(val) < 8) next
      }

      # ── placeholders. v1.2 fix (Skeptic re-poll): the exemption was anchored only at the
      #    START, so `changeme_<real-key-appended>` was laundered by its own prefix.
      #    A placeholder must now be the WHOLE value.
      if (val ~ /^<[^>]*>$/)                       next    # <FILL — anything>
      if (val ~ /^\$\{[^}]*\}$/ || val ~ /^\$\([^)]*\)$/) next    # ${VAR} $(cmd)
      if (val ~ /^\$[A-Za-z_][A-Za-z0-9_]*$/)      next    # $VAR
      if (tolower(val) ~ /^(changeme|change-me|replace|replace-me|todo|tbd|none|null|n\/a|xxx+|\.\.\.|example|placeholder|dummy)$/) next
      # A bare CI-secret NAME is the legitimate content of this file. But the first version of this
      # exemption was `^[A-Z][A-Z0-9_]{2,}$`, which exempted `AKIAIOSFODNN7EXAMPLE` — an AWS key is
      # also uppercase alphanumeric. It silently un-fixed both GDF-010 fixtures. Caught by running
      # the harness, which is the entire reason the harness exists.
      # A secret NAME has an underscore (`SONAR_TOKEN`, `DEPLOY_SSH_KEY`); a raw credential does not.
      if (val ~ /^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$/)    next

      if (val in ALLOWED) next                   # documented literal (.secret-scan-allow)
      # v1.2 fix #4: the floor was 12, and `admin_password: "Adm1n#2026"` (10) walked through.
      # 8 is the shortest length any sane policy permits, so it is the shortest thing worth flagging.
      if (length(val) < 8) next
      # v1.2 fix #5: "contains a space ⇒ prose" let a passphrase through
      # (`wifi_password: "correct horse battery staple2026"`). Only genuinely sentence-shaped values
      # are prose now: ≥4 words AND no digit and no symbol.
      if (val ~ /[ \t]/ && split(val, W, /[ \t]+/) >= 4 && val !~ /[0-9]/ && val !~ /[^A-Za-z \t]/) next
      printf "%s:%d:%s\n", FNAME, NR, $0
      hits++
    }
    END { exit (hits ? 1 : 0) }' "$f" || RC=1
done
exit "${RC:-0}"
