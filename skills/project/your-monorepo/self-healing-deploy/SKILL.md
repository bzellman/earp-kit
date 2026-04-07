---
name: self-healing-deploy
description: >
  Self-healing merge-to-production pipeline. Use when the user approves a PR for merge,
  says "ship it", "deploy this", "merge and deploy", "take this to prod", or wants to
  promote code through environments. Handles CI monitoring, failure analysis and auto-fix,
  DB migrations, terraform apply, and progressive deployment (dev -> staging -> prod) with
  health verification at each stage. Also triggers for partial invocations like "promote
  to staging", "deploy to prod", "run migrations", or "check deploy status".
---

# Self-Healing Deploy

Orchestrate the entire lifecycle from merge to production: monitor CI, self-heal failures, run DB migrations, apply terraform, and progressively deploy through dev -> staging -> prod.

## How It Works

This skill runs a 7-phase pipeline. Each phase has built-in monitoring and self-healing. The pipeline stops and reports to you if it hits something it can't fix automatically.

```
PR Approved
  |
  v
[Phase 0] Recon — classify what changed (backend? terraform? migrations? iOS?)
  |
  v
[Phase 1] Merge — squash merge, capture SHA, discover triggered workflows
  |
  v
[Phase 2] Self-Heal — if any workflow fails: read logs, classify, fix, re-push, loop
  |
  v
[Phase 3] DB Migrations (dev) — detect new .sql files, run migration workflow
  |
  v
[Phase 4] Terraform Apply (dev) — if terraform changed, explicitly trigger apply
  |
  v
[Phase 5] Dev Verification — health check, config validation
  |
  v
[Phase 6] Staging — migrations -> terraform -> promote -> verify
  |
  v
[Phase 7] Production — migrations -> terraform -> promote -> verify
```

## State Tracking

Maintain a running status table throughout execution. Update and display it at each major milestone:

```markdown
## Deploy Pipeline Status
| Phase | Status | Duration |
|-------|--------|----------|
| Merge | ... | ... |
| CI/Deploy (dev) | ... | ... |
| DB Migrations (dev) | ... | ... |
| Terraform (dev) | ... | ... |
| Dev Health | ... | ... |
| DB Migrations (staging) | ... | ... |
| Staging Promote | ... | ... |
| Staging Health | ... | ... |
| DB Migrations (prod) | ... | ... |
| Prod Promote | ... | ... |
| Prod Health | ... | ... |
```

Use these status values: `Pending`, `In Progress`, `Done`, `Skipped`, `Failed`, `Passed`.
Track wall-clock duration per phase. Record `PIPELINE_START` time at the beginning.

## Global Rules

These apply across all phases:

### Self-Healing Budget
You get **5 fix attempts total** across the entire pipeline. Each time you modify code and push a fix, that's one attempt. Rerunning a transient failure (`gh run rerun`) does NOT count against this budget. If you exhaust all 5 attempts, stop the pipeline and report what you've tried.

### No Auto-Fix in Production
Production failures are always presented to the user with options. Never automatically fix and push code to resolve a prod deployment failure.

### Commit Attribution
All fix commits must include:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```

### 30-Minute Warning
If the pipeline has been running for over 30 minutes, report current status and ask whether to continue.

### Environment URLs
Read environment URLs from `Infrastructure/docs/api-endpoints.json` rather than hardcoding them. This file is auto-updated by CI after each successful deploy.

---

## Phase 0: Pre-Merge Reconnaissance

Goal: Understand what's changing so the pipeline knows which phases to run.

### Identify the PR

If the user provided a PR number, use it. Otherwise, detect from the current branch:

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,state --jq '.[0]'
```

### Classify Change Scope

Check which files the PR touches:

```bash
gh pr diff <NUMBER> --name-only
```

Categorize into flags — set each to `true` or `false`:

| Flag | Pattern | What It Triggers |
|------|---------|-----------------|
| `HAS_BACKEND` | `Infrastructure/<YOUR_API_PROJECT>/**` (excluding `*.md`) | Dev deploy, staging/prod promotion |
| `HAS_TERRAFORM` | `Infrastructure/terraform/**` | Terraform apply at each environment |
| `HAS_MIGRATIONS` | `Infrastructure/<YOUR_API_PROJECT>/Data/Migrations/*.sql` (new files only) | DB migration workflow at each environment |
| `HAS_IOS` | `<YOUR_APP>/**` (excluding `*.md`) | iOS CI only (no deployment) |

### Check CI Status

```bash
gh pr checks <NUMBER>
```

If CI is not yet green, wait for it or enter the self-healing loop (Phase 2) on the PR branch before merging.

### Present Summary and Confirm

Show the user:
- PR title and number
- Change scope flags
- Which phases will run
- Current CI status

Ask for confirmation before proceeding to merge.

---

## Phase 1: Merge & Monitor

### Merge

```bash
gh pr merge <NUMBER> --squash --delete-branch
```

Capture the merge commit SHA:

```bash
MERGE_SHA=$(gh pr view <NUMBER> --json mergeCommit --jq '.mergeCommit.oid')
```

### Discover Triggered Workflows

Wait ~15 seconds for GitHub Actions to register the push event, then discover what was triggered:

```bash
sleep 15
gh run list --commit "$MERGE_SHA" --json workflowName,databaseId,status,conclusion,createdAt
```

Expected workflows based on change scope:
- Backend changes → "Deploy to Dev" (`gcp-deploy.yml`)
- Terraform changes → "Terraform" (`gcp-terraform.yml`) — this auto-run only does `plan`
- Both → both workflows trigger

### Watch Until Completion

For each triggered workflow run:

```bash
gh run watch <RUN_ID>
```

If a run completes with `conclusion: success`, move on. If it fails, enter Phase 2.

---

## Phase 2: Self-Healing Loop

This phase activates whenever a workflow run fails, at any point in the pipeline.

### Step 1: Get Failure Logs

```bash
gh run view <RUN_ID> --log-failed 2>&1 | tail -200
```

The `--log-failed` flag shows only the output from failed steps, which is exactly what you need for diagnosis.

### Step 2: Classify the Failure

Read the logs carefully and classify into one of these categories:

| Category | Signals | Action |
|----------|---------|--------|
| **Build error** | `error CS`, `Build FAILED`, compiler errors | Fix the source code |
| **Test failure (legit bug)** | Test assertion failed, the test logic is correct but the code under test is wrong | Fix the production code |
| **Test failure (flaky/bad test)** | Test makes fragile assumptions, race conditions, hardcoded values, test logic is wrong | Fix the test |
| **Terraform error** | `Error:` in terraform output, missing variable, invalid config | Fix the terraform files |
| **Transient/infra** | Runner failed, network timeout, `GITHUB_TOKEN` expired, rate limit | Rerun failed jobs |
| **Auth/permissions** | Missing IAM role, secret not found, 403 | **Stop and report** — can't self-fix |

The distinction between "legit bug" and "bad test" is the most important judgment call. Look at the test assertion and the code being tested. If the test expectation is reasonable and the code doesn't meet it, the code is wrong. If the test expectation is unreasonable, overly brittle, or testing the wrong thing, the test is wrong.

### Step 3: Apply the Fix

**For code/test/terraform fixes:**

1. Read the failing file(s) to understand context
2. Make the minimal fix needed
3. Commit and push:

```bash
git add <specific-files>
git commit -m "fix: <description of what was wrong and why>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push
```

4. The push to main triggers new workflow runs — return to monitoring (Phase 1's watch step)
5. Increment the fix attempt counter

**For transient failures:**

```bash
gh run rerun <RUN_ID> --failed
```

This reruns only the failed jobs, not the entire workflow. Then watch the rerun.

**For auth/permissions failures:**

Stop the pipeline and report to the user. These require manual intervention (GCP Console, Secret Manager, IAM changes).

### Step 4: Check Budget

If fix attempts >= 5, stop and report:
- How many attempts were made
- What was tried each time
- What the current failure looks like
- Suggestion for manual investigation

---

## Phase 3: DB Migrations (Dev)

**Skip this phase if `HAS_MIGRATIONS` is false.**

New SQL migration files need to be applied to the database before the new code starts serving traffic. The dev deploy runs concurrently (it was triggered by the push to main), but Cloud Run's rolling update means the old revision handles traffic until the new one is healthy — so running migrations now is safe.

### Check Migration Status

```bash
gh workflow run gcp-db-migrations.yml -f environment=dev -f action=status
```

Wait for the status workflow to complete, then read its output:

```bash
# Find the run ID
RUN_ID=$(gh run list -w "Database Migrations" -L 1 --json databaseId --jq '.[0].databaseId')
gh run view "$RUN_ID" --log 2>&1 | grep -A 50 "Pending Migrations"
```

### Apply Migrations

```bash
gh workflow run gcp-db-migrations.yml -f environment=dev -f action=migrate
```

Monitor the migration workflow:

```bash
sleep 10
RUN_ID=$(gh run list -w "Database Migrations" -L 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
```

If the migration fails:
- Read the failure logs
- If it's a SQL syntax error or logic issue in the new migration file, fix it and push (counts as a fix attempt)
- If it's a connection issue or transient error, rerun
- If the migration partially applied or the error is unclear, **stop and report** — DB failures are high-risk

---

## Phase 4: Terraform Apply (Dev)

**Skip this phase if `HAS_TERRAFORM` is false.**

The push-to-main terraform workflow only runs `plan`, not `apply`. You need to explicitly trigger apply.

This is important because terraform may add environment variables or secrets that the new code needs. Terraform apply should complete before promoting to staging (CLAUDE.md gotcha #21: "Terraform Apply != Code Deploy").

```bash
gh workflow run gcp-terraform.yml -f environment=dev -f action=apply
```

Monitor:

```bash
sleep 10
RUN_ID=$(gh run list -w "Terraform Infrastructure" -L 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
```

If terraform apply fails, enter the self-healing loop (Phase 2).

---

## Phase 5: Dev Verification

Wait for the dev deploy workflow to complete if it's still running:

```bash
# Check if Deploy to Dev is still running
gh run list -w "Deploy to Dev" -L 1 --json databaseId,status,conclusion
```

If still `in_progress`, watch it:

```bash
gh run watch <RUN_ID>
```

### Health Checks

Read the dev URL from `Infrastructure/docs/api-endpoints.json`, then verify:

```bash
# Health endpoint
curl -sf "$(jq -r '.environments.dev.baseUrl' Infrastructure/docs/api-endpoints.json)/health"

# Config structure (should return valid JSON with expected fields)
curl -sf "$(jq -r '.environments.dev.baseUrl' Infrastructure/docs/api-endpoints.json)/config/generative-media" | jq '.image.model, .video.model'
```

If health checks fail, the deploy workflow's own smoke test likely also failed — check its status and enter self-healing if needed.

### Report Dev Status

Update and display the status table. Dev is now fully deployed and verified.

---

## Phase 6: Staging Promotion

### Step 1: DB Migrations (Staging)

**Skip if `HAS_MIGRATIONS` is false.**

```bash
gh workflow run gcp-db-migrations.yml -f environment=staging -f action=migrate
```

The staging environment has a GitHub Environment approval gate for the `migrate` action. If the workflow is waiting for approval, inform the user:

> "The staging migration workflow needs approval in the GitHub UI. Please approve it at: https://github.com/<owner>/<repo>/actions/runs/<RUN_ID>"

Monitor until complete. Self-heal if needed.

### Step 2: Terraform Apply (Staging)

**Skip if `HAS_TERRAFORM` is false.**

```bash
gh workflow run gcp-terraform.yml -f environment=staging -f action=apply
```

Monitor. The staging terraform may also require approval depending on environment protection rules.

### Step 3: Code Promotion

```bash
gh workflow run gcp-promote-staging.yml
```

This auto-detects the latest successful dev deploy image and copies it to the staging Artifact Registry via `crane`. It may require GitHub Environment approval.

Monitor:

```bash
sleep 10
RUN_ID=$(gh run list -w "Promote to Staging" -L 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
```

If the promotion fails, enter the self-healing loop.

### Step 4: Staging Verification

```bash
curl -sf "$(jq -r '.environments.staging.baseUrl' Infrastructure/docs/api-endpoints.json)/health"
curl -sf "$(jq -r '.environments.staging.baseUrl' Infrastructure/docs/api-endpoints.json)/config/generative-media" | jq '.image.model, .video.model'
```

Update and display the status table.

---

## Phase 7: Production Promotion

Invoking this skill IS the user's approval to go all the way to production. No additional confirmation needed — proceed automatically through prod once staging is verified.

### Step 1: DB Migrations (Prod)

**Skip if `HAS_MIGRATIONS` is false.**

```bash
gh workflow run gcp-db-migrations.yml -f environment=prod -f action=migrate
```

Inform the user about the approval gate. Monitor until complete.

### Step 2: Terraform Apply (Prod)

**Skip if `HAS_TERRAFORM` is false.**

```bash
gh workflow run gcp-terraform.yml -f environment=prod -f action=apply
```

Monitor. Prod terraform likely requires approval.

### Step 3: Code Promotion

```bash
gh workflow run gcp-promote-prod.yml
```

Inform the user about the approval gate. Monitor:

```bash
sleep 10
RUN_ID=$(gh run list -w "Promote to Production" -L 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
```

**If prod deployment fails — NO auto-fix.** Instead:

1. Get the failure logs: `gh run view <RUN_ID> --log-failed`
2. Analyze the failure
3. Present the analysis to the user with these options:
   - **Rollback**: `gh workflow run gcp-rollback.yml -f environment=prod -f revision=<previous-revision>`
   - **Investigate**: Dig deeper into logs, check Cloud Logging
   - **Rerun**: `gh run rerun <RUN_ID> --failed` (if it looks transient)

Never auto-rollback production. The user decides.

### Step 4: Prod Verification

```bash
curl -sf "$(jq -r '.environments.prod.baseUrl' Infrastructure/docs/api-endpoints.json)/health"
curl -sf "$(jq -r '.environments.prod.baseUrl' Infrastructure/docs/api-endpoints.json)/config/generative-media" | jq '.image.model, .video.model'
```

### Step 5: Final Report

Display the completed status table with all durations. Calculate total pipeline time from `PIPELINE_START`. Something like:

```markdown
## Deploy Complete

All environments are live and verified.

| Phase | Status | Duration |
|-------|--------|----------|
| Merge | Done | 0:02 |
| CI/Deploy (dev) | Done | 4:15 |
| DB Migrations (dev) | Done | 1:30 |
| Terraform (dev) | Skipped | - |
| Dev Health | Passed | 0:05 |
| DB Migrations (staging) | Done | 1:45 |
| Staging Promote | Done | 3:20 |
| Staging Health | Passed | 0:05 |
| DB Migrations (prod) | Done | 2:10 |
| Prod Promote | Done | 3:45 |
| Prod Health | Passed | 0:05 |

**Total pipeline time**: 17:02
**Self-healing attempts used**: 1/5
**Merge SHA**: abc1234
```

---

## Partial Invocation

The skill supports starting at any phase when the user hasn't asked for a full merge-to-prod flow:

| User says | Start at | Notes |
|-----------|----------|-------|
| "promote to staging" | Phase 6 | Assumes dev is already deployed. Verify dev health first. |
| "deploy to prod" / "promote to prod" | Phase 7 | Assumes staging is deployed. Verify staging health first. |
| "run migrations on dev/staging/prod" | Phase 3/6.1/7.1 | Just the migration step for that environment. |
| "check deploy status" | None | Read `api-endpoints.json` and run health checks across all envs. |
| "rollback prod" | None | Run `gh workflow run gcp-rollback.yml -f environment=prod` and monitor. |

For partial invocations, skip Phase 0 recon and infer the scope from context. Still run health verification after any deployment action.

---

## Detecting Approval Gates

GitHub Environment approvals cause a workflow run to enter `waiting` status. Detect this with:

```bash
gh run view <RUN_ID> --json status --jq '.status'
```

If status is `waiting`, check which environment needs approval:

```bash
gh run view <RUN_ID> --json jobs --jq '.jobs[] | select(.status == "waiting") | .name'
```

Then inform the user with a direct link:

```
The workflow is waiting for environment approval.
Approve at: https://github.com/OWNER/REPO/actions/runs/<RUN_ID>
```

After the user approves, resume monitoring with `gh run watch <RUN_ID>`.

---

## Troubleshooting Reference

### Common Self-Healable Failures

| Failure | Fix Pattern |
|---------|-------------|
| `error CS` + missing using | Add the missing `using` statement |
| `dotnet test` assertion failure | Read the test, read the code, fix whichever is wrong |
| Terraform `resource already exists` | Import or adjust config |
| Terraform `secret not found` | Create the secret version via gcloud (if you have access) or report |
| `crane: ... not found` | Image wasn't pushed — check if dev deploy completed |
| Smoke test HTTP 503 | New revision not ready yet — rerun (transient) |
| `xcodebuild` error | Fix Swift compilation error |

### When to Stop and Report

- Auth/IAM failures (need GCP Console access)
- Secret Manager issues (need manual secret creation)
- DB migration failures that can't be resolved with SQL fixes
- 5 fix attempts exhausted
- Pipeline exceeds 30 minutes
- Any production failure
