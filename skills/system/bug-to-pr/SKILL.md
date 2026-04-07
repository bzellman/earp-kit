---
name: bug-to-pr
description: >-
  End-to-end pipeline from bug report to merged fix PR. Chains bug triage & reproduction →
  root cause analysis → fix strategy counsel (Opus 4.6 + Codex 5.4 extra high) →
  targeted implementation → /simplify → /pr-handoff-to-codex with adversarial review →
  Copilot feedback review → /self-healing-deploy. Use when user reports a bug and
  expects a delivered fix: "fix this bug", "bug to PR", "debug and fix".
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

# Bug-to-PR Pipeline v1.0 — End-to-End Bug Resolution

Orchestrate the full lifecycle from bug report to a reviewed, ready-to-merge fix PR. This skill chains existing tools and adds new capabilities between them. It mirrors the discipline of `/prd-to-pr` but every stage is purpose-built for debugging and fixing rather than building new features.

## When to Use This Skill

Activate when user:
- Says "bug to PR", "fix this bug", "debug and fix", "resolve this issue"
- Reports a bug and expects a delivered fix PR
- Pastes an error, stack trace, or reproduction steps and wants it resolved end-to-end

Do NOT activate for:
- New features → use `/prd-to-pr`
- PR review only → use `/pr-handoff-to-codex`
- Code simplification only → use `/simplify`
- Quick one-line fixes the user can obviously describe → just fix it directly

## Core Principles

**The Checklist Discipline**
Good software development is an art and a science. Think of it like modern aviation — the systems that have achieved true greatness use checklists religiously. Even a great pilot like Sully ran checklists before landing the plane and in decision-making. This pipeline is our checklist. Every stage runs. Every time. No exceptions.

**ALL 8 STAGES ARE MANDATORY**
No stage may be skipped, abbreviated, or "optimized away" regardless of perceived simplicity, time pressure, or context compaction. A "simple" bug still gets counsel review. A "small" fix still gets simplification. An "obvious" fix still gets Codex adversarial review. The stages exist because human judgment about what's "simple enough to skip" is unreliable — the checklist removes that failure mode. Bugs that look simple are the ones that cause regressions.

**Diagnosis Before Treatment**
Never jump to a fix. Reproduce first, diagnose second, plan third, implement fourth. The most dangerous bug fixes are the ones that "obviously" address the problem but actually treat a symptom.

**Minimal Fix, Maximum Confidence**
Bug fixes should be surgical. Change the minimum necessary to resolve the root cause. No "while we're here" refactoring, no scope creep. But testing must be expansive — cover the fix, the regression, and the blast radius.

**Claude Code for Implementation, Codex for Review**
Implementation uses Claude Code's multi-agent teams (TeamCreate, file ownership, wave execution). Review uses Codex's autonomous fix-apply-test loop.

**Opus 4.6 Everything**
All Claude Code agents run at Opus 4.6. No exceptions. No cost-saving downgrades.

## Pipeline Overview (8 Stages — ALL MANDATORY)

```
Stage 1: Bug Triage & Reproduction     → Interactive diagnosis + GitHub issue (MANDATORY)
Stage 2: Root Cause Analysis            → Systematic debugging with evidence (MANDATORY)
Stage 3: Fix Strategy Counsel           → Opus 4.6 + Codex 5.4 extra high adversarial review (MANDATORY)
Stage 4: Targeted Implementation        → Claude Code agent teams (MANDATORY)
Stage 5: Simplification Pass            → /simplify (MANDATORY)
Stage 6: Create PR + Codex Review       → /pr-handoff-to-codex (MANDATORY)
Stage 7: Copilot Feedback Review        → Check & apply GitHub Copilot suggestions (MANDATORY)
Stage 8: Self-Healing Deploy            → /self-healing-deploy (MANDATORY)
```

> **No-skip rule**: If context compaction occurs mid-pipeline, check pipeline state and resume from the next incomplete stage. If a stage can no longer run as designed, flag it to the user and adapt — but never silently skip it.

---

## Stage 1: Bug Triage & Reproduction

**Owned by**: this skill (bug-to-pr)

Before anything else, the bug must be understood and reproducible. No reproduction = no confidence in any fix.

### 1.1: Gather Bug Context

Use **AskUserQuestion** to collect:

1. **Symptoms**: What is the user observing? Error messages, unexpected behavior, crashes?
2. **Reproduction Steps**: How to trigger the bug? (If unknown, that's fine — we'll find them.)
3. **Environment**: Which environment? (`dev`, `staging`, `prod`). Which platform? (iOS, Backend, Both)
4. **Frequency**: Always, intermittent, or one-time?
5. **Severity**: Blocking, degraded, cosmetic?
6. **Recent Changes**: Did this start after a specific deploy or code change?
7. **Evidence**: Logs, stack traces, screenshots, error codes?

If the user already provided this information in their message, extract it — don't re-ask what's already known.

### 1.2: Scope Detection

Based on the symptoms and affected areas, detect scope:

| Signal | Scope |
|--------|-------|
| iOS crash, UI glitch, Swift error | `SCOPE_IOS` |
| API error, 500, backend log | `SCOPE_BACKEND` |
| Infrastructure, deploy, config | `SCOPE_GCP_INFRA` |
| "It works on iOS but the API returns wrong data" | `SCOPE_IOS` + `SCOPE_BACKEND` |

### 1.3: Reproduce the Bug

Based on scope, attempt reproduction:

**Backend bugs**:
```bash
# Check recent logs for the error
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="<YOUR_SERVICE_NAME>" AND severity>=ERROR' \
  --limit=50 --format='table(timestamp,textPayload,jsonPayload.message)'

# Start local server and reproduce
dotnet run --project Infrastructure/<YOUR_API_PROJECT>/<YOUR_API_PROJECT>.GCP.csproj -- --urls http://localhost:7270

# Hit the affected endpoint
curl -v http://localhost:7270/{affected-endpoint}
```

**iOS bugs**:
```bash
# Build and check for compile-time issues
cd <YOUR_APP> && xcodebuild -project <YOUR_APP>.xcodeproj -scheme "<YOUR_APP> Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=latest' build 2>&1 \
  | python3 ../FULLSTACK_SCRIPTS/format-build-log.py

# Run existing tests to see if any already fail
cd <YOUR_APP> && xcodebuild test -project <YOUR_APP>.xcodeproj -scheme "<YOUR_APP> Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=latest' \
  -only-testing:<YOUR_APP>Tests/{RelevantTestClass} 2>&1 \
  | python3 ../FULLSTACK_SCRIPTS/format-build-log.py
```

**Cross-stack bugs**:
- Reproduce the backend component first (easier to isolate)
- Then verify the iOS client behavior matches expectations

### 1.4: Write a Reproduction Test (if possible)

Write a failing test that captures the bug. This becomes the regression test later.

```
A test that FAILS right now = proof the bug exists
A test that PASSES after the fix = proof the fix works
A test that STAYS PASSING forever = proof against regression
```

If a reproduction test isn't feasible (UI-only bug, timing issue), document why and describe the manual reproduction steps precisely.

### 1.5: Create GitHub Issue (Bug Report)

```bash
gh issue create \
  --title "bug: {concise bug description}" \
  --label "bug" \
  --body "$(cat <<'EOF'
## Bug Report

### Symptoms
{what the user observed}

### Reproduction Steps
1. {step 1}
2. {step 2}
3. {step 3}

### Expected Behavior
{what should happen}

### Actual Behavior
{what actually happens}

### Environment
- **Scope**: {iOS / Backend / Full-Stack}
- **Environment**: {dev / staging / prod}
- **Frequency**: {always / intermittent / one-time}
- **Severity**: {blocking / degraded / cosmetic}

### Evidence
{logs, stack traces, screenshots — inline or linked}

### Reproduction Test
{path to failing test, or "Manual reproduction only — see steps above"}

### Suspected Area
{files/components that likely contain the bug, based on initial triage}

---
*Bug triaged by Claude Code bug-to-pr pipeline*
EOF
)"
```

**Capture**:
- `ISSUE_URL` — the published GitHub issue URL
- `ISSUE_NUMBER` — the issue number
- `BUG_SLUG` — derived from the bug description (e.g., `websocket-disconnect-on-token-refresh`)
- Detected scope: `SCOPE_IOS`, `SCOPE_BACKEND`, `SCOPE_GCP_INFRA`

**Gate**: Bug must be reproducible (test or manual steps) before proceeding. If it can't be reproduced, use AskUserQuestion to get more information from the user. Don't proceed to root cause analysis on a bug you can't reproduce.

---

## Stage 2: Root Cause Analysis

**Owned by**: this skill (bug-to-pr)

Systematic investigation to find the actual root cause. Not guessing — following evidence.

### 2.1: Trace the Execution Path

Starting from the reproduction, trace the code path that triggers the bug:

1. **Entry point**: What user action or API call starts the flow?
2. **Call chain**: Follow the code path from entry to failure point
3. **State at failure**: What is the state of the system when the bug manifests?
4. **Expected vs actual**: Where does the actual behavior diverge from expected?

Use `Read`, `Grep`, and `Glob` to follow the code. Use `git log --oneline -20 -- {affected-file}` to check recent changes.

### 2.2: Form Hypotheses

Based on the trace, form 1-3 hypotheses about the root cause:

```markdown
## Root Cause Hypotheses

### Hypothesis 1 (Primary): {description}
- **Evidence for**: {what supports this}
- **Evidence against**: {what contradicts this}
- **Confidence**: High/Medium/Low
- **Test**: {how to confirm or reject this hypothesis}

### Hypothesis 2 (Alternative): {description}
- **Evidence for**: {what supports this}
- **Evidence against**: {what contradicts this}
- **Confidence**: High/Medium/Low
- **Test**: {how to confirm or reject this hypothesis}
```

### 2.3: Confirm Root Cause

Test each hypothesis systematically. Prefer the simplest explanation that accounts for all evidence. A root cause is confirmed when:

1. It explains ALL observed symptoms
2. It explains WHY the bug didn't exist before (if it's a regression)
3. Fixing it (mentally or via prototype) would resolve the reproduction case
4. No simpler explanation exists

### 2.4: Write the Fix Plan

Create a spec folder and fix plan:

```
agent-os/specs/{YYYY-MM-DD-HHMM-bug-slug}/
  ├── fix-plan.md
  └── counsel-log.md (created in Stage 3)
```

The fix plan must contain:

```markdown
# Fix Plan — {Bug Description}

**Bug Report**: {ISSUE_URL}
**Root Cause**: {confirmed root cause description}
**Confidence**: High/Medium/Low

## Root Cause Analysis

{Detailed explanation of the root cause, with code references and evidence}

### Execution Path
1. {step 1 — what happens}
2. {step 2 — where it diverges}
3. {step 3 — how the bug manifests}

### Why This Wasn't Caught
{Why existing tests/code didn't prevent this}

## Proposed Fix

### Changes Required

| File | Change Type | Description |
|------|-------------|-------------|
| {file path} | MODIFY | {what changes and why} |

### What NOT to Change
{Explicitly call out nearby code that should NOT be touched — minimize blast radius}

## Regression Prevention

### Tests to Add
1. {Test 1}: {what it covers — must include the original reproduction case}
2. {Test 2}: {what it covers — edge cases around the fix}

### Tests to Verify (Existing)
1. {Existing test}: {why it should still pass}

## Blast Radius

| Component | Impact | Verification |
|-----------|--------|-------------|
| {component} | {how it's affected} | {how to verify it's fine} |

## Rollback Plan
{How to revert if the fix causes issues — usually "revert the commit"}
```

**Capture**:
- `SPEC_FOLDER` — path to spec folder
- `PLAN_PATH` — `{SPEC_FOLDER}/fix-plan.md`

**Gate**: Fix plan must exist with a confirmed root cause before proceeding.

---

## Stage 3: Fix Strategy Counsel

**Owned by**: this skill (bug-to-pr)

Before implementing the fix, the plan undergoes adversarial review. For bugs, the counsel focuses on root cause validation, regression risk, and fix minimality rather than feature coverage.

### Counsel Architecture

| Role | Agent | Focus |
|------|-------|-------|
| **Reviewer A** | Claude Code subagent (Opus 4.6) | Root cause validation — is the diagnosis correct? Does the fix address the cause, not the symptom? |
| **Reviewer B** | Codex (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox`) | Regression risk — what's the blast radius? What else could this fix break? Is test coverage sufficient? |
| **Reviewer C** | Codex 5.4 extra high (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox --model codex-5.4 --reasoning-effort extra-high`) | Deep reasoning — hidden failure modes, deeper systemic issues, edge cases the fix might miss. Orchestrator's discretion on focus area. |
| **Orchestrator** | Main session (you) | Curious, quality-obsessed, tie-breaker. May dispatch additional Codex 5.4 extra high agents if a domain warrants deeper analysis. |

### Communication Protocol

The counsel communicates via a shared discussion log at `{SPEC_FOLDER}/counsel-log.md`. This creates a permanent, auditable record of the review discussion.

See `reference/counsel-protocol.md` for the full discussion log format.

### Process

#### 3.1: Initialize Discussion Log

Write the initial counsel-log.md:

```markdown
# Fix Strategy Counsel — {Bug Name}

**Bug Report**: {ISSUE_URL}
**Fix Plan**: {PLAN_PATH}
**Date**: {current date/time}

---

## Round 1: Initial Reviews

### Reviewer A (Root Cause Validation)

_Pending..._

### Reviewer B (Regression Risk)

_Pending..._

### Reviewer C (Codex 5.4 Extra High — Deep Reasoning)

_Pending..._

---

## Round 2: Orchestrator Synthesis

_Pending..._

## Refined Fix Amendments

_Pending..._

## Final Verdict

_Pending..._
```

#### 3.2: Spawn Reviewer A (Opus 4.6 Subagent)

Launch a Claude Code subagent at Opus 4.6 with this prompt:

```
You are Reviewer A on a fix strategy counsel. Your lens is ROOT CAUSE VALIDATION.

Bug Report (source of truth): {ISSUE_URL}
Fix Plan under review: Read {PLAN_PATH}
Tech Stack context: Read CLAUDE.md for full stack details (iOS Swift 6/SwiftUI, .NET 8 Cloud Run, PostgreSQL, Firebase Auth)

Your job:
1. Read the bug report from the GitHub issue (use `gh issue view {ISSUE_NUMBER}`)
2. Read the fix plan at {PLAN_PATH}
3. Read CLAUDE.md for tech stack context
4. READ THE ACTUAL CODE referenced in the fix plan — don't trust descriptions, verify against source
5. Evaluate the fix plan against these criteria:
   a. Is the diagnosed root cause correct? Follow the code path yourself and verify.
   b. Does the proposed fix address the ROOT CAUSE or just a SYMPTOM?
   c. Could there be a deeper cause that the diagnosis missed?
   d. Is the fix minimal? Are there any changes that aren't strictly necessary?
   e. Does the fix follow CLAUDE.md patterns (config-driven AI, .Select() projections, @Observable, etc.)?
   f. Are the proposed regression tests sufficient to catch this specific bug?

Write your findings to: {SPEC_FOLDER}/counsel-log.md
Replace the "Reviewer A" section with your structured critique.

Format each finding as:
- [ISSUE] — {description} — {rationale} — {suggested fix}
- [ROOT CAUSE CHALLENGE] — {description} — {evidence for/against} — {alternative hypothesis}
- [SCOPE CREEP] — {description} — {why this change isn't necessary for the fix}
- [APPROVAL] — {what looks good} — {why}

Be thorough but concise. The #1 risk in bug fixes is misdiagnosis. Verify everything.
```

#### 3.3: Run Reviewer B (Codex)

After Reviewer A completes, run Codex for the regression risk review:

```bash
# Write the Codex prompt to a temp file
cat > /tmp/counsel-reviewer-b-prompt.md << 'PROMPT_EOF'
You are Reviewer B on a fix strategy counsel. Your lens is REGRESSION RISK.

Bug Report: {ISSUE_URL}
Fix Plan: Read {PLAN_PATH}

Your job:
1. Read the bug report (use `gh issue view {ISSUE_NUMBER}`)
2. Read the fix plan at {PLAN_PATH}
3. For EVERY file listed in "Changes Required", find all consumers/callers:
   - Who calls this function?
   - Who imports this module?
   - What tests cover this code path?
4. Evaluate the fix plan against these criteria:
   a. What is the blast radius? Map every file that could be affected by this change.
   b. Are there callers/consumers of the changed code that aren't accounted for?
   c. Could this fix introduce a NEW bug in an adjacent code path?
   d. Is the test coverage sufficient? Are there gaps in the blast radius?
   e. Is the rollback plan realistic?
   f. Are there race conditions, ordering dependencies, or state issues the fix might trigger?

5. Read the current Reviewer A findings from {SPEC_FOLDER}/counsel-log.md
6. Append your findings to counsel-log.md under the "Reviewer B" section.

Format each finding as:
- [REGRESSION RISK] — {description} — {affected area} — {probability} — {mitigation}
- [BLAST RADIUS] — {file} — {consumers} — {risk level}
- [TEST GAP] — {description} — {what's not covered} — {suggested test}
- [DISAGREE with Reviewer A] — {which finding} — {why you disagree} — {your alternative}
- [APPROVAL] — {what looks good} — {why}

Be paranoid. The most dangerous bug fixes are the ones that create new bugs.
PROMPT_EOF

# Launch Codex
codex exec \
  --full-auto \
  --dangerously-bypass-approvals-and-sandbox \
  -o /tmp/counsel-reviewer-b-result.md \
  "$(cat /tmp/counsel-reviewer-b-prompt.md)"
```

#### 3.4: Run Reviewer C (Codex 5.4 Extra High)

After Reviewers A and B complete, run the Codex 5.4 extra high reasoning agent. The orchestrator chooses the focus area based on what A and B surfaced.

```bash
# Write the Codex 5.4 prompt to a temp file
cat > /tmp/counsel-reviewer-c-prompt.md << 'PROMPT_EOF'
You are Reviewer C on a fix strategy counsel. You are the DEEP REASONING reviewer.
Your lens is chosen by the orchestrator based on what previous reviewers surfaced.

FOCUS AREA: {ORCHESTRATOR_CHOSEN_FOCUS — e.g., "is there a deeper systemic issue?", "concurrency edge cases around the fix", "data consistency after the fix"}

Bug Report: {ISSUE_URL}
Fix Plan: Read {PLAN_PATH}

Your job:
1. Read the bug report (use `gh issue view {ISSUE_NUMBER}`)
2. Read the fix plan at {PLAN_PATH}
3. Read the findings from Reviewer A and Reviewer B in {SPEC_FOLDER}/counsel-log.md
4. Apply DEEP reasoning to your focus area. Think step by step. Consider:
   a. Is the diagnosed root cause actually a symptom of something deeper?
   b. Could this bug recur in a different form if only the surface is fixed?
   c. Are there related code paths with the same latent bug?
   d. What happens under concurrent access, partial failure, or edge-case input?
   e. Does the fix hold under all environments (dev, staging, prod)?
   f. What are the second-order effects on the broader system?

5. Append your findings to counsel-log.md under the "Reviewer C" section.

Format each finding as:
- [DEEPER ROOT CAUSE] — {description} — {what A/B diagnosed} — {what's actually underneath} — {implication for fix}
- [RISK] — {description} — {probability: low/medium/high} — {impact: low/medium/high} — {mitigation}
- [RELATED BUG] — {description} — {where the same pattern exists} — {whether to fix now or file follow-up}
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

**Orchestrator discretion**: The orchestrator may spawn additional Codex 5.4 extra high agents if a specific domain (e.g., concurrency safety, auth flow integrity, data migration risk) warrants independent deep analysis. Each additional agent gets a narrowed focus and writes to the counsel-log under its own section.

#### 3.5: Orchestrator Synthesis

After all three reviewers complete, the orchestrator (main session — you) reads the full counsel-log.md and synthesizes:

**Orchestrator Personality**:
> You are the quality champion. For bugs, you are especially paranoid — the cost of a wrong diagnosis is high (wasted implementation that doesn't fix the bug, or worse, introduces new bugs). Challenge every assumption. Demand evidence. But when the evidence is clear, move decisively.

**Synthesis Process**:
1. Read the full counsel-log.md
2. **Root cause verdict**: Is the diagnosed root cause correct? If reviewers challenged it, evaluate the evidence.
3. For each finding:
   - **Agreements**: Strong signal. Accept and incorporate.
   - **Conflicts**: Weigh both sides. Make the call. Document rationale.
   - **Gaps**: Ask "why?" about every non-obvious decision. Look for what's missing.
4. Write the "Orchestrator Synthesis" section in counsel-log.md
5. Write the "Refined Fix Amendments" section — specific changes to fix-plan.md with rationale
6. Apply the amendments to fix-plan.md
7. Write the "Final Verdict":
   - **APPROVED** — proceed to Stage 4
   - **REQUIRES REWORK** — send specific feedback, loop (max 2 iterations)
   - **ROOT CAUSE REJECTED** — go back to Stage 2 with new direction

**Use AskUserQuestion** to present the verdict and any significant amendments for user confirmation before proceeding.

---

## Stage 4: Targeted Implementation

**Owned by**: this skill (bug-to-pr)

Implementation for bug fixes follows the same multi-agent pattern as features but with tighter constraints: minimal changes, maximal testing, and explicit regression prevention.

### 4.1: Create Feature Branch

```bash
git checkout -b fix/{BUG_SLUG}
```

### 4.2: Determine Agent Roster

Bug fixes typically need fewer agents:

| Scope Detected | Agent to Spawn |
|---------------|----------------|
| `SCOPE_IOS` only | `ios-engineer` + `test-engineer` |
| `SCOPE_BACKEND` only | `backend-engineer` + `test-engineer` |
| `SCOPE_GCP_INFRA` only | `infra-engineer` + `test-engineer` |
| Multi-scope (2+) | All relevant engineers + `test-engineer` + `integration-engineer` |

### 4.3: Build File Ownership Matrix

Read the refined fix-plan.md and extract all files to be modified. Assign each file to exactly one agent.

**Bug fix constraint**: The file ownership matrix should be SMALL. If you're touching more than ~8 files, question whether the fix is truly minimal. A large blast radius for a bug fix is a code smell.

### 4.4: Create Task Dependency Graph

Bug fix waves are typically simpler:

```
Wave 1 (sequential — the fix):
  - Write the regression test FIRST (it should FAIL) — test-engineer
  - Apply the minimal code fix — {scope}-engineer
  - Verify regression test now PASSES — test-engineer

Wave 2 (parallel — blast radius verification):
  - Run all existing tests in affected area — test-engineer
  - Add blast radius tests if gaps found — test-engineer

Wave 3 (sequential — verification):
  - Backend build gate (team-lead)
  - iOS build gate (team-lead, if applicable)
  - Full test suite pass (team-lead)
```

**Critical**: The regression test is written BEFORE the fix. This is non-negotiable. Test-Driven Bug Fixing:
1. Write a test that reproduces the bug (it fails)
2. Apply the fix (test passes)
3. Verify no other tests broke

### 4.5: Create Team and Spawn Agents

```
Use TeamCreate tool:
  name: fix-{bug-slug}
  members: [list of agents from 4.2]
```

Then spawn each agent with a detailed prompt:

```
Use Agent tool for each member:
  model: opus
  team_name: fix-{bug-slug}
  name: {agent-name}
  prompt: |
    You are `{role}-engineer` on the `fix-{bug-slug}` team.

    Bug Report: {ISSUE_URL}
    Fix Plan: {PLAN_PATH}

    YOUR FILES (you own these exclusively — no other agent touches them):
    {file ownership list from 4.3}

    YOUR TASKS:
    {task list with IDs and blockedBy dependencies from 4.4}

    Build verification after each task:
    {scope-specific build commands from CLAUDE.md}

    Rules — BUG FIX SPECIFIC:
    - MINIMAL CHANGES ONLY — do not refactor, clean up, or "improve" adjacent code
    - Write regression test BEFORE the fix (test must fail first, then pass after fix)
    - Verify your changes build before marking tasks complete
    - Use TaskUpdate to mark tasks completed
    - Use SendMessage to team-lead if blocked
    - Follow existing patterns in the codebase — read before writing
    - If you discover the root cause is different from the fix plan, STOP and SendMessage to team-lead
```

### 4.6: Monitor and Gate

1. Monitor task completion via TaskList/TaskGet
2. **Critical check after Wave 1**: The regression test must:
   - FAIL without the fix (verify by temporarily reverting)
   - PASS with the fix
3. After all waves complete, run full verification:

```bash
# Backend
cd Infrastructure/<YOUR_API_PROJECT> && dotnet build <YOUR_API_PROJECT>.GCP.csproj
cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"

# iOS (if applicable)
cd <YOUR_APP> && xcodebuild -project <YOUR_APP>.xcodeproj -scheme "<YOUR_APP> Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=latest' build

# Run ALL tests, not just new ones — bug fixes must not break anything
cd <YOUR_APP> && xcodebuild test -project <YOUR_APP>.xcodeproj -scheme "<YOUR_APP> Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=latest' 2>&1 \
  | python3 ../FULLSTACK_SCRIPTS/format-build-log.py
```

4. **Gate**: ALL builds AND ALL tests must pass before proceeding to Stage 5.
5. If builds/tests fail: identify the issue, send fix instructions via SendMessage, re-verify.

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

3. **Bug fix constraint**: The simplifier should only simplify the NEW code (the fix and tests). It should NOT refactor surrounding code. If the simplifier suggests changes outside the fix scope, reject them.

4. After simplification completes, re-run builds to verify nothing broke:
   ```bash
   cd Infrastructure/<YOUR_API_PROJECT> && dotnet build <YOUR_API_PROJECT>.GCP.csproj
   cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"
   ```

5. If builds pass, commit the simplification changes:
   ```bash
   git add -A && git commit -m "refactor: simplify fix implementation

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
   ```

6. **Gate**: builds must pass after simplification before proceeding.

---

## Stage 6: Create PR + Codex Review

### 6.1: Create Pull Request

```bash
gh pr create \
  --title "fix: {concise bug description}" \
  --body "$(cat <<'EOF'
## Summary

{1-3 bullet points summarizing the fix}

## Root Cause

{Brief description of the root cause — what was wrong and why}

## Fix

{What was changed to resolve the root cause}

## Bug Report

Fixes #{ISSUE_NUMBER}

## Counsel Review

Fix strategy counsel: {SPEC_FOLDER}/counsel-log.md

## Regression Prevention

- {Regression test 1 — what it covers}
- {Regression test 2 — what it covers}

## Blast Radius

{List of components verified to be unaffected}

## Test Plan

- [ ] Regression test passes (was failing before fix)
- [ ] All existing tests pass
- [ ] Backend build passes
- [ ] Backend tests pass
- [ ] iOS build passes (if applicable)
- [ ] iOS tests pass (if applicable)
- [ ] No new failure modes introduced

🤖 Generated with [Claude Code](https://claude.com/claude-code) bug-to-pr pipeline
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

**Owned by**: this skill (bug-to-pr)

After the Codex adversarial review completes and pushes its fixes, check whether GitHub Copilot has left any feedback on the PR.

### 7.1: Wait for Copilot Review

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

**Bug fix caution**: Be more conservative here than in feature PRs. If a Copilot suggestion changes code outside the fix's blast radius, think twice — it could introduce its own regression.

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

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
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

**Bug fix note**: After deploy to each environment, verify the original reproduction case no longer occurs. This is the ultimate proof the fix works.

**Gate**: The PR must have all CI checks passing before self-healing-deploy will merge it.

---

## Pipeline State Tracking

Track pipeline progress using output to the user at each stage transition:

```
Pipeline: Bug-to-PR for {Bug Name}

  [✓] Stage 1: Bug Triaged — {ISSUE_URL}, reproduced: yes
  [✓] Stage 2: Root Cause Found — {root cause summary}, confidence: High
  [✓] Stage 3: Counsel Approved — 1 risk mitigated, root cause validated (3 reviewers)
  [→] Stage 4: Implementation — Wave 1/3, regression test written
  [ ] Stage 5: Simplification
  [ ] Stage 6: PR + Codex Review
  [ ] Stage 7: Copilot Feedback Review
  [ ] Stage 8: Self-Healing Deploy (dev → staging → prod)
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Bug can't be reproduced | Use AskUserQuestion for more details; if still unreproducible after 2 rounds, document as "unable to reproduce" and ask user to proceed or close |
| Root cause uncertain after Stage 2 | Document competing hypotheses in fix plan; counsel will evaluate in Stage 3 |
| Counsel rejects root cause | Go back to Stage 2 with reviewer feedback; max 2 iterations |
| Codex 5.4 extra high times out | Proceed with Reviewer A + B findings only; note the gap in counsel-log |
| Regression test can't be written | Document manual reproduction steps; add a comment in code explaining the untestable scenario |
| Fix introduces new test failures | Revert fix, re-analyze — the root cause diagnosis may be wrong |
| Agent discovers different root cause during implementation | STOP implementation, go back to Stage 2, update fix plan |
| Simplification breaks tests | Revert simplification commit, re-run /simplify with tighter scope |
| Codex review finds critical issues | Codex orchestrator fixes autonomously |
| Codex hangs or times out | Fall back to Generate mode, output prompt for manual review |
| Copilot never reviews the PR | Proceed after ~2 min wait; log "No Copilot feedback received" |
| Copilot fixes break builds | Revert the Copilot-fix commit, skip that suggestion, re-verify |
| Self-healing deploy fails in dev/staging | Self-healing loop auto-fixes (up to 5 attempts) |
| Self-healing deploy fails in prod | Pipeline stops and presents options to user (rollback, investigate, rerun) |
| Fix works in dev but not staging/prod | Likely env-specific issue — check config, secrets, data differences between environments |

---

## Tips

**Run the Checklist**: Like a pre-flight checklist, every stage runs every time. A pilot doesn't skip the engine check because "this is a short flight." You don't skip counsel because "this is an obvious bug."

**Reproduction Is Non-Negotiable**: If you can't reproduce it, you can't fix it with confidence. And you definitely can't write a regression test for it.

**Regression Test First**: Write the failing test BEFORE the fix. This proves the bug exists, proves the fix works, and prevents regression forever.

**Minimal Fix, Maximal Testing**: The fix itself should be surgical — change as little as possible. But the testing should be expansive — verify everything in the blast radius.

**Wrong Diagnosis Is Worse Than No Fix**: A fix based on the wrong root cause is actively dangerous — it gives false confidence while the real bug remains. When in doubt, go back to Stage 2.

**Context Compaction Is Not a Shortcut**: If the context window compresses mid-pipeline, pick up from the next incomplete stage. Never use compaction as justification to skip remaining stages.

---

**Remember**: This skill orchestrates the full bug-fix pipeline. ALL 8 STAGES ARE MANDATORY. It delegates to specialized skills for each stage but maintains control throughout. The pipeline is: Triage → Diagnose → Counsel → Fix → Simplify → Codex Review → Copilot Feedback → Deploy → Done.
