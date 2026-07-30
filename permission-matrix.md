# GDF Permission Matrix (default-deny)

## 1. Git operations ownership

| Operation | PM | Builder | Bench seats | CI |
|---|---|---|---|---|
| read repo | ✅ | ✅ | ✅ | ✅ |
| create branch / commit / push (feature branches only) | ❌ | ✅ | ❌ | ✅ (bot commits: version bumps, generated files) |
| open PR | ❌ | ✅ (single owner per PR) | ❌ | ❌ |
| review PR | ❌ | ❌ (never own PR) | ✅ | — |
| **merge PR (gated path only)** | ❌ | ✅ (authoring domain; all required checks green) | ❌ | ❌ |
| push tags (`release-candidate/*`) | ❌ | ❌ | ❌ (DevOps seat may PROPOSE) | ✅ |
| deploy / rollback | ❌ | ❌ | ❌ | ✅ (sole executor) |
| modify control plane (CODEOWNERS, branch/env protection, workflows, freeze toggle, label allowlist) | ❌ | ❌ | ❌ | ❌ — **owner only** |

## 2. Branch protection (required BEFORE any agent merge is enabled)

`main` + trunk: required status checks (strict/up-to-date): build · QG · secret-scan ·
bench-seat checks · commit-trailer lint · AC-hash check · gdf-policy (PR shape: single owner,
Jira key, tier label matches bench) — **no force pushes · no deletions · enforce_admins ON ·
squash-merge only (linear history; one commit = one PR = one task = one agent)** · merge via the
gated API path only · CODEOWNERS: owner-human on control-plane paths AND ⛔ globs.

## 3. Credentials custody (non-negotiable — ships before v1.0 runs)

- **Agents NEVER hold secrets.** No SSH keys, registry passwords, or broad PATs in any agent-readable
  `.env`/workspace. A CI check greps the agent workspace for secret patterns and fails on hit.
- **CI is the only deployer.** All secrets live in GitHub Actions **environment-scoped** secrets
  (`staging`, `production`). Production requires environment protection with the **owner as
  required reviewer**. Rollback is also CI-executed (workflow taking an artifact version input).
- Deploy target hardening (reference profile): dedicated keypair known only to Actions, restricted
  by `authorized_keys` forced-command (deploy script only), rotated on schedule.
- Agent tokens: fine-grained, least-privilege, one **machine account** (`gdf-bot`) whose commits
  carry mandatory trailers — `GDF-Agent: <role-id>` · `GDF-Task: <JIRA-key>` · `GDF-Run: <run-id>` —
  enforced by a commit-lint required check. Per-agent audit = `git log` filtered by trailer.
- The workflow-dispatch token is the soft underbelly: scope to `actions:write` +
  `contents:write` on `release-candidate/*` only; keep it out of agent prompts/logs; rotate; canary.
- **v4.0 — credential identity ledger (V4C-05, GDF-007):** this section maintains a table with
  one row per credential NAME: `name · holding identity (CI env / machine account) · scope ·
  expiry/rotation date`. Recording is v1 and mandatory at intake (gdf-config lists the names);
  ENFORCEMENT — short-lived scoped tokens, intersection principle (agent may do only what BOTH
  the owner and the agent identity may), expiry alerting — is a pilot-exit condition (owner: GDF
  lead). Direction: GitLab-composite-identity / SPIFFE-class infrastructure, not agent-held keys.

  | Credential name | Holding identity | Scope | Expiry / rotation |
  |---|---|---|---|
  | `<NAME>` | `<CI env secret / gdf-bot>` | `<repo/env/action scope>` | `<date · schedule>` |

## 4. Always-blocking (agents may NEVER, even in GDF)

Hold/read/exfiltrate any credential · SSH or interactive shells to any environment · modify the
control plane · force-push/delete protected refs · merge outside the gated path or approve own PR ·
create/rotate credentials or grant permissions · push directly to protected branches · suppress,
skip, or mark-green any required check · deploy by any path other than tag+environment approval ·
operate the freeze toggle · edit an in-flight task's acceptance criteria.
