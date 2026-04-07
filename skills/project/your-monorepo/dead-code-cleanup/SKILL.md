---
name: dead-code-cleanup
description: Safely find and remove dead code from Swift files using an isolated git worktree. Creates a branch, runs analysis with build verification, and generates a report for review before merge.
---

# Dead Code Cleanup Skill

Safely removes dead code from Swift files using git worktree isolation.

## What This Does

1. Creates an isolated git worktree OUTSIDE the main repo (avoids IDE indexer conflicts)
2. Spawns a Dead Code Agent to scan and remove dead code
3. Verifies with builds after each removal
4. Generates a comprehensive report
5. Presents results for your review and merge decision

## Usage

```
/dead-code-cleanup [scope]
```

### Examples

```
/dead-code-cleanup                    # Full <YOUR_APP>/<YOUR_APP>/ directory
/dead-code-cleanup Features           # Only Features/ subdirectory
/dead-code-cleanup Core/Services      # Only Core/Services/
```

## What Gets Removed

| Category | Risk | Verification |
|----------|------|--------------|
| Unused imports | Low | Build only |
| Commented-out code blocks | Low | Build only |
| Unused private variables | Low | Build only |
| Unused private functions | Medium | Build + Test |
| Unreachable code | Medium | Build + Test |
| **Test-only functions** | High | Build + Test |
| Unused internal/public functions | High | Build + Test |

### Test-Only Functions

Functions that are ONLY called from test files (not production code) are dead code. The tests are testing dead code paths. Both the function and its tests should be removed.

## What Gets Skipped

- `@objc` functions (selector calls)
- Protocol conformance methods
- `Codable`/`Decodable` types
- `@IBAction`/`@IBOutlet` connections
- `override` functions
- View `body` properties (SwiftUI requirement)
- PreviewProvider structs (Xcode previews)

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Create Isolated Worktree                           │
│  - Location: ../.worktrees/dead-code-TIMESTAMP              │
│  - Branch: dead-code-cleanup-YYYYMMDD                       │
│  - OUTSIDE main repo to avoid Xcode indexer conflicts       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Run Dead Code Agent                                │
│  - Scans .swift files in scope                              │
│  - Distinguishes production vs test usage                   │
│  - Removes confirmed dead code                              │
│  - Verifies with builds                                     │
│  - Commits changes                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Report & Review                                    │
│  - Generates DEAD_CODE_REPORT.md                            │
│  - Shows summary of removals                                │
│  - User decides: merge / discard                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Cleanup                                            │
│  - Merge to main (if approved)                              │
│  - Remove worktree                                          │
│  - Delete branch                                            │
└─────────────────────────────────────────────────────────────┘
```

## After Completion

### To Merge
```bash
git checkout main
git merge dead-code-cleanup-YYYYMMDD
git worktree remove ../.worktrees/dead-code-TIMESTAMP
git branch -d dead-code-cleanup-YYYYMMDD
```

### To Discard
```bash
git worktree remove ../.worktrees/dead-code-TIMESTAMP --force
git branch -D dead-code-cleanup-YYYYMMDD
```

## Implementation Notes (for Claude)

When this skill is invoked:

### Step 1: Create Worktree
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
# Create worktree OUTSIDE the main repo to avoid IDE indexer confusion
WORKTREE_PATH="../.worktrees/dead-code-$TIMESTAMP"
BRANCH_NAME="dead-code-cleanup-$(date +%Y%m%d)"

# Ensure parent directory exists
mkdir -p ../.worktrees

# Create worktree from main
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" main
```

### Step 2: Spawn Agent
Use the Task tool with `subagent_type: general-purpose` and `model: haiku`.

Provide agent prompt from `.claude/agents./dead-code-agent.md` with:
- `{{WORKTREE_PATH}}` replaced with absolute path
- Scope parameter applied if provided

### Step 3: Handle Results
1. Read the generated `DEAD_CODE_REPORT.md`
2. Summarize findings to user
3. Ask: merge or discard?

### Step 4: Execute Decision
- Merge: `git checkout main && git merge $BRANCH_NAME`
- Cleanup: `git worktree remove $WORKTREE_PATH && git branch -d/-D $BRANCH_NAME`
