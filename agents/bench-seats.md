# GDF Bench Seat Profiles (ephemeral, fresh-eyes — dispatched per PR by tier)

> Common rules: the seat NEVER reviewed its own authored code (fresh-eyes); verdicts are GitHub
> PR reviews in the structured format (`pr-bench.md` §2); every BLOCKING finding cites evidence
> (failing test / rule ID / repro); a stay-green fault or invalid AC-hash is BLOCKING; seats may
> escalate tier up, never down. Countersign duty: on HIGH PRs, one seat verifies 2 random claims
> in the PR description against the actual artifacts (anti self-attestation).

## Code Reviewer (all tiers; the combined reviewer at LOW)
AC compliance · correctness · duplication-vs-reuse · drive-by edits (out-of-scope → reject into a
follow-up task) · swallowed-exception wallpaper · secret scan · test-integrity diff (weakened/
deleted-to-green = BLOCKING) · trailers + AC-hash present.

## Tester (MED/HIGH)
Citing test proves each touched AC through the LIVE entrypoint · affected-flow E2E subset ·
bugfix = symptom reproduced red→green · **fault-injection on HIGH:** break the load-bearing
behavior → confirm RED → revert in place, verify byte-identical → stay-green = the finding →
mandatory new test before the next merge on that surface.

## Software Engineer (HIGH)
Architecture/contract impact · public-API and cross-module coherence · was an alternative
considered · generalization smell (clever-but-fragile).

## Quality (HIGH)
AC-to-test traceability audit · coverage adequacy ON THE DIFF · tier-assignment audit (cumulative
task LOC; tier-gaming spot checks on LOW streams).

## DevOps (HIGH)
CI/deploy/infra impact · workflow/config diffs are control-plane (⛔ — owner required) ·
dependency/lockfile changes verified (real package, maintained, license) · artifact/deploy path sane.

## Data Engineer (auto-seated on data triggers)
Migration protocol: serialized · forward-only + CI-tested rollback path · expand/contract on live
columns · canonical-schema drift check (migration is the ONLY schema mutation path) · contract
tests at producer/consumer boundaries · PII-tagged column touches → redaction/encryption asserts.
