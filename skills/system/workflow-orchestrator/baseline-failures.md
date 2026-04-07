# RED Phase: Baseline Failure Analysis

## Scenario: User asks to run 3 workflows simultaneously without orchestrator skill

Work items:
1. PRD: "Add user profile sharing" (prd-to-pr)
2. Bug: "Auth token race condition on cold start" (bug-to-pr)
3. PRD: "Notification system for memory reactions" (prd-to-pr)

## Predicted Baseline Failures (Without Skill)

### F1: Branch Contamination
**What happens:** Agent works on main branch, mixing changes from all 3 workflows. Or creates branches but doesn't use worktrees, switching between them and losing context.
**Rationalization:** "I'll keep track of which changes belong to which workflow."
**Impact:** Merge conflicts, mixed commits, impossible to isolate or revert individual workflows.

### F2: Sequential Execution Disguised as Parallel
**What happens:** Agent runs workflow 1 to completion, then workflow 2, then workflow 3. Claims "parallel" but actually serial.
**Rationalization:** "I need to finish one before starting the next to avoid conflicts."
**Impact:** 3x longer total time. Defeats the purpose of orchestration.

### F3: Stage Skipping Under Context Pressure
**What happens:** As context window fills with 3 workflows' worth of artifacts (counsel logs, plans, build output), agent starts skipping "obvious" stages. Counsel gets abbreviated. Copilot review gets skipped. Simplification pass disappears.
**Rationalization:** "This bug fix is simple enough to skip counsel." / "Context is getting long, I'll skip the Copilot review step." / "Simplification isn't needed for this small change."
**Impact:** Quality degradation. The whole point of the 8-stage pipeline is that EVERY stage catches something.

### F4: Gate Stalling (Silent Death)
**What happens:** Workflow 2 hits Stage 3 counsel and needs user input. But agent is deep in Workflow 1's implementation. Gate sits unattended for the entire duration of Workflow 1. User has no idea.
**Rationalization:** "I'll get back to that after I finish this task."
**Impact:** Massive time waste. Workflow sits idle when it could be progressing.

### F5: Lost Observability
**What happens:** With 3 workflows in flight, agent loses track of which workflow is at which stage. No dashboard. No status updates. User asks "how's it going?" and gets a vague "making progress."
**Rationalization:** "I know where everything is." (Agent doesn't.)
**Impact:** User has zero visibility. Can't make informed decisions about priorities.

### F6: Decision Bottleneck
**What happens:** Every gate decision gets escalated to user. 3 workflows × 8 stages × multiple gates = constant interruption. User drowns in "should I approve this?" messages.
**Rationalization:** "The user should make all decisions."
**Impact:** User fatigue. Defeats autonomy. Simple decisions that the orchestrator could handle clog the pipeline.

### F7: No Cross-Workflow Coordination
**What happens:** Workflows 1 and 3 both try to modify `GCPStartup.cs`. Both reach Stage 8 (deploy) simultaneously and create conflicting CI runs. No one detects the shared file conflict until merge time.
**Rationalization:** "Each workflow is independent."
**Impact:** Merge hell. Deploy conflicts. Possible production issues.

### F8: Context Pollution
**What happens:** Agent's context fills with Workflow 1's counsel log, Workflow 2's stack traces, Workflow 3's build output. Can't think clearly about any single workflow.
**Rationalization:** "I need all this context to coordinate."
**Impact:** Degraded quality across all workflows. Agent makes errors because it's juggling too much.

### F9: Workflow Agent Can't Resume After Context Compression
**What happens:** A background workflow agent's context gets compressed mid-pipeline. It loses track of what stage it's on, what artifacts were produced, and what gates were passed. Starts over or skips ahead randomly.
**Rationalization:** "I think I was on Stage 5."
**Impact:** Duplicated work, skipped stages, or broken state.

### F10: Deploy Collision
**What happens:** Two workflows finish around the same time and both try to merge and deploy. CI runs conflict, or one deploy breaks the other's assumptions.
**Rationalization:** "They're independent, they can deploy in parallel."
**Impact:** Failed deploys, broken production, rollback chaos.

## Summary of Failure Categories

| Category | Failures | Root Cause |
|----------|----------|------------|
| Isolation | F1, F8 | No worktree management |
| Parallelism | F2 | No background agent dispatch |
| Discipline | F3, F9 | No stage enforcement mechanism |
| Responsiveness | F4, F6 | No gate detection/routing |
| Visibility | F5 | No dashboard/reporting |
| Coordination | F7, F10 | No cross-workflow awareness |
