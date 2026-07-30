# GDF Project Charter — `<PROJECT_NAME>`

> Copy to the project repo root as `GDF-CHARTER.md` at intake. The bench checks this file at PR
> time; a false declaration or a silently-continued disqualifier is a constitutional violation.

## Eligibility declaration (all must be TRUE to run under GDF)

- [ ] No external users (internal/experimental only)
- [ ] No production-revenue dependency
- [ ] The core product is NOT a ⛔-critical surface (auth/payments/crypto/PII/prod-infra as the product)
- [ ] Owner has signed this charter: `<initials/date>`

## Graduation tripwire (mechanical)

The moment ANY of the following becomes true, merges FREEZE and the project migrates to GP
governance: external users appear · production revenue depends on it · a ⛔-critical surface
becomes the core · the owner says so.

## Project facts

- Intent (1–3 sentences, allowed to be fuzzy — that's why we're in GDF): `<...>`
- Jira project key: `<KEY>` · Repo: `<url>` · Toolchain profile: `<reference|custom>`
- ⛔ globs for this repo (extends the constitution defaults): `<paths>`
- Data stores + canonical schema file locations: `<...>`
- Mode: **GDF v1.1 (PROVISIONAL)** · Charter date: `<date>`
