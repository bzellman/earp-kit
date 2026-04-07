---
name: pr-handoff-to-codex
description: Use when a PR is ready for senior architect review and autonomous fix-up by Codex CLI. Uses adversarial counsel (3 specialized reviewers + 1 orchestrator) for comprehensive coverage. Gathers PR URL, GitHub issue URL, project standards, and build/test commands.
---

# PR Handoff to Codex — Adversarial Counsel Review

Hand off a PR to Codex CLI for adversarial review by 3 specialized reviewers + 1 orchestrator that synthesizes, fixes, and pushes until green.

**Core principle:** Three adversarial Codex agents review from different lenses (architecture, security, code quality), then an orchestrator Codex synthesizes findings, applies fixes, runs builds, and pushes — all autonomously.

## When to Use

- PR is created and pushed but needs senior review before merge
- You want Codex to autonomously apply fixes, run tests, and push updates
- The PR has a linked GitHub issue with requirements to verify against

## Quick Reference

| Input | Source |
|-------|--------|
| PR number | User provides or from `gh pr list` |
| GitHub issue | Linked in PR body or user provides |
| Standards | Auto-discovered from `agent-os/standards/` and `CLAUDE.md` |
| Build/test commands | From `CLAUDE.md` Quick Reference section |

## Adversarial Counsel Architecture

| Agent | Lens | Looks For | Standards Subset |
|-------|------|-----------|-----------------|
| `codex-arch` | Architecture | Pattern violations, over/under-engineering, config-driven compliance, API contract issues, separation of concerns | `backend/*.md`, `ios/*.md`, `api/*.md` |
| `codex-security` | Security | SQL injection, XSS, hardcoded secrets, auth bypass, PII exposure, input validation gaps, HTTPS enforcement | `gcp/*.md`, auth standards |
| `codex-quality` | Code Quality | Missing tests, error handling gaps, edge cases, dead code, naming violations, ContentVector projection | `testing/*.md`, code quality standards |
| `codex-orchestrator` | Synthesis + Fix | Deduplicates findings, resolves conflicts, prioritizes, applies ALL fixes, runs builds until green | ALL standards + ALL review outputs |

**All agents use**: `codex exec --dangerously-bypass-approvals-and-sandbox`

---

## Process

### Step 1: Gather PR Context

```bash
# Get PR metadata (title, branch, file list)
gh pr view {PR_NUMBER} --json title,body,headRefName,baseRefName,url,files

# Get linked issue number (parse from PR body or ask user)
# Just need the issue number — Codex will fetch the full content
```

### Step 2: Identify Relevant Standards

Based on files changed in the PR, select applicable standards from `agent-os/standards/`:

| Files touched | Standards to include |
|--------------|---------------------|
| `Infrastructure/<YOUR_API_PROJECT>/Controllers/` | `api/*.md`, `backend/*.md` |
| `Infrastructure/<YOUR_API_PROJECT>/Data/` | `database/*.md`, `backend/*.md` |
| `Infrastructure/<YOUR_API_PROJECT>/GCP/` | `gcp/*.md` |
| `Infrastructure/<YOUR_API_PROJECT>/Services/` | `backend/*.md`, `gcp/ai-configuration-centralization.md` |
| `<YOUR_APP>/<YOUR_APP>/Core/` | `ios/*.md` |
| `<YOUR_APP>/<YOUR_APP>/Features/` | `ios/*.md` |
| `*Tests*` | `testing/*.md` |
| Both iOS + Backend | `api/cross-stack-integration.md` |

Read each relevant standard file. Split standards into subsets for each reviewer (see architecture table above).

### Step 3: Determine Build/Test Commands

From `CLAUDE.md`, extract the appropriate commands based on scope:

**Backend:**

```bash
cd Infrastructure/<YOUR_API_PROJECT> && dotnet build
cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"
```

**iOS:**

```bash
cd <YOUR_APP> && xcodebuild -project <YOUR_APP>.xcodeproj -scheme <YOUR_APP> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' build
```

**Both:** Include all commands.

### Step 4: Generate Adversarial Review Prompts

Generate 3 narrowed reviewer prompts + 1 orchestrator prompt. Each reviewer gets only their lens-specific checklist and standards subset.

#### codex-arch Prompt Template

````markdown
# Architecture Review: {PR_TITLE}

## Mission

You are an architecture reviewer for PR #{PR_NUMBER} in the <YOUR_MONOREPO> project.

**Your lens: ARCHITECTURE ONLY.** Do not review for security or test coverage — other reviewers handle those.

**Your job:**
1. Read the PR diff and linked issue
2. Review ALL changes through your architecture lens
3. Write findings to `/tmp/codex-review-arch-{PR_NUMBER}.md`

**You are a reviewer, not a fixer.** Report findings only. The orchestrator will apply fixes.

## PR & Issue URLs

- **PR:** {PR_URL}
- **Issue:** {ISSUE_URL}

Start by reading both:
```bash
gh pr view {PR_NUMBER}
gh pr diff {PR_NUMBER}
gh issue view {ISSUE_NUMBER}
```

## PR Details

- **Branch:** `{HEAD_BRANCH}` -> `{BASE_BRANCH}`
- **Files changed:** {FILE_COUNT}

## Your Review Checklist

- [ ] Changes follow existing patterns in the codebase
- [ ] No unnecessary abstractions or over-engineering
- [ ] Proper separation of concerns (Controllers -> Services -> Data)
- [ ] Config-driven: no hardcoded AI models, prompts, or magic numbers
- [ ] API contract follows camelCase JSON, ISO 8601 dates, Bearer auth
- [ ] EF Core entities map correctly to snake_case PostgreSQL columns
- [ ] JSONB columns use `JsonDocument` with proper serialization
- [ ] New endpoints registered with proper route attributes
- [ ] DI registrations added in `GCPStartup.cs`
- [ ] `@Observable` with `@ObservationIgnored` for dependencies (iOS)
- [ ] SwiftUI views use `.frame(maxWidth: .infinity)` before height on Map (iOS)

## Relevant Standards

{ARCH_STANDARDS_CONTENT}

## Output Format

Write your findings to `/tmp/codex-review-arch-{PR_NUMBER}.md` in this format:

```markdown
# Architecture Review — PR #{PR_NUMBER}

## Critical Issues (must fix)
1. [file:line] — {description} — {fix suggestion}

## Important Issues (should fix)
1. [file:line] — {description} — {fix suggestion}

## Suggestions (nice to have)
1. [file:line] — {description}

## Approvals (what looks good)
1. {what's done well and why}
```
````

#### codex-security Prompt Template

````markdown
# Security Review: {PR_TITLE}

## Mission

You are a security reviewer for PR #{PR_NUMBER} in the <YOUR_MONOREPO> project.

**Your lens: SECURITY ONLY.** Do not review for architecture or test coverage — other reviewers handle those.

**Your job:**
1. Read the PR diff and linked issue
2. Review ALL changes through your security lens
3. Write findings to `/tmp/codex-review-security-{PR_NUMBER}.md`

**You are a reviewer, not a fixer.** Report findings only. The orchestrator will apply fixes.

## PR & Issue URLs

- **PR:** {PR_URL}
- **Issue:** {ISSUE_URL}

Start by reading both:
```bash
gh pr view {PR_NUMBER}
gh pr diff {PR_NUMBER}
gh issue view {ISSUE_NUMBER}
```

## Your Review Checklist

- [ ] No SQL injection vectors (parameterized queries only)
- [ ] No XSS vulnerabilities (output encoding)
- [ ] No hardcoded secrets or API keys
- [ ] No auth bypass possibilities (all endpoints check Bearer token)
- [ ] All inputs validated at system boundaries
- [ ] No PII exposure in logs or error responses
- [ ] HTTPS enforced for all external calls
- [ ] Firebase auth tokens validated properly
- [ ] No command injection in Bash/shell calls
- [ ] Secret Manager used for all sensitive configuration

## Relevant Standards

{SECURITY_STANDARDS_CONTENT}

## Output Format

Write your findings to `/tmp/codex-review-security-{PR_NUMBER}.md` in this format:

```markdown
# Security Review — PR #{PR_NUMBER}

## Critical Issues (must fix — security vulnerabilities)
1. [file:line] — {vulnerability type} — {description} — {fix}

## Important Issues (should fix — security hardening)
1. [file:line] — {description} — {fix suggestion}

## Suggestions
1. [file:line] — {description}

## Approvals (security-relevant code that looks correct)
1. {what's done well and why}
```
````

#### codex-quality Prompt Template

````markdown
# Code Quality Review: {PR_TITLE}

## Mission

You are a code quality reviewer for PR #{PR_NUMBER} in the <YOUR_MONOREPO> project.

**Your lens: CODE QUALITY + TESTING ONLY.** Do not review for architecture or security — other reviewers handle those.

**Your job:**
1. Read the PR diff and linked issue
2. Review ALL changes through your code quality lens
3. Write findings to `/tmp/codex-review-quality-{PR_NUMBER}.md`

**You are a reviewer, not a fixer.** Report findings only. The orchestrator will apply fixes.

## PR & Issue URLs

- **PR:** {PR_URL}
- **Issue:** {ISSUE_URL}

Start by reading both:
```bash
gh pr view {PR_NUMBER}
gh pr diff {PR_NUMBER}
gh issue view {ISSUE_NUMBER}
```

## Your Review Checklist

- [ ] New functionality has corresponding tests
- [ ] Tests verify behavior, not implementation details
- [ ] Edge cases covered (null, empty, boundary values)
- [ ] No test pollution (each test is independent)
- [ ] Error handling: all async calls have try/catch, meaningful error messages
- [ ] Database queries use `.Select()` projection (avoid ContentVector)
- [ ] No unused imports, dead code, or TODO comments left behind
- [ ] Lazy service init for heavy frameworks (iOS)
- [ ] Enums decode both integer (legacy) and string formats (iOS)
- [ ] Naming follows conventions (PascalCase .NET, camelCase Swift properties)

## Relevant Standards

{QUALITY_STANDARDS_CONTENT}

## Output Format

Write your findings to `/tmp/codex-review-quality-{PR_NUMBER}.md` in this format:

```markdown
# Code Quality Review — PR #{PR_NUMBER}

## Critical Issues (must fix — bugs or missing tests)
1. [file:line] — {description} — {fix suggestion}

## Important Issues (should fix — quality gaps)
1. [file:line] — {description} — {fix suggestion}

## Suggestions
1. [file:line] — {description}

## Test Coverage Assessment
- New public APIs covered: X/Y
- Edge cases covered: [list]
- Missing coverage: [list]

## Approvals (well-written code)
1. {what's done well and why}
```
````

#### codex-orchestrator Prompt Template

````markdown
# Synthesis & Fix: {PR_TITLE}

## Mission

You are the orchestrator for an adversarial review of PR #{PR_NUMBER} in the <YOUR_MONOREPO> project. Three specialized reviewers have independently analyzed this PR. Your job is to synthesize their findings and fix everything.

**Your job:**
1. Read all 3 review reports
2. Deduplicate findings (same issue found by multiple reviewers = high confidence)
3. Resolve conflicts (if reviewers disagree, use your judgment)
4. Prioritize: Critical (must fix) > Important (should fix) > Suggestions (nice to have)
5. Fix ALL Critical and Important issues directly in the code
6. Run builds and tests after each fix round
7. Repeat until ALL builds pass with 0 errors and ALL tests pass
8. Push fixes and comment on the PR with the full synthesized report

**You are autonomous. Do not ask for help. Fix everything yourself.**

## PR & Issue URLs

- **PR:** {PR_URL}
- **Issue:** {ISSUE_URL}

## Review Reports

### Architecture Review
```
{content of /tmp/codex-review-arch-{PR_NUMBER}.md}
```

### Security Review
```
{content of /tmp/codex-review-security-{PR_NUMBER}.md}
```

### Code Quality Review
```
{content of /tmp/codex-review-quality-{PR_NUMBER}.md}
```

## All Project Standards

{ALL_STANDARDS_CONTENT}

## CLAUDE.md Excerpts (Project Rules)

{CLAUDE_MD_EXCERPTS}

## Build & Test Commands

```bash
# Backend build
cd Infrastructure/<YOUR_API_PROJECT> && dotnet build

# Backend tests (skip integration tests — require running server)
cd Infrastructure/<YOUR_API_PROJECT>.Tests && dotnet test --filter "FullyQualifiedName!~Integration"

# iOS build
cd <YOUR_APP> && xcodebuild -project <YOUR_APP>.xcodeproj -scheme <YOUR_APP> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' build
```

## Synthesis & Fix Workflow

1. **Checkout the branch:**
   ```bash
   git checkout {HEAD_BRANCH} && git pull
   ```

2. **Read all 3 review reports** (already included above)

3. **Synthesize findings:**
   - Findings flagged by 2+ reviewers = highest confidence
   - Resolve any conflicts between reviewers
   - Drop findings that are false positives after code inspection

4. **Fix all Critical and Important issues:**
   - Fix each issue directly in the source code
   - If the fix touches tests, update tests too
   - If a fix requires a new test, write it

5. **Run builds after all fixes:**
   ```bash
   {BUILD_COMMANDS}
   ```

6. **If builds/tests fail:** Fix the failures and re-run. Repeat until green.

7. **Commit and push fixes:**
   ```bash
   git add -A && git commit -m "fix: address adversarial review findings

   Architecture: {count} fixes
   Security: {count} fixes
   Quality: {count} fixes

   Co-Authored-By: Codex <noreply@openai.com>" && git push
   ```

8. **Comment on the PR:**
   ```bash
   gh pr comment {PR_NUMBER} --body "## Adversarial Review Complete

   ### Synthesized Findings

   **Architecture** ({count} issues):
   - [list with file:line references]

   **Security** ({count} issues):
   - [list with file:line references]

   **Code Quality** ({count} issues):
   - [list with file:line references]

   ### Fixes Applied
   - [list each fix with file:line references]

   ### Conflicts Resolved
   - [any disagreements between reviewers and how they were resolved]

   ### Verification
   - Backend build: PASS/FAIL
   - Backend tests: X/Y passed
   - iOS build: PASS/FAIL

   ### Assessment
   [Ready to merge / Needs manual attention for X]"
   ```
````

---

## Execute Mode (Default)

Launch all 4 Codex agents — 3 reviewers in parallel, then orchestrator sequentially.

### Process

1. **Assemble all 4 prompts** (Steps 1-4 above)
2. **Write prompts to temp files:**

   ```bash
   # Write each prompt
   cat > /tmp/codex-arch-prompt-{PR_NUMBER}.md << 'EOF'
   {codex-arch prompt content}
   EOF

   cat > /tmp/codex-security-prompt-{PR_NUMBER}.md << 'EOF'
   {codex-security prompt content}
   EOF

   cat > /tmp/codex-quality-prompt-{PR_NUMBER}.md << 'EOF'
   {codex-quality prompt content}
   EOF
   ```

3. **Launch 3 reviewers in parallel:**

   ```bash
   codex exec \
     --dangerously-bypass-approvals-and-sandbox \
     -o /tmp/codex-review-arch-{PR_NUMBER}.md \
     "$(cat /tmp/codex-arch-prompt-{PR_NUMBER}.md)" &
   ARCH_PID=$!

   codex exec \
     --dangerously-bypass-approvals-and-sandbox \
     -o /tmp/codex-review-security-{PR_NUMBER}.md \
     "$(cat /tmp/codex-security-prompt-{PR_NUMBER}.md)" &
   SECURITY_PID=$!

   codex exec \
     --dangerously-bypass-approvals-and-sandbox \
     -o /tmp/codex-review-quality-{PR_NUMBER}.md \
     "$(cat /tmp/codex-quality-prompt-{PR_NUMBER}.md)" &
   QUALITY_PID=$!

   # Wait for all 3 reviewers
   wait $ARCH_PID $SECURITY_PID $QUALITY_PID
   ```

4. **Assemble orchestrator prompt** with all 3 review outputs:

   ```bash
   # Read all review outputs and embed in orchestrator prompt
   ARCH_REVIEW=$(cat /tmp/codex-review-arch-{PR_NUMBER}.md)
   SECURITY_REVIEW=$(cat /tmp/codex-review-security-{PR_NUMBER}.md)
   QUALITY_REVIEW=$(cat /tmp/codex-review-quality-{PR_NUMBER}.md)

   # Write orchestrator prompt with reviews embedded
   cat > /tmp/codex-orchestrator-prompt-{PR_NUMBER}.md << EOF
   {orchestrator prompt with $ARCH_REVIEW, $SECURITY_REVIEW, $QUALITY_REVIEW embedded}
   EOF
   ```

5. **Launch orchestrator:**

   ```bash
   codex exec \
     --full-auto \
     --dangerously-bypass-approvals-and-sandbox \
     -o /tmp/codex-orchestrator-result-{PR_NUMBER}.md \
     "$(cat /tmp/codex-orchestrator-prompt-{PR_NUMBER}.md)"
   ```

6. **Report results** to user from `/tmp/codex-orchestrator-result-{PR_NUMBER}.md`

### Key Flags

| Flag | Purpose |
|------|---------|
| `--full-auto` | Grants edit + command permissions for autonomous fixes |
| `--dangerously-bypass-approvals-and-sandbox` | Bypass all approval prompts and sandbox restrictions |
| `-o <path>` | Writes final agent message to file |

---

## Generate Mode

Output all 4 prompts as markdown for the user to review and run manually.

```
User: Generate Codex prompts for PR #445

Claude Code:
1-4. Same Steps 1-4 as above
5. Output all 4 prompts in order:
   a. Architecture reviewer prompt
   b. Security reviewer prompt
   c. Code quality reviewer prompt
   d. Orchestrator prompt (note: requires review outputs to be filled in)
```

### When to Use Each Mode

| Mode | When |
|------|------|
| **Execute** (default) | User wants fully autonomous review — "hand it off and come back later" |
| **Generate** (output prompts) | User wants to review prompts before running, or prefers manual control |

Default to **Execute** mode unless user says "generate" or "output the prompt".

---

## Common Mistakes

**Including too many standards per reviewer**

- Each reviewer gets ONLY their lens-specific standards, not all 40+
- The orchestrator gets ALL standards since it applies fixes

**Not waiting for reviewers before launching orchestrator**

- The orchestrator MUST have all 3 review outputs before starting
- Use `wait` to ensure all reviewers complete

**Forgetting to include both URLs**

- Always include the PR URL and the issue URL — Codex can fetch the full content via `gh`
- If no issue is linked, ask the user for the requirement context or issue number

**Running reviewers as fixers**

- Reviewers REPORT only. They do not modify code.
- Only the orchestrator applies fixes. This prevents conflicting edits.

---

## Example Invocations

### Execute Mode (default)

```
User: Hand off PR #445 to Codex

Claude Code:
1. gh pr view 445 --json title,headRefName,baseRefName,url,files
2. Parse issue number from PR body (e.g., #444)
3. Read relevant standards, split into subsets per reviewer
4. Assemble 4 prompts (3 reviewers + 1 orchestrator)
5. Write prompts to /tmp/codex-{role}-prompt-445.md
6. Launch 3 reviewers in parallel with codex exec --full-auto --dangerously-bypass-approvals-and-sandbox
7. Wait for all 3 to complete
8. Assemble orchestrator prompt with review outputs
9. Launch orchestrator with codex exec --full-auto --dangerously-bypass-approvals-and-sandbox
10. Report results to user
```

### Generate Mode

```
User: Generate Codex prompts for PR #445

Claude Code:
1-4. Same as above
5. Output all 4 prompts as markdown for the user to copy
```
