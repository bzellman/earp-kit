# Pattern: PRD-to-Production Pipeline

## Overview

An end-to-end orchestration that takes a product requirement from PRD document to deployed production code, chaining 8+ skills and commands in sequence.

## The Full Pipeline

```
1. /prd-taskmaster     -> PRD document + GitHub Issue
2. /agent-os:shape-spec -> Implementation plan in plan mode
3. Plan refinement     -> Counsel from Opus 4.6 + Codex 5.4
4. Implementation      -> Multi-agent development (dispatched agents)
5. /simplify           -> Code clarity and consistency pass
6. /pr-handoff-to-codex -> 4-agent adversarial review
7. Copilot feedback    -> Address review findings
8. /self-healing-deploy -> 7-phase merge to production
```

### Step 1: PRD Generation (`/prd-taskmaster`)
- Takes feature description from user
- Generates comprehensive PRD with all requirements as must-deliver (no deferred scope)
- Publishes PRD as GitHub Issue
- Triggers `/agent-os:shape-spec`

### Step 2: Specification Shaping (`/agent-os:shape-spec`)
- Enters plan mode
- Gathers context from standards index
- Produces structured implementation plan
- Identifies critical files, patterns to follow, tests to write

### Step 3: Plan Refinement
- Implementation plan reviewed by multiple models (Opus 4.6, Codex 5.4 extra high)
- Each provides independent perspective on approach
- Plan is refined based on counsel

### Step 4: Multi-Agent Implementation
- Dispatches specialized agents based on change type:
  - `ios-developer` for Swift/SwiftUI changes
  - `gcp-platform-engineer` for infrastructure
  - `dead-code-agent` for cleanup
- Uses TDD (superpowers:test-driven-development)
- Commits incrementally

### Step 5: Simplification (`/simplify`)
- Reviews all changed code for clarity, consistency, reuse
- Removes unnecessary complexity
- Ensures naming conventions match codebase

### Step 6: Adversarial Review (`/pr-handoff-to-codex`)
- 4 Codex agents review independently (architecture, security, quality, orchestrator)
- Autonomous fix application
- See: `patterns/adversarial-review.md`

### Step 7: Feedback Resolution
- Address any remaining review findings
- Re-run reviews until clean

### Step 8: Self-Healing Deploy (`/self-healing-deploy`)
- 7-phase autonomous deployment
- See: `patterns/self-healing-pipeline.md`

## When to Use

- Any feature that has clear requirements
- Triggered by: `/prd-to-pr` skill
- Also available step-by-step via individual skills

## Alternative: Bug-to-PR (`/bug-to-pr`)

Same pipeline but starts with bug triage instead of PRD:
1. Bug triage & reproduction
2. Root cause analysis
3. Fix strategy counsel
4. Targeted implementation
5. `/simplify`
6. `/pr-handoff-to-codex`
7. Feedback resolution
8. `/self-healing-deploy`

## See Also

- `skills/system/prd-to-pr/` - Full pipeline skill
- `skills/system/bug-to-pr/` - Bug variant
- `skills/system/prd-taskmaster/` - PRD generation
- `patterns/adversarial-review.md` - Review step detail
- `patterns/self-healing-pipeline.md` - Deploy step detail
