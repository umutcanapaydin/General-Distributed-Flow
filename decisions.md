---
record_type: design
id: gdf-decisions
status: ratified
process_version: v1.2
---
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

> **Reading note added at v1.2 (GDF-012), because the chair had been mis-citing this.** Dissent 2 is
> **one seat's declared future voting posture**, not a ratified council-wide freeze with its own id.
> It has repeatedly been summarised as "GDF-008 froze pre-pilot rule additions." It did not. The
> practical effect is the same and the seat's position is sound — but the citation must be accurate.
> Flagged independently by the Software, Quality and Skeptic seats at GP Increment 12.

**Standing concerns logged:** the digest must stay scannable (SRE — it now carries overrides,
waived, stale-reclaims, throwbacks, state-diverged, timeouts); an unread digest reduces the
telemetry layer to theater (Quality); pilot must measure dual-evidence catch-rate vs cost before
any further hardening.

---

## GDF-009 — The Jira "atomic claim" was false; claim discipline corrected (v1.1 defect fix)

**Status:** ACTIVE (2026-07-30; GP Increment 11, architecture research + chair verification)

**Defect:** `gdf-design.md` §4 and `agents/builder-agent.md` instructed builders that "the
transition is the lock" and to "claim atomically … in ONE call". **Jira provides no such
atomicity.** Chair fetched the primary source on 2026-07-30: `JRASERVER-26005` — *"As a program, I
can opt into some form of optimistic locking when updating an issue via REST"* — is **CLOSED,
resolution "Won't Do", resolved 2015-06-25**; the sibling Cloud ticket `JRACLOUD-26005` is also
closed. The documented update idiom is GET→modify→PUT with no `If-Match`/version precondition.
Consequence: two builders can both read "unassigned", both write their assignment, last write wins
**silently** — duplicated spend and conflicting PRs, intermittent, the profile that hides for
months. Found by architecture research (AI1 Card 3.9, which flagged itself as the report's weakest
claim and asked for re-verification); **not** caught by the GDF design council, the market round, or
the v1.1 council.

**Decision:**
1. The false claim is **struck from both files**. The mandatory read-back stays and is named as
   what it is: a race-window narrower, not a lock. "If the read-back shows another assignee, STOP —
   do not win the race."
2. **Interim operating rule until the lease pilot passes: ONE builder per domain.** A claims-related
   `state-diverged` flag is an escalate-NOW event.
3. **Git-ref claim lease = PILOT (NOVEL, unvalidated).** `git push origin HEAD:refs/claims/<TICKET>`
   is a genuine server-side compare-and-swap. Before it may be relied on: a two-racer test on the
   real host · confirmation the host permits `refs/claims/*` and forbids force-push/delete there ·
   `lease_expires_at` + a CI-only sweeper · `attempt_count` escalation.

**Also repaired in the same change (Increment 11 Phase 0):** `scripts/gdf-check.sh` step 8
**failed open** — `enabled: True` (capital T), `TRUE` or `yes` did not match the lowercase-only
pattern, so the script printed "deploy disabled" and **skipped the owner-required-reviewer
assertion (GDF-003, a declared non-negotiable)**. Now case-insensitive, value-parsed, and
**fail-closed on anything unrecognised**; the dead `grep -qA3 … | grep -q …` line is gone.
Regression-tested across `True|true|TRUE|yes|false|maybe`.

**Rationale for the record:** both defects were live in an UNPILOTED flow — found by audit, not by
production. This is the strongest available argument for the Increment-11 doctrine: *a declared
control that silently passes is worse than an absent one.*

---

## GDF-010 — Step 3 of the intake gate was FAIL-OPEN on the first-named non-negotiable (2026-08-05)

**Found by:** the **Security seat** of GP's Increment-12 scoped council, which was asked to hunt for
"the same fail-open shape in the OTHER steps" after step 8 was repaired at v1.1. It found one, and
reproduced it.

**The defect.** `scripts/gdf-check.sh` step 3 enforces the constitution's first-named
non-negotiable — *NO secret VALUES in this config, names only.* The detector piped its matches
through `grep -vi 'required\|_name\|<FILL'`, and that exclusion matched **the whole line**. So one
innocuous word in a trailing comment laundered a live credential:

```
api_key: "AKIAIOSFODNN7EXAMPLE"  # required for staging deploy      →  NOT FLAGGED
```

`templates/gdf-config.template.yaml` told operators *"gdf-check greps this file for secret patterns
and FAILS on hit."* That claim was false under an entirely ordinary input.

**It was worse than reported.** Verifying the seat's finding, the chair found the pattern list never
covered `access_key`, `private_key` or `credential` **at all** — so `deploy_access_key = AKIA…` was
missed by a second, independent route. Two misses, not one.

**Repair.** Match on the **VALUE**, exclude on the **KEY**. Comment text can no longer influence the
verdict. Placeholders (`<FILL`, `${…}`, `changeme`) and name-suffixed keys (`*_name`, `*_ref`,
`*_env`, `*_var`, `*_id`) stay legitimately exempt, because naming a secret is the entire purpose of
the file. Private-key detection widened to DSA and PGP.

**Class.** Identical to GDF-009: *an unanticipated input silently treated as benign.* Two of eight
steps of this gate have now been found fail-open by seats reading the code. Neither was found by its
author. This is GP's Cluster A (`council-telemetry.md` §6.1) arriving in GDF from a third dataset.

## GDF-011 — The intake gate gets a regression harness that runs the REAL gate (2026-08-05)

**Condition set by the Security seat** (*"a committed conformance fixture directory for GDF before
GDF's first pilot begins"*) and independently by the **PM seat** (*"a conformance/negative-fixture set
+ self-test for GDF's new checks, mirroring V4C-32, before GDF-side CI is declared trustworthy"*).
**Closed at this cut rather than at pilot start.**

`scripts/gdf-selftest.sh` + `conformance/secret-values/` + `conformance/non-negotiables/`.

Governing rule, GP **V4C-50**: *a suite that bypasses the layer where the bug lives is correctly
green and completely uninformative.* So the harness invokes **`gdf-check.sh` itself** against each
fixture and asserts on that step's own verdict line. It does not re-implement a single pattern — a
re-implementation would certify the copy and not the control.

Five fixtures, each declaring its expectation on its first line:

| Fixture | Asserts |
|---|---|
| `secret-values/laundered-by-comment.yaml` | step 3 **FLAGS** the GDF-010 defect input |
| `secret-values/uncovered-key-pattern.yaml` | step 3 **FLAGS** `access_key`, the second miss |
| `secret-values/clean-names-only.yaml` | step 3 stays **CLEAN** on names, `${env}`, `<FILL>` and prose mentioning `api_key` — a gate that cries wolf gets bypassed |
| `non-negotiables/deploy-enabled-capital-true.yaml` | step 8 **FLAGS** the GDF-009 defect input |
| `non-negotiables/deploy-enabled-garbage.yaml` | step 8 **FAILS CLOSED** on an unrecognised boolean |

**Falsification run, and this is the part that matters:** with step 3 reverted to its v1.1 form the
harness **exits 1 and names both missed inputs**. With the repair in place it exits 0. The harness is
not a no-op, and that was demonstrated rather than asserted — which is the specific failure
(`council-telemetry.md` TB-008) this council caught the chair committing on the same day.

## GDF-012 — v1.2: enforcement installed, ZERO rules added (2026-08-05)

**Owner directive OD-8** (recorded verbatim in GP `v4-candidate-register.md` §12.5): cut a new GDF
version now, carrying current rules and repairs, before the next project starts. Version label
corrected by the chair from the owner's casual `1.2.1` to **v1.2** — under GP V4C-11's semver
semantics a PATCH cannot precede the MINOR it patches. Council concurred 6/6.

**The freeze is respected, and the freeze is also described more accurately than before.** Three
seats (Software, Quality, Skeptic) flagged that the chair had been characterising GDF-008 as *"a
ratified freeze on pre-pilot rule additions."* It is not. What the tree actually contains is a
**Skeptic dissent stating future voting intent** — *"if the pilot has not started by the next
council, this seat moves to REJECT-by-default on all further pre-pilot candidates"* — which is one
seat's declared posture, not a council-wide rule with an id. **Corrected here so the compression does
not become a citation error two cuts from now.** The practical effect is the same: no rules were
added at v1.2, and none should be.

**What v1.2 installs — all of it enforcement for already-ratified rules:**

| Artifact | Closes |
|---|---|
| `.github/workflows/governance-contract.yml` | GDF had **no `.github` directory at all**. OVR-1 grants agents merge authority "bounded by required status checks" that did not exist. Six unconditional steps. |
| `.github/CODEOWNERS` | the paths that bound agent authority must not be agent-editable |
| `scripts/check_records.py` + `schemas/record.schema.json` | byte-identical to GP's live copy, run against GDF's own record set via `.governed-records` — **not a fork**, because a near-copy drifts |
| `.governed-records` | the manifest that makes the unforked copy possible |
| frontmatter on `decisions.md`, `GDF-CONSTITUTION.md`, `gdf-design.md`, `permission-matrix.md`, `pr-bench.md` | the Skeptic predicted this retrofit would be required; it was, and it is done |
| `scripts/gdf-selftest.sh` + `conformance/` | GDF-011 |
| step 3 repair | GDF-010 |

**Still UNPILOTED, and v1.2 changes nothing about that.** The open conditions all need a pilot to
close: the Jira invariant config evidence, branch-protection evidence, the **V4C-10 injection-defense
exercise** (a blocking precondition for scale-out), the **V4C-48 git-ref claim-lease two-racer test**,
and credential enforcement at pilot exit. **The next GDF version number should be earned by pilot
evidence, not by more rules.**

**Owner action still required, outside the repo — until it is done the gate is Tier 2, advisory:**
make `governance-contract` a required status check on the protected branch, bind it to the app,
disable bypass, and CODEOWNER-protect `.github/`.

## GDF-013 — One detector, because two copies of a security check is one too many (2026-08-05)

**Found by:** the **Skeptic seat** on re-poll, hours after GDF-010 was recorded. Verbatim:

> *"the newest security surface — GDF's first CI file — reintroduces the exact comment-laundering
> shape of GDF-010 in a different location in the same cut."*

It constructed `prod_api_key: "F1XTURE0DEMO0VALUE0NOTREAL1234"  # env_name reference` and the new CI
step passed it silently, because that step had its own inline `grep -vE '…_name…'` excluding on the
**whole line** — the identical defect GDF-010 had just fixed thirty lines away in another file.

**Plus two live bypasses in the repaired step 3 itself, both constructed by the same seat:**

1. **Placeholder-prefix laundering** — the placeholder exemption was anchored at the *start* of the
   value, so `some_api_key: "changeme_F1XTURE0DEMO0NOTREAL0VALUE"` passed clean. A placeholder must
   be the **whole** value.
2. **Untracked key names** — `webhook_signing_key` and `bearer` were not in the allowlist. Any key
   ending in `key` now counts, plus `bearer`, `signing_key`, `encryption_key`, `auth`.

**Repair:** `scripts/scan-secret-values.sh` — **one** implementation, sourced by `gdf-check.sh`
step 3 **and** the CI step. Two more fixtures (`placeholder-prefix-laundering.yaml`,
`untracked-key-names.yaml`), seven total.

**Two further bugs surfaced while fixing this, both caught by running the harness rather than reading
the code** — which is the whole argument for GDF-011 existing:

- The narrowed detector exempted bare `SCREAMING_SNAKE` values as CI-secret names — and an AWS key
  is *also* uppercase alphanumeric, so `AKIAIOSFODNN7EXAMPLE` became exempt and **silently un-fixed
  both GDF-010 fixtures**. A secret *name* has an underscore; a raw credential does not.
- The comment-strip guard *"skip the strip if the value is an open quoted string"* matched **any**
  quoted value followed by a comment, so the comment survived into the value and the line was then
  discarded as prose. Latent behind the old code path; exposed the moment a prose filter was added.

**The claim, stated precisely, because the seat insisted on the distinction and it is right:**
this is a **config-hygiene heuristic**, not a secret scanner. `gitleaks` is the secret scanner and it
is a non-negotiable. **"Zero false positives" is not "cannot be bypassed."** A complete detector is
**refused by decision** — a second half-good scanner invites trusting the wrong one.

**Falsification run:** reverting `scan-secret-values.sh` to its v1.1 form makes the harness exit 1 and
name three failing fixtures. The harness is not a no-op, demonstrated rather than asserted.

## GDF-014 — A security fixture must never be shaped like a real credential (2026-08-05)

**Found by:** **GitHub push protection**, which rejected the entire v1.2 push. Not a council, not a
reviewer — a machine at the far end of the pipe, after everything local was green.

```
remote: - GITHUB PUSH PROTECTION
remote:     —— Slack API Token ——
remote:        - .secret-scan-allow:16
remote:        - conformance/secret-values/untracked-key-names.yaml:70
remote: ! [remote rejected] main -> main (push declined due to repository rule violations)
```

**What happened.** The GDF-013 fixtures used realistic provider signatures — `xoxb-…`, `whsec_…`,
`AKIA…` — on the reasoning that a realistic value is a better test. Every local check passed: the
harness, the shared detector, both simulated CI runs. Then the remote refused the push.

**GitHub was right, and the reason matters more than the inconvenience.** A fixture shaped like a
live credential trips every downstream scanner — GitHub's, `gitleaks`, the vendor's own revocation
bots. The only way to ship it is to click *"allow this secret."* **That habit is precisely what leaks
the real ones.** The rule now:

> **A security fixture must be long, high-entropy and UNMISTAKABLY FAKE.** Detection in
> `scan-secret-values.sh` depends on the **key name, the value length and the value shape** — never
> on a provider prefix. Nothing is lost by removing the signature, and a whole class of downstream
> false alarms goes with it. Fixtures carry an `F1XTURE`/`f1xture` marker.

All five secret-value fixtures were rewritten; the harness still catches all of them and still fails
when the detector is reverted. The one provider-shaped literal remaining in this repo is
`AKIAIOSFODNN7EXAMPLE` — the AWS-published documentation key, which every scanner already recognises
as a sample, quoted in GDF-010 as the exact input that was laundered.

**Where this belongs in the pattern.** `council-telemetry.md` Cluster A is *a control ratified
without a fixture proving it fires.* GDF-014 is its neighbour: **a fixture written without asking
what else reads it.** Both are the same root — the author reasons about their own artifact and not
about the system it lands in. That is F45's claim (*a lesson does not transfer between artifacts by
itself*) and V4C-49's remedy, arriving for the fourth time in one day, from the fourth independent
observer, this one not even human.

**`found_by` for the record: an external machine, after six seats, one re-poll and a zero-context
human reviewer had all signed off.**

## GDF-015 — The detector crashed on macOS and reported clean (2026-08-05)

**Found by:** the **owner**, running `gdf-selftest.sh` on his own Mac for the first time. Everything
had passed in the Linux sandbox and would have passed on GitHub's Ubuntu runners.

```
does the password-catcher still fire?    FAIL
      awk: newline in string AKIAIOSFODNN7EXAMPLE... at source line 1
        ✅ no secret values detected
```

**The defect.** `scan-secret-values.sh` passed the allowlist to awk as a **multi-line `-v` variable**.
GNU awk accepts that. **BSD awk — which is what macOS ships — rejects it.** So on the owner's machine
the detector died on startup, printed nothing, and `gdf-check.sh` read an empty result as *"no secret
values detected."*

**A fail-open that existed only on the platform never tested.** Linux: fine. CI: fine. The one machine
that actually matters: silently blind. This is V4C-50's rule (*test through the real entry point*) with
a second edge nobody had named — **the real entry point includes the real operating system.**

**A second, self-inflicted defect found while fixing the first.** The scanner carried
`trap '…exit 2' ERR`, added hours earlier to fail closed on a crash. But awk exits **1** on purpose
when it finds hits — a non-zero return — so the trap fired on every real detection and converted it
into a fake `INTERNAL ERROR`. **A blanket ERR trap cannot distinguish an expected non-zero from a
crash.** Removed; the explicit `case $?` (0 clean · 1 hits · anything else → exit 2) does the job
precisely, and that is now stated in the file.

**Repairs**

| | |
|---|---|
| awk reads the allowlist **from the file** via `getline`; no multi-line value crosses the boundary | portable to BSD, GNU, mawk and busybox awk |
| `case $?` replaces the ERR trap | a crash is rc=2 and fails closed; a hit is rc=1 and is reported |
| **PREFLIGHT in `gdf-selftest.sh`** | *"can the detector run on this machine at all?"* is now its own loud first check. It plants an obvious secret, requires rc=1, and on failure prints the awk dialect and says **PLATFORM failure, not fixture failure** |

**Verified across three awk dialects** (GNU 5.1, mawk, busybox), 8 checks each, plus: planted secret →
rc=1; clean file → rc=0; awk made unavailable → **rc=2, fails closed**.

**BSD awk verified on the owner's Mac, 2026-08-05** — the harness went from `FAIL` to `PASS` with all
8 checks green on the machine that produced the defect, including the deliberate-sabotage leg. That
closes the only dialect no CI runner and no sandbox can reach.

**Why the preflight matters more than the fix.** The symptom the owner saw was *"a fixture didn't
fire"*, which points at the fixture. The cause was *"the tool cannot start here"*. Three minutes were
spent looking in the wrong place. A control that fails for an environmental reason must say so in the
environmental language, not in the language of the thing it was testing.
