# Pattern: Self-Healing Deploy Pipeline

## Overview

A 7-phase autonomous deployment pipeline that can detect CI failures, diagnose root causes, apply fixes, and re-push - all without human intervention.

## The 7 Phases

### Phase 0: Recon
- Classify the changes being deployed (backend, iOS, infrastructure, mixed)
- Determine which CI checks and deploy steps are relevant
- Set expectations for what "success" looks like

### Phase 1: Merge
- Merge the PR to main
- Handle merge conflicts if any arise

### Phase 2: Self-Heal CI
- Monitor CI pipeline execution
- If checks fail: read logs, classify the failure type
- Apply targeted fix based on failure category:
  - **Build failure** - Fix compilation errors, missing imports
  - **Test failure** - Fix broken assertions, update snapshots
  - **Lint failure** - Apply auto-formatting, fix style issues
  - **Infra failure** - Retry transient failures, fix config
- Push the fix and re-monitor

### Phase 3: DB Migrations
- If SQL migrations are part of the change, run `gcp-db-migrations.yml`
- Verify migration applied successfully
- Roll back if migration fails

### Phase 4: Terraform Apply
- If infrastructure changes are part of the change, run `gcp-terraform.yml`
- Apply terraform plan that was validated during CI

### Phase 5: Dev Verification
- Confirm the dev deployment is healthy
- Run smoke tests against dev endpoint
- Check Cloud Run logs for errors

### Phase 6: Staging Promotion
- Trigger `gcp-promote-staging.yml`
- Wait for environment approval gate
- Verify staging deployment health

### Phase 7: Production Promotion
- Trigger `gcp-promote-prod.yml`
- Wait for environment approval gate
- Verify production deployment health
- Announce completion

## Key Design Decisions

- **Why self-healing?** Most CI failures are fixable automatically (import errors, snapshot updates, lint). Human intervention adds hours of latency for 5-minute fixes.
- **Why phases?** Each phase is a checkpoint. Failure at any phase halts progression and reports status.
- **Build-once-promote-by-digest** - Images built in dev are promoted to staging/prod by SHA digest, never rebuilt.

## When to Use

Triggered by:
- "ship it" / "deploy this" / "merge and deploy"
- User approves a PR for merge
- `/self-healing-deploy` skill invocation

## Integration Points

- Uses: All 16 GitHub Actions workflows
- Preceded by: `/pr-handoff-to-codex` adversarial review
- Monitored by: `/gh-fix-ci` for CI failure debugging

## See Also

- `skills/system/self-healing-deploy/` - Full skill implementation
- `workflows/ci-cd/` - GitHub Actions workflows it orchestrates
- `docs/ci-cd-catalog.md` - Workflow documentation
