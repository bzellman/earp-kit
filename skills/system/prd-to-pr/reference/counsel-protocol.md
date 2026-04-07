# Plan Refinement Counsel — Communication Protocol

## Overview

The counsel is a lightweight adversarial review of the implementation plan before coding begins. Two reviewers with different perspectives critique the plan, then the orchestrator synthesizes and makes final decisions.

## Participants

| Role | Agent Type | Personality |
|------|-----------|-------------|
| **Reviewer A** | Claude Code subagent (Opus 4.6) | Meticulous architect. Cares deeply about tech stack alignment, pattern consistency, and requirement coverage. |
| **Reviewer B** | Codex (`codex exec --full-auto --dangerously-bypass-approvals-and-sandbox`) | Pragmatic implementer. Cares about feasibility, complexity cost, and whether the plan will actually work in practice. |
| **Orchestrator** | Main Claude Code session | Quality champion. Curious — always asks "why?". Fights for quality but makes decisive tie-breaking calls. |

## Discussion Log Format

The counsel communicates via a shared Markdown file at `{SPEC_FOLDER}/counsel-log.md`.

**Why a file instead of SendMessage?**
- Creates a permanent, auditable record
- Both Claude Code agents and Codex can read/write to it
- Survives session boundaries
- The orchestrator can review the full context before making decisions

### Template

```markdown
# Plan Refinement Counsel — {Feature Name}

**PRD**: {ISSUE_URL}
**Plan**: {PLAN_PATH}
**Date**: {YYYY-MM-DD HH:MM}
**Iteration**: 1 of 2 (max)

---

## Round 1: Initial Reviews

### Reviewer A (Tech Stack + Product Spec)

**Reviewed**: {timestamp}

#### Findings

1. [ISSUE] — {description}
   - **Rationale**: {why this matters}
   - **Suggested Fix**: {specific change to plan}

2. [SUGGESTION] — {description}
   - **Rationale**: {why this would improve the plan}

3. [APPROVAL] — {what looks good}
   - **Why**: {what makes this the right approach}

#### Coverage Matrix

| PRD Requirement | Plan Task | Status |
|----------------|-----------|--------|
| REQ-001: ... | Task 3 | Covered |
| REQ-002: ... | Task 5 | Covered |
| REQ-003: ... | _None_ | **MISSING** |

#### Summary
- Issues: {count}
- Suggestions: {count}
- Approvals: {count}
- Missing PRD coverage: {count}

---

### Reviewer B (Implementation Feasibility)

**Reviewed**: {timestamp}

#### Findings

1. [ISSUE] — {description}
   - **Rationale**: {why this matters}
   - **Suggested Fix**: {specific change to plan}

2. [DISAGREE with Reviewer A] — Re: finding #{number}
   - **Their position**: {what Reviewer A said}
   - **My position**: {why I disagree}
   - **My alternative**: {what I'd do instead}

3. [APPROVAL] — {what looks good}
   - **Why**: {what makes this feasible}

#### Feasibility Assessment

| Plan Task | Feasible? | Complexity | Notes |
|-----------|-----------|-----------|-------|
| Task 1 | Yes | Low | Straightforward migration |
| Task 2 | Risky | High | File ownership conflict with Task 5 |

#### Summary
- Issues: {count}
- Suggestions: {count}
- Disagreements with A: {count}
- Approvals: {count}

---

## Round 2: Orchestrator Synthesis

**Synthesized**: {timestamp}

### Agreements (Both Reviewers Align)

1. {Finding} — **Action**: {accept/incorporate}

### Conflicts (Reviewers Disagree)

1. **Topic**: {what they disagree about}
   - **Reviewer A**: {their position}
   - **Reviewer B**: {their position}
   - **Orchestrator Decision**: {which side, or a third option}
   - **Rationale**: {why this is the right call}

### Gaps (Neither Caught)

1. {What's missing} — **Action**: {add to plan}

### Curiosity Questions Resolved

1. **Why**: {question about a plan decision}
   - **Answer**: {rationale, confirmed or changed}

---

## Refined Plan Amendments

The following changes are applied to `plan.md`:

1. **Amendment 1**: {specific change}
   - **Source**: {which reviewer or orchestrator gap}
   - **Rationale**: {why}

2. **Amendment 2**: {specific change}
   - **Source**: {which reviewer or orchestrator gap}
   - **Rationale**: {why}

---

## Final Verdict

**APPROVED** / **REQUIRES REWORK**

**Confidence**: {High / Medium / Low}

**Conditions** (if any):
- {condition that must hold during implementation}

**Iteration**: {1 or 2} of 2 max
```

## Execution Rules

### Sequential Writes
Reviewers write sequentially to prevent file conflicts:
1. Reviewer A writes first (replaces "Pending..." under their section)
2. Reviewer B writes second (replaces "Pending..." under their section, can reference A's findings)
3. Orchestrator writes last (fills in synthesis, amendments, and verdict)

### Max Iterations
The counsel loops at most 2 times. If the plan still has issues after 2 iterations, the orchestrator must either:
- Accept the plan with documented risks
- Escalate to the user via AskUserQuestion

### Orchestrator Curiosity Mandate
The orchestrator MUST ask at least 3 "why?" questions about non-obvious decisions in the plan before writing the synthesis. Examples:
- "Why is Task 3 in Wave 2 instead of Wave 1?"
- "Why does the ios-engineer own `GCPAPIURLBuilder.swift` instead of backend-engineer?"
- "Why is there no explicit error handling task?"

### Disagreement Resolution
When reviewers disagree:
1. The orchestrator evaluates both positions on technical merit
2. Considers the project's existing patterns (CLAUDE.md is authoritative)
3. Makes a decisive call — no hedging, no "both are valid"
4. Documents the rationale clearly

### Minimum Quality Bar
The counsel MUST verify:
- [ ] Every PRD requirement (REQ-XXX) maps to at least one plan task
- [ ] File ownership matrix has zero overlaps
- [ ] Wave dependencies form a valid DAG (no circular dependencies)
- [ ] Build verification commands are included for every wave
- [ ] Tests are co-located with implementation (not deferred to a later wave)
