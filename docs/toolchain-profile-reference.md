# GDF Toolchain Profile — Reference Stack (swappable; GDF law references only the INTERFACES)

> Core GDF requires interfaces, not vendors: "a quality-gate status check exists" · "a versioned
> artifact store with immutable promote" · "a deploy/rollback workflow taking an artifact-version
> input" · "a task tracker with labels, transitions, comments, custom fields." This file is the
> reference implementation (SonarCloud + JFrog + GitHub Actions + Jira + target host) and its
> field-learned gotchas — harvested from the SDLC pipeline experience (GP register, Increment 7).

## Reference stages (CI on trunk push)
build (fail fast, cached) → sonar-scan (tests+coverage) → **QG check (BLOCKS: coverage ≥80%,
duplication ≤3%, ratings A)** → deploy-to-artifactory (Docker) → verify-artifact (manifest 200).
Production: tag + environment protection (owner reviewer) → CI deploy → health check → CI rollback
on failure.

## Gotcha pack (16 — verified integration facts; check BEFORE debugging)

1. **SonarCloud Automatic Analysis MUST be OFF** before any CI scan (else the workflow crashes). Project-admin permission required.
2. Jira direct REST on `{site}.atlassian.net` returns 401 — use the gateway: `api.atlassian.com/ex/jira/{cloudUuid}/rest/...`.
3. Jira sprint names ≤30 chars (400 above).
4. Jira sprint field `customfield_10020` = number, NOT array.
5. Jira sprint close: `PUT /sprint/{id}` needs the FULL object (GET first; no partial update).
6. JFrog Docker repo names: hyphens, never underscores (DNS).
7. JFrog build API needs `?project={key}` (404 without).
8. Jira "In Testing"-style custom statuses must be created manually (workflow editor) before transitions use them.
9. GitHub MCP lacks workflow dispatch — REST with a scoped PAT: `POST .../actions/workflows/<file>/dispatches`.
10. Splitting npm install and build into separate Actions jobs breaks `.bin` symlinks — same job.
11. SonarCloud token ≠ GitHub PAT (generate at sonarcloud.io/account/security).
12. Semgrep MCP may time out sandboxed — CLI fallback `semgrep ci`.
13. Nginx SPA `try_files ... /index.html` always 200s — handle 404 client-side.
14. Angular 15+: `npx ng build --configuration=production` (not `--prod`).
15. Windows PowerShell 5.1: no `&&` — use `;`.
16. GitHub↔Jira / ↔SonarCloud / ↔Semgrep links are manual UI setup — do them at intake, not mid-run.

## Runtime notes
Node 22 LTS in CI · `sonarcloud-github-action@master` (NOT `sonarqube-scan-action` — Docker/Node18
issue) · caching: pip, node_modules, Docker layers.
