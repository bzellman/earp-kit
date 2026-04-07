# Pattern: Adversarial PR Review

## Overview

A 4-agent Codex-powered review system where specialized agents independently review a PR, then an orchestrator synthesizes findings and autonomously fixes issues.

## How It Works

1. **PR is ready for review** - developer triggers `/pr-handoff-to-codex`
2. **3 Specialized Reviewers** run in parallel (each as a Codex agent):
   - **Architecture Reviewer** - Evaluates design patterns, separation of concerns, scalability
   - **Security Reviewer** - Checks for OWASP top 10, auth issues, injection vectors
   - **Code Quality Reviewer** - Assesses readability, test coverage, naming, duplication
3. **Orchestrator Agent** - Synthesizes all 3 reviews, deduplicates findings, prioritizes by severity
4. **Autonomous Fix** - Orchestrator applies fixes, pushes updated commits, re-runs CI

## Key Design Decisions

- **Why 3 reviewers instead of 1?** Single-pass reviews miss category-specific issues. A security expert catches things an architecture reviewer misses, and vice versa.
- **Why Codex agents?** They run autonomously with full repo access, can modify code, and push changes - not just comment.
- **Why adversarial?** Each reviewer is instructed to be thorough and critical. The orchestrator balances severity vs. noise.

## When to Use

- Before merging any PR to main
- After significant refactors
- For security-sensitive changes (auth, payments, data handling)

## When NOT to Use

- Trivial changes (typos, comments, version bumps)
- Draft PRs still in progress
- Hotfixes that need immediate merge (use `/gh-fix-ci` instead)

## Integration Points

- Triggered by: `/pr-handoff-to-codex` skill
- Depends on: GitHub CLI (`gh`), Codex agents
- Feeds into: `/self-healing-deploy` for merge-to-production
- Part of: `/prd-to-pr` and `/bug-to-pr` pipelines

## See Also

- `skills/system/pr-handoff-to-codex/` - Full skill implementation
- `skills/system/bug-to-pr/` - Uses this as step 6 of 8
- `skills/system/prd-to-pr/` - Uses this as review gate
