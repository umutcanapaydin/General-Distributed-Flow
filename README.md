# GDF — General Distributed Flow

> **Status: v1.1 DRAFT — PROVISIONAL charter** (expires after 3 projects or 60 days of field use,
> whichever first → mandatory retrospective before re-charter). Chartered by owner directive OD-5
> (2026-07-17), shaped by a 7-seat technical design council; **v1.1 (2026-07-30): market-informed
> hardening, 6-seat GDF council — 8 adopts** (server-side AC invariants · dual evidence · bench
> input scoping · recorded overrides + control telemetry · stale-approval dismissal · FIFO merge
> serialization · deploy checks by GP-v4.0 reference · bench SLA fail-closed). Decision records:
> `decisions.md` GDF-001 (charter) · GDF-007 (GP v4.0 constitution adoptions) · GDF-008 (v1.1).
> **Still UNPILOTED — the first pilot is the next evidence generator; pre-pilot rule additions are
> frozen (Skeptic ceiling, GDF-008).**

## What GDF is

A **delegated-lane** delivery flow for AI agents: a PM-role agent orchestrates work through Jira;
builder agents claim tasks, write code, open PRs; a **risk-tiered technical review bench** gates
every PR; **agents perform git operations including merges** behind mechanical gates (protected
branches, CI, required bench checks); the human owner reviews **commits + Jira asynchronously**,
protected by backpressure caps, tripwires, and an auto-revert window.

GDF is the sibling of **General Pipeline (GP)** — one constitution, two flows:

| | **GP (General Flow)** | **GDF (Distributed Flow)** |
|---|---|---|
| Human | in the loop — reviews every milestone, makes every commit | async — reviews commits + Jira on his own cadence |
| Git | owner-only | agents commit, open PRs, **merge** (gated) |
| Spec | PRD + hash-frozen milestone plans | rolling backlog; per-TASK acceptance criteria, hash-frozen at Jira level |
| Use when | PRD/features are clear; production-critical; ⛔ surfaces | **PRD NOT yet clear; speed matters; non-production-critical projects** |
| Versioning | v4.0 (own lineage) | v1.1 (own lineage, independent) |

## Eligibility (hard rule — see GDF-CHARTER template)

GDF projects must have: **no external users, no production-revenue dependency, no ⛔-critical
surface as the core product.** The moment a disqualifier becomes true, merges freeze and the
project **graduates to GP governance**. Fast lane ≠ back door.

## Read order

1. `GDF-CONSTITUTION.md` — inherited GP constitution (referenced, pinned) + the explicit overrides
2. `gdf-design.md` — the flow: stages, Jira conventions, coordination mechanics
3. `pr-bench.md` — the tiered review bench that gates every PR
4. `permission-matrix.md` — who may do what in git; credentials custody; always-blocking ops
5. `agents/` — PM, Builder, and bench-seat profiles
6. `decisions.md` — GDF ADRs (GDF-001 names, in plain text, what this flow overrides and why)
7. `templates/` — per-project charter, task format, **`gdf-config.template.yaml` (mandatory intake)**
8. `docs/toolchain-profile-reference.md` — the reference CI/QG/artifact/deploy stack + gotcha pack
9. `gdf-schema.html` — the whole flow on one page (open in a browser)

## Intake gate (GDF-006 — executable, not documentary)

Every GDF project starts by filling `gdf-config.yaml` (from the template): tracker, git host,
quality gate, artifact store, deploy target, scans, ⛔ globs, limits. **`scripts/gdf-check.sh`
must PASS before any task, branch, or PR exists** — it verifies all fields are filled, no secret
values leaked into the config, the charter is signed, branch protection is confirmed, and the
known toolchain gotchas (e.g. SonarCloud automatic analysis) are handled.

## Improvement loop

GDF uses **GP's EXPERIENCE → register → council machinery** (no parallel ecosystem): each GDF
project keeps a living EXPERIENCE.md (template: GP `docs/EXPERIENCE.template.md`); harvests feed
GP's candidate register; shared-constitution changes go through GP's council; GDF-only changes
through a GDF council recorded in `decisions.md`.
