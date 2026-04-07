---
description: Complete PR workflow with self-review and documentation updates
---

# PR Flow - Complete Pull Request Workflow

Execute a complete, high-quality PR workflow with self-review and documentation updates.

## Phase 1: Checkpoint Confirmation

**This work represents an acceptable checkpoint.** The implementation:
- Solves the stated problem
- Follows existing patterns in the codebase
- Is testable and verifiable
- Does not introduce regressions

✅ **REINFORCEMENT**: Good direction confirmed. Proceeding with PR workflow.

## Phase 2: Documentation Updates

**Documentation Directory**: `~/Documentation/` (operate from here regardless of monorepo location)

**Priority Order**:
1. **Update existing `.md` files** - NEVER create new docs if existing ones can be extended
2. Keep directory structure flat - use subdirs only when absolutely necessary
3. Update in this order:
   - `CLAUDE.md` - Development instructions and patterns
   - `README.md` - Project overview and setup
   - `AGENTS.md` - Agent guidelines (if agents involved)
   - Feature-specific docs only if they already exist

**Documentation Checklist**:
- [ ] Check what docs exist: `ls -la ~/Documentation/*.md`
- [ ] Update relevant existing docs with new patterns/learnings
- [ ] Update CLAUDE.md if workflow changed
- [ ] Update README.md if setup/usage changed
- [ ] Do NOT create new .md files unless explicitly required

## Phase 3: Instruction Updates

Update project instruction files if the work introduced:
- New patterns or conventions
- New commands or workflows
- Changed architecture
- New dependencies or setup steps

Files to consider:
- `CLAUDE.md` - Main development instructions
- `.claude/README.md` - Claude Code configuration docs
- `README.md` - Project readme
- `AGENTS.md` - Repository guidelines

## Phase 4: Create Initial PR

```bash
# Check current state
git status
git diff --stat

# Stage and commit
git add -A
git commit -m "<type>: <description>

<detailed summary>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push and create PR
git push -u origin HEAD
gh pr create --title "<PR Title>" --body "$(cat <<'PRBODY'
## Summary
<1-3 bullet points describing what this PR does>

## Changes
<List of key changes>

## Testing
<How this was tested/verified>

## Documentation
- [ ] Updated existing docs (not created new ones)
- [ ] CLAUDE.md updated if patterns changed
- [ ] README.md updated if setup changed

🤖 Generated with [Claude Code](https://claude.com/claude-code)
PRBODY
)"
```

## Phase 5: Self-Review as Senior Engineer

**Adopt this persona for review:**

> You are a **Senior Staff Engineer** with 15+ years of experience. You value:
> - **Clarity over cleverness** - Code should be obvious, not impressive
> - **Simplicity over flexibility** - Solve today's problem, not tomorrow's maybe-problem
> - **Readability over brevity** - A few extra lines for clarity is always worth it
> - **Consistency over perfection** - Match existing patterns even if you'd do it differently
> - **Pragmatism over dogma** - Rules exist to serve the code, not the other way around

**Review Criteria** (in priority order):

### 1. Correctness
- Does it actually solve the stated problem?
- Are there edge cases not handled?
- Could this break existing functionality?

### 2. Readability
- Can a new team member understand this in 5 minutes?
- Are variable/function names self-documenting?
- Is the logic flow obvious without comments?

### 3. Simplicity
- Is there any code that could be removed?
- Are there abstractions that aren't earning their keep?
- Is this the simplest solution that works?

### 4. Consistency
- Does it match existing patterns in the codebase?
- Are naming conventions followed?
- Does the structure match similar features?

### 5. Scalability (only if relevant)
- Will this perform acceptably at 10x scale?
- Are there obvious bottlenecks?
- Is resource cleanup handled?

**Review Process**:
```bash
# Get the PR diff
gh pr diff

# Review each file changed
# For each issue found, fix it immediately
# Re-run tests after fixes
```

**After each fix, ask:**
- "Is this change necessary or am I gold-plating?"
- "Does this match how we do things elsewhere?"
- "Would I be embarrassed if a senior engineer saw this?"

## Phase 6: Address Feedback & Iterate

For each issue identified in self-review:
1. Fix the issue
2. Verify the fix doesn't break anything
3. Commit with clear message explaining the fix

```bash
# After fixes
git add -A
git commit -m "address review: <what was fixed>"
git push
```

**Continue until the Senior Engineer persona says:**
> "This PR is clean, focused, and ready for human review. Ship it."

## Phase 7: Final PR Update & Assign Reviewer

```bash
# Update PR with final summary
gh pr edit --body "$(cat <<'PRBODY'
## Summary
<Final summary after self-review>

## Changes
<Updated list of changes>

## Self-Review Complete
- [x] Correctness verified
- [x] Readability optimized
- [x] Simplicity confirmed
- [x] Consistency with codebase
- [x] No unnecessary complexity

## Testing
<How this was tested>

## Documentation
- [x] Updated existing docs
- [x] No new doc files created unnecessarily

🤖 Generated with [Claude Code](https://claude.com/claude-code)
PRBODY
)"

# Assign reviewer
gh pr edit --add-reviewer bzellman

# Output PR URL
gh pr view --web
```

## Execution

Run this workflow now for: $ARGUMENTS

**Start by confirming the checkpoint, then proceed through each phase.**
