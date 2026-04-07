---
name: prd-to-pr
description: >-
  End-to-end pipeline from PRD to merged PR. Chains /prd-taskmaster → /shape-spec →
  plan refinement counsel (Opus 4.6 + Codex 5.4 extra high) → multi-agent implementation →
  /simplify → /pr-handoff-to-codex with adversarial review → Copilot feedback review →
  /self-healing-deploy. Use when user wants the full pipeline: "build this feature",
  "PRD to PR", "end to end".
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - Skill
  - Agent
  - TeamCreate
  - SendMessage
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
---

# PRD-to-PR Pipeline v1.0 — End-to-End Feature Delivery

Orchestrate the full lifecycle from product requirements to a reviewed, ready-to-merge pull request. This skill chains existing tools and adds new capabilities between them.

## When to Use This Skill

Activate when user:
- Says "PRD to PR", "end to end", "build this feature from scratch"
- Wants the full pipeline from requirements through merged PR
- Describes a feature and expects a delivered PR

Do NOT activate for:
- PRD generation only → use `/prd-taskmaster`
- PR review only → use `/pr-handoff-to-codex`
- Code simplification only → use `/simplify`
- Plan shaping only → use `/agent-os:shape-spec`

## Core Principles

**The Checklist Discipline**
Good software development is an art and a science. Think of it like modern aviation — the systems that have achieved true greatness use checklists religiously. Even a great pilot like Sully ran checklists before landing the plane and in decision-making. This pipeline is our checklist. Every stage runs. Every time. No exceptions.

**ALL 8 STAGES ARE MANDATORY**
No stage may be skipped, abbreviated, or "optimized away" regardless of perceived simplicity, time pressure, or context compaction. A "simple" feature still gets counsel review. A "small" change still gets simplification. A "clean" implementation still gets Codex adversarial review. The stages exist because human judgment about what's "simple enough to skip" is unreliable — the checklist removes that failure mode.

**Full Pipeline Ownership**
This skill owns the entire journey. It delegates to specialized skills for each stage but maintains orchestration control throughout.

**Quality Over Speed**
Every stage has a quality gate. The plan refinement counsel ensures we build the right thing. The adversarial PR review ensures we built it right.

**Claude Code for Implementation, Codex for Review**
Implementation uses Claude Code's multi-agent teams (TeamCreate, file ownership, wave execution). Review uses Codex's autonomous fix-apply-test loop.

**Opus 4.6 Everything**
All Claude Code agents run at Opus 4.6. No exceptions. No cost-saving downgrades.

## Pipeline Overview (8 Stages — ALL MANDATORY)

```
Stage 1: Generate PRD               → /prd-taskmaster (MANDATORY)
Stage 2: Shape the Plan             → /agent-os:shape-spec (MANDATORY)
Stage 3: Plan Refinement Counsel    → Opus 4.6 + Codex 5.4 extra high adversarial review (MANDATORY)
Stage 4: Multi-Agent Implementation → Claude Code agent teams (MANDATORY)
Stage 5: Simplification Pass        → /simplify (MANDATORY)
Stage 6: Create PR + Codex Review   → /pr-handoff-to-codex (MANDATORY)
Stage 7: Copilot Feedback Review    → Check & apply GitHub Copilot suggestions (MANDATORY)
Stage 8: Self-Healing Deploy        → /self-healing-deploy (MANDATORY)
```

> **No-skip rule**: If context compaction occurs mid-pipeline, check pipeline state and resume from the next incomplete stage. If a stage can no longer run as designed (e.g., counsel after implementation is done), flag it to the user and adapt — but never silently skip it.

---

## Stage 1: Generate PRD

**Delegate to**: `/prd-taskmaster`

Invoke the prd-taskmaster skill. It handles the full PRD lifecycle:
- Discovery (interactive requirements gathering)
- PRD generation (comprehensive, zero-compromise)
- Quality validation (14 automated checks)
- GitHub issue publication

**Capture from prd-taskmaster**:
- `ISSUE_URL` — the published GitHub issue URL
- `PRD_PATH` — local file path (`.taskmaster/docs/prd-{slug}.md`)
- `FEATURE_SLUG` — derived from the feature name
- Detected scope: `SCOPE_IOS`, `SCOPE_BACKEND`, `SCOPE_GCP_INFRA`

```
Use Skill tool: skill="prd-taskmaster"
```

**After prd-taskmaster completes**, confirm you have the issue URL and detected scope before proceeding. If prd-taskmaster triggered shape-spec automatically, skip Stage 2.

---

## Stage 2: Shape the Plan

**Delegate to**: `/agent-os:shape-spec`

If not already triggered by prd-taskmaster, invoke shape-spec with the scope-aware prompt.

```
Use Skill tool: skill="agent-os:shape-spec", args="{scope-aware prompt with ISSUE_URL}"
```

**Capture from shape-spec**:
- `SPEC_FOLDER` — path to `agent-os/specs/{YYYY-MM-DD-HHMM-feature-slug}/`
- `PLAN_PATH` — `{SPEC_FOLDER}/plan.md`

**Gate**: Plan must exist at `PLAN_PATH` before proceeding.

---

## Stage 3: Plan Refinement Counsel

**Owned by**: this skill (prd-to-pr)

Before implementation begins, the plan undergoes adversarial review by a small counsel to ensure quality, completeness, and feasibility.

### Counsel Architecture

| Role | Agent | Focus |
|------|-------|-------|
| **Reviewer A** | Claude Code subagent (Opus 4.6) | Tech stack fidelity, product spec coverage, architectural soundness |
| **Reviewer B** | Codex (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox`) | Implementation feasibility, complexity cost, parallelization realism |
| **Reviewer C** | Codex 5.4 extra high (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox --model codex-5.4 --reasoning-effort extra-high`) | Deep reasoning review — risk analysis, hidden dependencies, edge-case coverage, cross-system failure modes. Orchestrator's discretion on focus area. |
| **Orchestrator** | Main session (you) | Curious, quality-obsessed, tie-breaker. May dispatch additional Codex 5.4 extra high agents if a domain warrants deeper analysis. |

### Communication Protocol

The counsel communicates via a shared discussion log at `{SPEC_FOLDER}/counsel-log.md`. This creates a permanent, auditable record of the review discussion that survives session boundaries.

See `reference/counsel-protocol.md` for the full discussion log format.

### Process

#### 3.1: Initialize Discussion Log

Write the initial counsel-log.md:

```markdown
# Plan Refinement Counsel — {Feature Name}

**PRD**: {ISSUE_URL}
**Plan**: {PLAN_PATH}
**Date**: {current date/time}

---

## Round 1: Initial Reviews

### Reviewer A (Tech Stack + Product Spec)

_Pending..._

### Reviewer B (Implementation Feasibility)

_Pending..._

### Reviewer C (Codex 5.4 Extra High — Deep Reasoning)

_Pending..._

---

## Round 2: Orchestrator Synthesis

_Pending..._

## Refined Plan Amendments

_Pending..._

## Final Verdict

_Pending..._
```

#### 3.2: Spawn Reviewer A (Opus 4.6 Subagent)

Launch a Claude Code subagent at Opus 4.6 with this prompt:

```
You are Reviewer A on a plan refinement counsel. Your lens is TECH STACK + PRODUCT SPEC.

PRD (source of truth): {ISSUE_URL}
Plan under review: Read {PLAN_PATH}
Tech Stack context: Read CLAUDE.md for full stack details (iOS Swift 6/SwiftUI, .NET 8 Cloud Run, PostgreSQL, Firebase Auth)

Your job:
1. Read the PRD from the GitHub issue (use `gh issue view {ISSUE_NUMBER}`)
2. Read the plan at {PLAN_PATH}
3. Read CLAUDE.md for tech stack context
4. Evaluate the plan against these criteria:
   a. Does the plan cover EVERY requirement in the PRD? Map each REQ-XXX to a task.
   b. Are architecture choices sound for this tech stack?
   c. Are there missing edge cases, error handling, or integration points?
   d. Is the file ownership matrix clean? Any potential merge conflicts?
   e. Are the wave dependencies correct? Any tasks that should be parallel but aren't?
   f. Does the plan follow CLAUDE.md patterns (config-driven AI, .Select() projections, @Observable, etc.)?

Write your findings to: {SPEC_FOLDER}/counsel-log.md
Replace the "Reviewer A" section with your structured critique.

Format each finding as:
- [ISSUE] — {description} — {rationale} — {suggested fix}
- [SUGGESTION] — {description} — {rationale}
- [APPROVAL] — {what looks good} — {why}

Be thorough but concise. Focus on substance, not style.
```

#### 3.3: Run Reviewer B (Codex)

After Reviewer A completes, run Codex for the feasibility review:

```bash
# Write the Codex prompt to a temp file
cat > /tmp/counsel-reviewer-b-prompt.md << 'PROMPT_EOF'
You are Reviewer B on a plan refinement counsel. Your lens is IMPLEMENTATION FEASIBILITY.

PRD: {ISSUE_URL}
Plan: Read {PLAN_PATH}

Your job:
1. Read the PRD (use `gh issue view {ISSUE_NUMBER}`)
2. Read the plan at {PLAN_PATH}
3. Evaluate the plan against these criteria:
   a. Can each task actually be completed as described? Flag unrealistic tasks.
   b. Are the file ownership boundaries clean or will agents step on each other?
   c. Is the parallelization realistic or will there be hidden dependencies?
   d. Are build/test verification steps sufficient?
   e. Is the complexity proportionate to the value delivered?
   f. Are there simpler approaches that achieve the same outcome?

4. Read the current Reviewer A findings from {SPEC_FOLDER}/counsel-log.md
5. Append your findings to counsel-log.md under the "Reviewer B" section.

Format each finding as:
- [ISSUE] — {description} — {rationale} — {suggested fix}
- [SUGGESTION] — {description} — {rationale}
- [APPROVAL] — {what looks good} — {why}
- [DISAGREE with Reviewer A] — {which finding} — {why you disagree} — {your alternative}

Be direct. If Reviewer A missed something, call it out. If they're wrong, say so.
PROMPT_EOF

# Launch Codex
codex exec \
  --full-auto \
  --dangerously-bypass-approvals-and-sandbox \
  -o /tmp/counsel-reviewer-b-result.md \
  "$(cat /tmp/counsel-reviewer-b-prompt.md)"
```

#### 3.4: Run Reviewer C (Codex 5.4 Extra High)

After Reviewers A and B complete, run the Codex 5.4 extra high reasoning agent. The orchestrator chooses the focus area based on what A and B surfaced — common targets include risk analysis, hidden cross-system dependencies, or edge-case coverage gaps.

```bash
# Write the Codex 5.4 prompt to a temp file
cat > /tmp/counsel-reviewer-c-prompt.md << 'PROMPT_EOF'
You are Reviewer C on a plan refinement counsel. You are the DEEP REASONING reviewer.
Your lens is chosen by the orchestrator based on what previous reviewers surfaced.

FOCUS AREA: {ORCHESTRATOR_CHOSEN_FOCUS — e.g., "cross-system failure modes", "data migration risk", "concurrency edge cases"}

PRD: {ISSUE_URL}
Plan: Read {PLAN_PATH}

Your job:
1. Read the PRD (use `gh issue view {ISSUE_NUMBER}`)
2. Read the plan at {PLAN_PATH}
3. Read the findings from Reviewer A and Reviewer B in {SPEC_FOLDER}/counsel-log.md
4. Apply DEEP reasoning to your focus area. Think step by step. Consider:
   a. What could go WRONG that the other reviewers missed?
   b. What are the hidden dependencies between components?
   c. What edge cases or failure modes are unaddressed?
   d. What are the second-order effects of this plan on the broader system?
   e. Are there race conditions, data consistency risks, or rollback gaps?
   f. Does the plan handle partial failure gracefully?

5. Append your findings to counsel-log.md under the "Reviewer C" section.

Format each finding as:
- [RISK] — {description} — {probability: low/medium/high} — {impact: low/medium/high} — {mitigation}
- [ISSUE] — {description} — {rationale} — {suggested fix}
- [DISAGREE with Reviewer A/B] — {which finding} — {why you disagree} — {your alternative}
- [AMPLIFY from Reviewer A/B] — {which finding} — {additional depth or context they missed}
- [APPROVAL] — {what looks good} — {why}

Be the hardest reviewer in the room. Your job is to find what others missed.
PROMPT_EOF

# Launch Codex 5.4 with extra high reasoning
codex exec \
  --full-auto \
  --dangerously-bypass-approvals-and-sandbox \
  --model codex-5.4 \
  --reasoning-effort extra-high \
  -o /tmp/counsel-reviewer-c-result.md \
  "$(cat /tmp/counsel-reviewer-c-prompt.md)"
```

**Orchestrator discretion**: The orchestrator may spawn additional Codex 5.4 extra high agents if a specific domain (e.g., database migration safety, auth flow integrity) warrants independent deep analysis. Each additional agent gets a narrowed focus and writes to the counsel-log under its own section.

#### 3.5: Orchestrator Synthesis

After all three reviewers complete, the orchestrator (main session — you) reads the full counsel-log.md and synthesizes:

**Orchestrator Personality**:
> You are the quality champion. Be curious — ask "why?" about every decision. Challenge assumptions. Never accept "good enough." Fight for quality in every detail. But when reviewers disagree, you are the tie-breaker — make the call decisively with clear rationale.

**Synthesis Process**:
1. Read the full counsel-log.md
2. For each finding:
   - **Agreements** (both reviewers align): Strong signal. Accept and incorporate.
   - **Conflicts** (reviewers disagree): Weigh both sides. Make the call. Document rationale.
   - **Gaps** (neither reviewer caught): This is your curiosity mandate. Ask "why?" about every non-obvious decision in the plan. Look for what's missing.
3. Write the "Orchestrator Synthesis" section in counsel-log.md
4. Write the "Refined Plan Amendments" section — specific changes to plan.md with rationale
5. Apply the amendments to plan.md
6. Write the "Final Verdict":
   - **APPROVED** — proceed to Stage 4
   - **REQUIRES REWORK** — send specific feedback, loop (max 2 iterations)

**Use AskUserQuestion** to present the verdict and any significant amendments for user confirmation before proceeding.

---

## Stage 4: Multi-Agent Implementation

**Owned by**: this skill (prd-to-pr)

Orchestrate implementation using Claude Code's multi-agent team pattern.

### 4.1: Determine Agent Roster

Based on the scope detected in Stage 1:

| Scope Detected | Agent to Spawn |
|---------------|----------------|
| `SCOPE_IOS` | `ios-engineer` |
| `SCOPE_BACKEND` | `backend-engineer` |
| `SCOPE_GCP_INFRA` | `infra-engineer` |
| Always | `test-engineer` |
| Multi-scope (2+) | `integration-engineer` |

### 4.2: Build File Ownership Matrix

Read the refined plan.md and extract all files to be created or modified. Assign each file to exactly one agent. No file is shared — this is what prevents merge conflicts.

```
Example:
  backend-engineer:
    - Infrastructure/<YOUR_API_PROJECT>/Data/Migrations/0XX_NewFeature.sql (CREATE)
    - Infrastructure/<YOUR_API_PROJECT>/Data/Entities/NewEntities.cs (CREATE)
    - Infrastructure/<YOUR_API_PROJECT>/Controllers/NewController.cs (CREATE)
    - Infrastructure/<YOUR_API_PROJECT>/Data/<YOUR_APP>DbContext.cs (MODIFY — append DbSet only)

  ios-engineer:
    - <YOUR_APP>/<YOUR_APP>/Core/Models/NewModels.swift (CREATE)
    - <YOUR_APP>/<YOUR_APP>/Features/NewFeature/NewService.swift (CREATE)
    - <YOUR_APP>/<YOUR_APP>/Features/NewFeature/NewViewModel.swift (CREATE)
    - <YOUR_APP>/<YOUR_APP>/Core/Services/GCP/GCPAPIURLBuilder.swift (MODIFY — append URLs only)
```

**Shared file rule**: If multiple agents need to modify the same file (e.g., `GCPStartup.cs`), assign it to one agent and have others add their registrations to the END of the file only.

### 4.3: Create Task Dependency Graph

Organize tasks into execution waves:

```
Wave 1 (parallel — foundation):
  - DB migration (backend-engineer)
  - DTOs/Models (backend-engineer or ios-engineer)

Wave 2 (sequential — core implementation):
  - Services (backend-engineer)
  - Controllers (backend-engineer)
  - iOS service layer (ios-engineer)

Wave 3 (parallel — integration + tests):
  - iOS ViewModels + Views (ios-engineer)
  - Backend tests (test-engineer)
  - iOS tests (test-engineer)

Wave 4 (sequential — verification):
  - Backend build gate (team-lead)
  - iOS build gate (team-lead)
  - Integration verification (integration-engineer or team-lead)
```

### 4.4: Create Team and Spawn Agents

```
Use TeamCreate tool:
  name: {feature-slug}
  members: [list of agents from 4.1]
```

Then spawn each agent with a detailed prompt:

```
Use Agent tool for each member:
  model: opus
  team_name: {feature-slug}
  name: {agent-name}
  prompt: |
    You are `{role}-engineer` on the `{feature-slug}` team.

    PRD: {ISSUE_URL}
    Spec: {PLAN_PATH}

    YOUR FILES (you own these exclusively — no other agent touches them):
    {file ownership list from 4.2}

    YOUR TASKS:
    {task list with IDs and blockedBy dependencies from 4.3}

    Build verification after each task:
    {scope-specific build commands from CLAUDE.md}

    Rules:
    - Tests alongside implementation, not after
    - Verify your own work builds before marking tasks complete
    - Use TaskUpdate to mark tasks completed
    - Use SendMessage to team-lead if blocked
    - Follow existing patterns in the codebase — read before writing
    - Config-driven: no hardcoded AI model names, prompts, or magic numbers
```

### 4.5: Monitor and Gate

1. Monitor task completion via TaskList/TaskGet
2. After each wave completes, verify builds pass
3. After all waves complete, run full verification:

```bash
# Backend
cd Infrastructure/<YOUR_API_PROJECT> && dotnet build <YOUR_API_PROJECT>.GCP.csproj
cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"

# iOS (if applicable)
cd <YOUR_APP> && xcodebuild -project <YOUR_APP>.xcodeproj -scheme "<YOUR_APP> Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' build
```

4. **Gate**: ALL builds must pass before proceeding to Stage 5.
5. If builds fail: identify the failing agent's code, send fix instructions via SendMessage, re-verify.

---

## Stage 5: Simplification Pass

**Delegate to**: `/simplify`

After implementation completes and all builds pass:

1. Get the list of changed files:
   ```bash
   git diff --name-only main...HEAD
   ```

2. Invoke the code-simplifier:
   ```
   Use Skill tool: skill="simplify"
   ```
   The simplifier will automatically scope to recently modified files.

3. After simplification completes, re-run builds to verify nothing broke:
   ```bash
   cd Infrastructure/<YOUR_API_PROJECT> && dotnet build <YOUR_API_PROJECT>.GCP.csproj
   cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"
   ```

4. If builds pass, commit the simplification changes:
   ```bash
   git add -A && git commit -m "refactor: simplify implementation for clarity

   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
   ```

5. **Gate**: builds must pass after simplification before proceeding.

---

## Stage 6: Create PR + Codex Review

### 6.1: Create Pull Request

```bash
gh pr create \
  --title "{Feature Name}" \
  --body "$(cat <<'EOF'
## Summary

{1-3 bullet points summarizing the implementation}

## PRD

Closes #{ISSUE_NUMBER}

## Counsel Review

Plan refinement counsel: {SPEC_FOLDER}/counsel-log.md

## Test Plan

- [ ] Backend build passes
- [ ] Backend tests pass
- [ ] iOS build passes (if applicable)
- [ ] iOS tests pass (if applicable)
- [ ] Endpoint tested with curl (if applicable)
- [ ] No security vulnerabilities introduced

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Capture `PR_NUMBER` and `PR_URL` from the output.

### 6.2: Handoff to Codex

Invoke the enhanced `/pr-handoff-to-codex` skill for adversarial review:

```
Use Skill tool: skill="pr-handoff-to-codex", args="{PR_NUMBER}"
```

This triggers the adversarial counsel (3 Codex reviewers + 1 Codex orchestrator) that reviews, fixes, and pushes until green.

---

## Stage 7: Copilot Feedback Review

**Owned by**: this skill (prd-to-pr)

After the Codex adversarial review completes and pushes its fixes, check whether GitHub Copilot (the built-in GitHub code review bot) has left any feedback on the PR.

### 7.1: Wait for Copilot Review

GitHub Copilot reviewer typically responds within a few minutes of PR creation or new pushes. Wait briefly, then check:

```bash
# Check for Copilot review comments on the PR
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments --jq '.[] | select(.user.login == "copilot[bot]" or .user.login == "github-copilot[bot]") | {path: .path, line: .line, body: .body}'

# Also check PR review threads
gh api repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/reviews --jq '.[] | select(.user.login == "copilot[bot]" or .user.login == "github-copilot[bot]") | {state: .state, body: .body}'
```

If no Copilot feedback is found after ~2 minutes, proceed to Stage 8. Copilot doesn't review every PR.

### 7.2: Evaluate Copilot Suggestions

For each Copilot suggestion, evaluate:

1. **Is it valid?** Does the suggestion identify a real issue or improvement?
2. **Is it value-add?** Would applying it improve the code meaningfully — even if the suggestion is technically out of scope?
3. **Is there a better way?** Copilot's suggested fix may not be optimal. If you see a better approach, use yours instead.

**Apply everything valid and value-add, even if out of scope.** The goal is to ship the best possible code, not to stay narrowly scoped.

**You don't have to accept Copilot's solution.** If there's a better way to address the concern it raised, do it your way.

### 7.3: Apply Fixes

For each accepted suggestion:

1. Read the file and line referenced
2. Apply the fix (Copilot's suggestion or your better alternative)
3. After all fixes, verify builds still pass:

```bash
cd Infrastructure/<YOUR_API_PROJECT> && dotnet build <YOUR_API_PROJECT>.GCP.csproj
cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"
```

4. Commit and push:

```bash
git add <specific-files>
git commit -m "fix: address GitHub Copilot review feedback

Applied N suggestions, adapted M with better alternatives.

git push
```

5. If no valid suggestions were found, log it and move on:

```
Copilot Feedback: No actionable suggestions found (or no review submitted). Proceeding.
```

**Gate**: builds must pass after Copilot fixes before proceeding.

---

## Stage 8: Self-Healing Deploy

**Delegate to**: `/self-healing-deploy`

After all review stages complete and the PR is ready, invoke the self-healing deploy pipeline to merge and progressively deploy through dev → staging → prod.

```
Use Skill tool: skill="self-healing-deploy"
```

This handles:
- Squash merge to main
- CI monitoring with self-healing
- DB migrations per environment
- Terraform apply per environment
- Progressive promotion (dev → staging → prod)
- Health verification at each stage

The self-healing deploy skill manages its own state tracking and will report status throughout. It stops and asks for help on production failures.

**Gate**: The PR must have all CI checks passing before self-healing-deploy will merge it.

---

## Pipeline State Tracking

Track pipeline progress using output to the user at each stage transition:

```
Pipeline: PRD-to-PR for {Feature Name}

  [✓] Stage 1: PRD Generated — {ISSUE_URL}
  [✓] Stage 2: Plan Shaped — {SPEC_FOLDER}
  [✓] Stage 3: Counsel Approved — 2 issues resolved, 1 gap found (3 reviewers)
  [→] Stage 4: Implementation — Wave 2/4, 3/7 agents active
  [ ] Stage 5: Simplification
  [ ] Stage 6: PR + Codex Review
  [ ] Stage 7: Copilot Feedback Review
  [ ] Stage 8: Self-Healing Deploy (dev → staging → prod)
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| prd-taskmaster fails validation | Fix PRD, re-validate, re-publish |
| shape-spec plan rejected by counsel | Loop with specific feedback (max 2 iterations) |
| Codex 5.4 extra high times out or errors | Proceed with Reviewer A + B findings only; note the gap in counsel-log |
| Agent build failure during implementation | SendMessage to failing agent with fix instructions |
| Simplification breaks builds | Revert simplification commit, re-run /simplify with targeted scope, verify builds pass |
| Codex review finds critical issues | Codex orchestrator fixes autonomously |
| Codex hangs or times out | Fall back to Generate mode, output prompt for manual review |
| Copilot never reviews the PR | Proceed after ~2 min wait; log "No Copilot feedback received" |
| Copilot fixes break builds | Revert the Copilot-fix commit, skip that suggestion, re-verify |
| Self-healing deploy fails in dev/staging | Self-healing loop auto-fixes (up to 5 attempts) |
| Self-healing deploy fails in prod | Pipeline stops and presents options to user (rollback, investigate, rerun) |

---

## Tips

**Run the Checklist**: Like a pre-flight checklist, every stage runs every time. A pilot doesn't skip the engine check because "this is a short flight." You don't skip counsel because "this is a simple feature."

**Let the Counsel Debate**: Don't rush the counsel review. The point is to catch issues before implementation, when they're cheap to fix.

**File Ownership Is Sacred**: The #1 cause of multi-agent merge conflicts is shared files. If two agents need the same file, assign one agent and have the other's additions go to END of file only.

**One-Shot Delivery**: The pipeline is designed for one-shot execution. Ask clarifying questions in Stage 1 (PRD discovery), not mid-implementation.

**Context Compaction Is Not a Shortcut**: If the context window compresses mid-pipeline, pick up from the next incomplete stage. Never use compaction as justification to skip remaining stages.

---

**Remember**: This skill orchestrates the full pipeline. ALL 8 STAGES ARE MANDATORY. It delegates to specialized skills for each stage but maintains control throughout. The pipeline is: PRD → Plan → Counsel → Build → Simplify → Codex Review → Copilot Feedback → Deploy → Done.
