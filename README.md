# GDF — General Distributed Flow

> **Status: v1.0 DRAFT — PROVISIONAL charter** (expires after 3 projects or 60 days of field use,
> whichever first → mandatory retrospective before re-charter). Chartered by owner directive OD-5
> (2026-07-17), shaped by a 7-seat technical design council. Decision record: `decisions.md` GDF-001.

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
| Versioning | v3.3 (own lineage) | v1.0 (own lineage, independent) |

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
7. `templates/` — per-project charter, task format
8. `docs/toolchain-profile-reference.md` — the reference CI/QG/artifact/deploy stack + gotcha pack

## Improvement loop

GDF uses **GP's EXPERIENCE → register → council machinery** (no parallel ecosystem): each GDF
project keeps a living EXPERIENCE.md (template: GP `docs/EXPERIENCE.template.md`); harvests feed
GP's candidate register; shared-constitution changes go through GP's council; GDF-only changes
through a GDF council recorded in `decisions.md`.
