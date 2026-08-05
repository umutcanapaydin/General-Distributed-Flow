---
record_type: design
id: gdf-constitution
status: ratified
process_version: v1.2
requires: [gdf-decisions]
---
# GDF Constitution — inherited core + explicit overrides

> **Model: REFERENCE, never copy** (Skeptic ruling, design council 2026-07-17). The constitution's
> single source of truth is the General Pipeline repo; GDF records ONLY its deltas below.
> **If the override appendix grows past one page, that is the drift alarm.**

## 1. Inherited core (binding, unchanged — pinned to **GP v4.2** as of GDF v1.2)

Source: `github.com/SADCAIVibe/General_Pipeline` → `general_pipeline_v4.0/` (re-pinned
deliberately at the v1.1 cut per GDF-007/GDF-008; charters signed before 2026-07-30 keep their
original v3.3 pin — pinned means pinned. The v4.0 pin additionally binds the **base-pinned policy
invariant** and **friction/bypass telemetry** constitution items).

1. **Evidence rule:** anything feeding trust, promotion, or a gate is computed from git/CI/hooks
   against protected refs the agents cannot move. Agent-asserted content (Jira comments, reports,
   self-assessments) is context for the owner — NEVER a gate input.
2. **Default-deny permission model** (permission-matrix pattern) + agent least-privilege.
3. **Security baseline** (no plaintext creds; server-side authz; invariant negative tests;
   built≠wired live-path proof; money = integer minor units where applicable).
4. **Escalate-NOW class:** suspected secret · scanner-finding suppression (agents may never waive
   gitleaks/SCA) · security-invariant test modified/deleted · CI/hook/gate-definition changes ·
   critical-CVE/slopsquat dependency · ⛔-zone or criteria-meaning questions · plan-invalidating
   scope change. These interrupt the owner immediately, never wait for the async cadence.
5. **Continuity is FILES, not sessions** (in GDF: Jira ticket + linked PR + `TASKSTATE/` file —
   a fresh agent must resume from artifacts alone).
6. **EXPERIENCE → register → council** improvement loop (GP machinery, shared).
7. **⛔ zones** defined by path/glob patterns, never agent self-classification:
   auth, payments, crypto, personal data, prod infra, migrations + GDF adds: the control plane
   itself (CODEOWNERS, branch protection, `.github/workflows/**`, freeze toggles, agent-label allowlist).

## 2. Override appendix (the complete list of GDF deviations from GP)

**OVR-1 — Agents perform git operations, including merges** (owner directive OD-5; ADR GDF-001).
Bounded by: protected branches (no force-push, no deletion, enforce_admins ON, squash/linear
history, merge only via the gated PR path), required status checks (CI + QG + bench-seat checks +
commit-trailer lint + criteria-hash check), diff-size cap, and the tripwire set (§3).
**The GP bright line is consciously crossed here and recorded as such in GDF-001.**

**OVR-2 — Owner review is asynchronous**, made real (not theater) by:
- **Backpressure cap:** max **5 unreviewed merges**, or **1 unreviewed HIGH-tier merge** → further
  merges pause; PRs queue (work continues on branches; throughput degrades gracefully).
- **Owner-silence rule:** 3 days without review activity → all merges auto-pause.
- **Daily risk-ranked digest** (script-generated from JQL/CI/merge SHAs — see gdf-design §PM honesty).
- **Auto-revert window:** an owner flag on any merge within the review window triggers revert/freeze
  without negotiation; agents build atop unreviewed merges at their own risk.
- **Weekly sampled adversarial sweep** (unpredictable sampling; built≠wired + scope-vs-Jira checks).

**OVR-3 — The sync exceptions (even in GDF, these BLOCK on the owner):**
- Any PR touching a **⛔ glob** → owner is a required reviewer (CODEOWNERS), merge blocks until
  his approval. Async does not apply to ⛔.
- **Migrations:** never auto-merged; serialized (never two in flight); forward-only with a
  CI-tested rollback path; expand/contract pattern for live columns; owner required reviewer on
  `/migrations/**`.
- **Production deploys:** only via tag + GitHub *environment protection* with the owner as
  required reviewer — this is the async-review moment with teeth.

**OVR-4 — Spec model:** no frozen PRD. Per-TASK acceptance criteria (Given/When/Then) written at
Jira-task creation, **hash-frozen at task level**; the PR must reference the exact criteria hash
(CI-verified). Criteria evolve by closing a task and opening a successor (lineage-linked,
`superseded-by`) — never by editing an in-flight task; in-flight edits are escalate-class.
Task churn tripwire: a requirement re-opened/replaced more than twice → owner review.

## 3. Tripwires — auto-freeze of ALL agent merge rights (mechanical; owner-only unfreeze)

1. Verified secret in a merged commit (post-merge gitleaks hit) → freeze + rotation runbook.
2. Any ⛔-glob change reaching a protected branch without the required owner approval.
3. High/critical security finding in a deployed artifact.
4. ≥2 agent-merged PRs reverted within 24h, or CI red on the trunk >1h.
5. Anomalous agent behavior: push outside the PR path, commit without valid trailers,
   auth failures on agent credentials, attempted control-plane modification.

Freeze = branch protection flips to require-human-review-on-everything via a toggle agents cannot
operate. **Only the owner unfreezes**, with a written cause+fix note in the incident issue.
Agents may keep opening PRs while frozen — work queues, it doesn't stop.

## 4. Provisional status & graduation

- GDF v1.1 is **PROVISIONAL**: after 3 projects or 60 days of field use → mandatory retrospective
  (GP retro format: verdict buckets + retired count) before re-charter.
- **Project graduation rule:** external users, production-revenue dependency, or a ⛔-critical core
  appearing in a GDF project → merges freeze → project migrates to GP governance. Silently
  continuing past a disqualifier is a named constitutional violation.
