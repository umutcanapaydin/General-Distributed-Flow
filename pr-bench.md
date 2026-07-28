# GDF PR Bench — the risk-tiered technical review gate

> Every PR passes a bench of fresh-eyes agent reviewers (never the author). Verdicts are
> **GitHub PR reviews** in structured format — platform artifacts, timestamped, per-seat
> attributable — and the tier's seat-set maps to **required status checks**: merge is mechanically
> blocked until the tier's seats are green. The PM cannot override; only the owner can (audited).

## 1. Tiers (assigned by a labeler bot from globs + diffstat — never agent-asserted; one-way ratchet up)

| Tier | Triggers | Bench |
|---|---|---|
| **LOW** | ≤150 changed LOC · no ⛔-glob · no dependency/schema/CI changes · single module or docs/tests only | ONE combined reviewer (Code-Reviewer checklist incl. secret scan + test-integrity) |
| **MED** | ≤600 LOC · app logic across ≤3 modules · no ⛔-glob | Code Reviewer + Tester (affected-flow E2E) — two independent verdicts |
| **HIGH** | any ⛔-glob · >600 LOC · dependency manifest/lockfile change · public API or schema change | FULL BENCH: Code Reviewer · Tester · Software Engineer · Quality · DevOps · **Data (auto-seated on data triggers)** — **plus the OWNER as required reviewer on ⛔ paths (sync exception)** |

**Data-seat triggers:** `/migrations/**`, `**/schema/**`, `**/*.sql`, `**/etl/**`, `**/pipelines/**`,
`**/seeds/**`, `**/contracts/**`, `**/fixtures/**`, or a diff intersecting PII-tagged columns.

**Anti tier-gaming:** cumulative merged LOC **per Jira task** counts toward the tier (splitting a
HIGH task into many LOW PRs escalates anyway); Quality seat spot-audits LOW-tier streams.

## 2. Verdict format (per seat, in the GitHub review body)

```
VERDICT: PASS | MINOR | BLOCKING
FINDINGS:
- [BLOCKING|MINOR] file:line — issue — evidence (failing test / rule ID / repro command)
AC-HASH CHECKED: <hash from PR description matches Jira task>  ✅/❌
```

BLOCKING → PR cannot merge; Jira throwback route fires. A BLOCKING finding without a citable
evidence referent is invalid (evidence rule applies to reviewers too).

## 3. The never-bends per-PR bar

Unit tests green **+** a citing test mapped to the task's AC hash **+** Semgrep/secret scan clean
**+** test-integrity diff clean (no weakened/deleted-to-green — BLOCKING) **+** the tier's bench
seats green **+** commit trailers valid **+** diff within size cap.

## 4. Economics at speed (what moves off the per-PR path)

- **Full E2E regression → nightly** (per-PR Playwright runs only the affected-flow subset, MED/HIGH).
- **Fault-injection → mandatory per HIGH PR** + a weekly trunk sweep (break → RED? stay-green =
  missing test, mandatory before the next merge on that surface).
- Deep dependency/license audit → weekly.
- **Smoke test per PR always** (cheap, fast, on the tested SHA).

## 5. Review checklist highlights (inherited from GP profiles, applied per PR)

Code Reviewer: plan/AC compliance · duplication-vs-reuse · drive-by edits (out-of-scope → reject
into follow-up task) · swallowed exceptions · secrets. Tester: citing test proves the AC through
the LIVE entrypoint (built≠wired) · symptom reproduced red→green for bugfixes · test-integrity.
Software Engineer (HIGH): architecture/contract impact · alternative considered. Quality (HIGH):
AC-to-test traceability · coverage adequacy on the diff. DevOps (HIGH): CI/deploy/infra impact ·
no control-plane touches. Data (triggered): migration protocol (serialized, forward-only, tested
rollback, expand/contract) · canonical-schema drift · PII columns.
