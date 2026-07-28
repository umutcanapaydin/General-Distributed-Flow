# GDF Decision Log (ADRs — append-only; supersede, never edit)

## GDF-001 — Charter: agents perform git operations including merges (OWNER OVERRIDE, recorded honestly)

**Status:** ACTIVE — PROVISIONAL (2026-07-17; expires per GDF-CONSTITUTION §4)

**Decision:** GDF is chartered as a delegated-lane flow in which agents commit, open PRs, and
**merge to protected branches** behind mechanical gates, with asynchronous owner review.

**The honest record (Skeptic objection #1, accepted by the chair and the owner):** on 2026-07-05
the owner ruled, for General Pipeline, that "we are not ready for agents to handle everything —
maybe around v15," demoting the autonomy ladder to a non-active north star, with the bright line
*"an agent commit reaching main = A1 = explicit owner ADR."* **This ADR is that explicit owner
ADR — for the GDF lane only.** The owner consciously overrides his own bright line here, on these
grounds: (1) different stakes — GDF is restricted to non-production-critical, no-external-user,
non-⛔-core projects (eligibility charter, enforced by graduation tripwire); (2) different goal —
speed on unclear-PRD projects, where synchronous review is the binding constraint; (3) the
override is bounded — PROVISIONAL status, tripwires, backpressure, auto-revert window, sync
exceptions on ⛔/migrations/production-deploys. GP's own ladder remains untouched: GP projects
stay owner-in-the-loop. If GDF's telemetry disproves the premise, the charter dies at its expiry.

**Mitigation if violated:** the tripwire set (constitution §3); any silent scope creep past the
eligibility charter is a named constitutional violation → freeze + graduation to GP.

**Revisit when:** 3 projects or 60 days of field use → mandatory retro (verdict buckets +
retired count) before re-charter.

---

## GDF-002 — Credentials custody: CI-only; agents trigger, never hold

**Status:** ACTIVE (2026-07-17) — precondition: GDF does not run until implemented.

**Decision:** all deployment/registry/SSH credentials live exclusively in CI environment-scoped
secrets; production deploys via tag + environment protection with the owner as required reviewer;
rollback CI-executed; agent workspaces mechanically checked for secret patterns. Replaces the
harvested SDLC design's agent-held `.env` secrets (rejected by the Security seat as disqualifying).

---

## GDF-003 — Sync exceptions: ⛔ paths, migrations, production deploys

**Status:** ACTIVE (2026-07-17)

**Decision:** three classes block on the owner even in the async lane: ⛔-glob PRs (CODEOWNERS
required review), migrations (never auto-merged; serialized; forward-only + tested rollback;
expand/contract), and production deploys (environment protection). Rationale: irreversibility —
async review of an irreversible action is incident response, not review.

---

## GDF-004 — Async review with teeth

**Status:** ACTIVE (2026-07-17)

**Decision:** backpressure cap (5 unreviewed merges / 1 unreviewed HIGH) → merge pause;
3-day owner silence → merge pause; daily script-generated risk-ranked digest; auto-revert window
(owner flag → revert/freeze without negotiation; agents stack on unreviewed merges at own risk);
weekly unpredictable sampled sweep. Rationale (Skeptic objection #2, accepted): without these,
"async review" is an audit log, not review.

---

## GDF-005 — Minimal v1.0 scope (falsifiability)

**Status:** ACTIVE (2026-07-17)

**Decision:** v1.0 ships WITHOUT: the 6-agent standing roster (PM + builders + ephemeral bench
only), the 4-phase spec ceremony (one Discovery/Shaping gate), per-PR full E2E (smoke per PR,
affected-flow on MED/HIGH, full E2E nightly), a copied constitution (reference + one-page override
appendix), and any parallel documentation ecosystem (GP's EXPERIENCE/register/council machinery is
reused). Specialists and ceremony are added only on demonstrated field need, via GDF ADRs.


---

## GDF-006 — Mandatory machine-readable intake config + executable check

**Status:** ACTIVE (2026-07-17; owner directive)

**Decision:** every GDF project begins by filling `gdf-config.yaml` (template in `templates/`):
tracker choice + keys, git host/repo/trunk, quality-gate provider + thresholds (SonarCloud or
CI-native), artifact store (or none), deploy target (or none), optional scans, per-repo ⛔ globs,
and the tunable limits. `scripts/gdf-check.sh` validates it — placeholders, leaked secret values
(names only allowed), signed charter, confirmed branch protection, known gotcha preconditions —
and **must pass before any task, branch, or PR exists.** The PM agent collects the answers from
the owner as questions at kickoff; it never guesses toolchain facts.

**Rationale:** the harvested SDLC design assumed a fixed toolchain; GDF is profile-based, so the
profile must be declared, not inferred — and per F1 doctrine, declared means machine-checked.

**Mitigation if violated:** work products created before a green gdf-check are invalid; tripwire 5
(anomalous behavior) applies.
