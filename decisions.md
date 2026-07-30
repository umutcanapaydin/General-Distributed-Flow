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

---

## GDF-007 — v4.0 constitution adoption: base-pinned policy, credential identity v1, tested injection defense

**Status:** ACTIVE (2026-07-30; GP v4.0 council, `General_Pipeline/v4.0-ratification.md`)

**Decision:** three GP v4.0 adoptions bind GDF:
1. **Base-pinned policy invariant (V4C-06):** any policy/instruction consumed by a bench seat,
   gate, or agent is read from the protected base ref — never from the PR/comment/task under
   evaluation. (Already GDF practice via owner-provenance labels; now a named constitution
   invariant. Market grounding: comment-driven credential theft, head-branch review-policy
   override, one-PR→RCE on a review bot — all 2026.)
2. **Credential identity v1 (V4C-05):** `permission-matrix.md` §3 records, per credential NAME:
   the holding identity, its scope, and its expiry. ENFORCEMENT (short-lived scoped tokens,
   intersection principle, expiry alerting) is a pilot-exit condition, owner: GDF lead.
3. **Injection defense becomes a TESTED control (V4C-10):** the first GDF pilot includes an
   adversarial exercise — planted malicious comment/task/PR content (Comment-and-Control class)
   must NOT move an agent; fixture + result recorded. **Blocking precondition for any GDF
   scale-out.** Until it passes, GDF's injection-defense claim stays PARTIAL, honestly.

**Note:** GDF-CONSTITUTION's GP pin moves to **GP v4.0** at the next charter signing; existing
pins stay until then (pinned means pinned).

---

## GDF-008 — v1.1: market-informed hardening (8 adopts, budget ceiling)

**Status:** ACTIVE (2026-07-30; 6-seat blind GDF council: Software, Quality/Test, Security,
DevOps, SRE, Skeptic; chair-tallied; MINOR bump 6/6 CONCUR)

**Adopted (GDF11 series):**
1. **GDF11-01 (AWC, guardrail)** — server-side AC invariants: Jira required-fields/automation
   rejects empty Given/When/Then at creation; assignee-only key transitions; `gdf-config.yaml`
   gains `tracker_invariants_configured` flags; `gdf-check` WARNS (not fails) if unconfirmed.
   *Condition: owner confirms the Jira config before pilot start; closure artifact = config
   evidence (the flag is self-attested — the artifact is the real control, DevOps).*
2. **GDF11-02 (template)** — dual evidence: builder attaches per-AC self-check evidence in the PR
   (AC-hash keyed); the bench marks each AC verified/failed INDEPENDENTLY — two artifacts, never
   merged. *Interaction rule (Software): builder self-check evidence is EXCLUDED from bench-seat
   inputs, or GDF11-03 silently breaks.*
3. **GDF11-03 (guardrail, 6/6)** — bench input scoping: each ephemeral seat receives ONLY the task
   spec (AC+hash), the diff, and CI results — never the builder's reasoning or comment thread.
   Doubles as injection-surface reduction (compensating control while GDF-007's injection test
   awaits the pilot — Security).
4. **GDF11-05+06 MERGED (guardrail)** — recorded override governance + control telemetry: a bench
   BLOCKING is overridable ONLY by the owner, with a written reason on the PR; the daily digest
   carries a mechanical line — overrides, waived checks, stale-reclaims, throwback counts; the
   SAME control overridden/bypassed 3× → review the CONTROL, not the people.
5. **GDF11-07 NARROWED (AWC, guardrail)** — the one mechanical rule only: **stale approvals are
   dismissed on new commits and the bench re-triggers on push** — branch-protection CONFIG, not
   prose (stale-approval-riding-new-commits is a live 2026 exploit class — Security). The full
   PR-state taxonomy stays deferred (trigger: first pilot PR hits an unmapped state).
   *Condition: config artifact before pilot.*
6. **GDF11-08 (doc)** — merge serialization: >1 ready PR merges FIFO; CI re-runs on the exact
   merged SHA after any rebase; GitHub native merge queue where available, with the stated
   fallback (require-branches-up-to-date + serialized auto-merge) on plans without it.
7. **GDF11-09 (doc)** — deploy/verify inherits GP v4.0's scheduled-journey monitoring (V4C-07) and
   stack-conditional canary/rehearsed-rollback (V4C-08) BY REFERENCE to the pinned constitution —
   never copied text.
8. **GDF11-10 (AWC, guardrail, 6/6)** — bench SLA + fail-closed timeout: timebox per tier; a seat
   that hasn't returned escalates to the owner as ONE deduped, machine-readable event; silence
   never unblocks anything. *Conditions: provisional SLA set at pilot kickoff; timeout path
   DRILLED in the pilot; recalibration at pilot retro (SRE/Skeptic).*

**Deferred with triggers:** GDF11-04 cross-model bench routing → first HIGH-tier pilot task ·
GDF11-07 full state taxonomy → first unmapped PR state.

**Skeptic dissents (verbatim):**
1. "GDF11-01 was re-tabled from a GP deferral with no new evidence. Re-tabling on owner
   preference alone is fashion; the deferral trigger was never met. Recorded so the pattern is
   countable if repeated."
2. "Seven adopts into a machine that has never run is my ceiling, not my comfort. If the pilot
   has not started by the next council, this seat moves to REJECT-by-default on all further
   pre-pilot candidates."

**Standing concerns logged:** the digest must stay scannable (SRE — it now carries overrides,
waived, stale-reclaims, throwbacks, state-diverged, timeouts); an unread digest reduces the
telemetry layer to theater (Quality); pilot must measure dual-evidence catch-rate vs cost before
any further hardening.
