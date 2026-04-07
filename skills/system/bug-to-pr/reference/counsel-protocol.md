# Fix Strategy Counsel — Communication Protocol

## Overview

The counsel is a lightweight adversarial review of the proposed fix strategy before coding begins. Three reviewers with different perspectives critique the fix plan, then the orchestrator synthesizes and makes final decisions. For bugs, the counsel focuses on root cause validation, regression risk, and fix minimality.

## Participants

| Role | Agent Type | Personality |
|------|-----------|-------------|
| **Reviewer A** | Claude Code subagent (Opus 4.6) | Root cause detective. Cares deeply about whether the diagnosis is correct, whether the fix addresses the actual cause vs. a symptom, and whether the fix follows existing patterns. |
| **Reviewer B** | Codex (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox`) | Regression guardian. Cares about blast radius, what else the fix might break, and whether the test coverage is sufficient to prevent regressions. |
| **Reviewer C** | Codex 5.4 extra high (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox --model codex-5.4 --reasoning-effort extra-high`) | Deep reasoning reviewer. Focuses on hidden failure modes, edge cases, and whether the root cause analysis missed a deeper systemic issue. |
| **Orchestrator** | Main Claude Code session | Quality champion. Curious — always asks "why?". Fights for correctness but makes decisive tie-breaking calls. |

## Discussion Log Format

The counsel communicates via a shared Markdown file at `{SPEC_FOLDER}/counsel-log.md`.

**Why a file instead of SendMessage?**
- Creates a permanent, auditable record
- Both Claude Code agents and Codex can read/write to it
- Survives session boundaries
- The orchestrator can review the full context before making decisions

### Template

```markdown
# Fix Strategy Counsel — {Bug Name}

**Bug Report**: {ISSUE_URL}
**Fix Plan**: {PLAN_PATH}
**Date**: {YYYY-MM-DD HH:MM}
**Iteration**: 1 of 2 (max)

---

## Round 1: Initial Reviews

### Reviewer A (Root Cause Validation)

**Reviewed**: {timestamp}

#### Findings

1. [ISSUE] — {description}
   - **Rationale**: {why this matters}
   - **Suggested Fix**: {specific change to plan}

2. [ROOT CAUSE CHALLENGE] — {description}
   - **Evidence for**: {what supports the diagnosed root cause}
   - **Evidence against**: {what contradicts it or suggests an alternative}
   - **Alternative hypothesis**: {if any}

3. [APPROVAL] — {what looks good}
   - **Why**: {what makes this the right diagnosis/approach}

#### Root Cause Confidence

| Hypothesis | Evidence | Confidence |
|-----------|----------|------------|
| {diagnosed cause} | {evidence} | High/Medium/Low |
| {alternative cause} | {evidence} | High/Medium/Low |

#### Summary
- Issues: {count}
- Root cause challenges: {count}
- Approvals: {count}

---

### Reviewer B (Regression Risk)

**Reviewed**: {timestamp}

#### Findings

1. [REGRESSION RISK] — {description}
   - **Affected area**: {what could break}
   - **Probability**: High/Medium/Low
   - **Mitigation**: {how to prevent it}

2. [DISAGREE with Reviewer A] — Re: finding #{number}
   - **Their position**: {what Reviewer A said}
   - **My position**: {why I disagree}
   - **My alternative**: {what I'd do instead}

3. [APPROVAL] — {what looks good}
   - **Why**: {what makes this safe}

#### Blast Radius Assessment

| Changed File | Other Consumers | Risk | Test Coverage |
|-------------|----------------|------|---------------|
| {file} | {who else uses this} | High/Medium/Low | Covered/Gap |

#### Summary
- Regression risks: {count}
- Issues: {count}
- Disagreements with A: {count}
- Approvals: {count}

---

### Reviewer C (Codex 5.4 Extra High — Deep Reasoning)

**Reviewed**: {timestamp}

#### Findings

1. [RISK] — {description}
   - **Probability**: High/Medium/Low
   - **Impact**: High/Medium/Low
   - **Mitigation**: {how to prevent it}

2. [DEEPER ROOT CAUSE] — {description}
   - **What A/B diagnosed**: {their root cause}
   - **What I see underneath**: {deeper systemic issue}
   - **Implication for fix**: {how this changes the approach}

3. [AMPLIFY from Reviewer A/B] — {which finding}
   - **Additional context**: {what they missed}

#### Summary
- Risks: {count}
- Deeper root causes: {count}
- Approvals: {count}

---

## Round 2: Orchestrator Synthesis

**Synthesized**: {timestamp}

### Agreements (Reviewers Align)

1. {Finding} — **Action**: {accept/incorporate}

### Conflicts (Reviewers Disagree)

1. **Topic**: {what they disagree about}
   - **Reviewer A**: {their position}
   - **Reviewer B**: {their position}
   - **Reviewer C**: {their position, if relevant}
   - **Orchestrator Decision**: {which side, or a third option}
   - **Rationale**: {why this is the right call}

### Gaps (Nobody Caught)

1. {What's missing} — **Action**: {add to plan}

### Root Cause Verdict

- **Confirmed root cause**: {description}
- **Confidence**: High/Medium/Low
- **Supporting evidence**: {key evidence}
- **Rejected alternatives**: {and why}

---

## Refined Fix Amendments

The following changes are applied to the fix plan:

1. **Amendment 1**: {specific change}
   - **Source**: {which reviewer or orchestrator gap}
   - **Rationale**: {why}

2. **Amendment 2**: {specific change}
   - **Source**: {which reviewer or orchestrator gap}
   - **Rationale**: {why}

---

## Final Verdict

**APPROVED** / **REQUIRES REWORK**

**Root Cause Confidence**: {High / Medium / Low}

**Conditions** (if any):
- {condition that must hold during implementation}

**Required Regression Tests**:
- {test 1}
- {test 2}

**Iteration**: {1 or 2} of 2 max
```

## Execution Rules

### Sequential Writes
Reviewers write sequentially to prevent file conflicts:
1. Reviewer A writes first (replaces "Pending..." under their section)
2. Reviewer B writes second (replaces "Pending..." under their section, can reference A's findings)
3. Reviewer C writes third (replaces "Pending..." under their section, can reference A and B's findings)
4. Orchestrator writes last (fills in synthesis, amendments, and verdict)

### Max Iterations
The counsel loops at most 2 times. If the fix plan still has issues after 2 iterations, the orchestrator must either:
- Accept the plan with documented risks
- Escalate to the user via AskUserQuestion

### Orchestrator Curiosity Mandate
The orchestrator MUST ask at least 3 "why?" questions about non-obvious decisions in the fix plan before writing the synthesis. Examples:
- "Why do we believe this is the root cause and not X?"
- "Why is this file in the blast radius but not Y?"
- "Why isn't there a regression test for the original reproduction case?"

### Disagreement Resolution
When reviewers disagree:
1. The orchestrator evaluates both positions on technical merit
2. Considers the project's existing patterns (CLAUDE.md is authoritative)
3. Makes a decisive call — no hedging, no "both are valid"
4. Documents the rationale clearly

### Minimum Quality Bar for Bug Fixes
The counsel MUST verify:
- [ ] Root cause is supported by evidence (logs, code traces, reproduction), not just speculation
- [ ] The fix addresses the root cause, not just the symptom
- [ ] Fix is minimal — no scope creep, no "while we're here" refactoring
- [ ] Blast radius is mapped — every changed file's consumers are identified
- [ ] Regression test specifically covers the original reproduction case
- [ ] No new failure modes introduced by the fix
- [ ] Rollback path exists if the fix causes issues in production
