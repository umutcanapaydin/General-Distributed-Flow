# GDF Jira Task Template (AC hash-frozen at creation — OVR-4)

**Title:** `<KEY> — <imperative, one line>`
**Labels:** `gdf-approved` (owner-provenance checked) + routing (`agent:backend|frontend`) + domain

## Description body

```
INTENT: <why this task exists, 1-2 sentences — may reference fuzzy discovery notes>

ACCEPTANCE CRITERIA (Given/When/Then — testable; hash-frozen at creation):
AC-1: Given <...> When <...> Then <...>
AC-2: ...

AC-HASH: <sha256 of the AC block — the PR description must reference this exact hash>
LINEAGE: <supersedes: KEY-n | none>   (criteria evolve by successor tasks, never in-flight edits)
OUT OF SCOPE: <explicitly>
⛔-ADJACENT: <yes/no — if yes, owner required review is automatic>
```

## PR closure requirement (v1.1, GDF11-02 — dual evidence)

The closing PR's description MUST carry the builder's **per-AC self-check evidence**, keyed to the
AC-HASH above (`AC-1: <test ref / command output ref>` …). The bench marks each AC
verified/failed **independently** in its verdict — the two artifacts are never merged, and the
builder's self-check is **excluded from bench-seat inputs** (bench input scoping, GDF11-03).

## Rules
- In-flight AC edits are escalate-class (blocked; open a successor task instead).
- A task superseded more than twice → owner review (churn tripwire).
- `Done` is reachable only via the transition that records the merge SHA.
- Close-out comment must state: done / NOT done / evidence referents (test run, PR, commit).
