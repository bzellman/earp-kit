# Installed Plugins Catalog

Claude Code plugins are installed via marketplaces and provide bundled skills, agents, and commands.

## Plugin Marketplaces

| Marketplace | Plugins | Focus |
|-------------|---------|-------|
| `claude-plugins-official` | superpowers, frontend-design, agent-sdk-dev, code-simplifier | Core workflow skills |
| `claude-code-plugins` | agent-sdk-dev, code-review, commit-commands, feature-dev, frontend-design, pr-review-toolkit, ralph-wiggum, security-guidance | Development workflow |
| `claude-code-workflows` | code-documentation, business-analytics, content-marketing, python-development, javascript-typescript, systems-programming, shell-scripting, developer-essentials | Domain expertise |
| `buildatscale-claude-code` | buildatscale, promo-video, nano-banana-pro | Build/deploy/video |

## Core Plugins

### superpowers v5.0.7
**Source:** claude-plugins-official
**Skills provided:**
- `brainstorming` - Pre-implementation exploration of intent and design
- `writing-plans` - Multi-step task planning before code
- `executing-plans` - Plan execution with review checkpoints
- `subagent-driven-development` - Parallel task execution via subagents
- `test-driven-development` - TDD workflow enforcement
- `using-git-worktrees` - Isolated workspace creation
- `finishing-a-development-branch` - Merge/PR/cleanup options
- `verification-before-completion` - Evidence-based success claims
- `requesting-code-review` / `receiving-code-review` - Review workflows
- `systematic-debugging` - Bug investigation methodology
- `dispatching-parallel-agents` - Parallel independent tasks
- `writing-skills` - Skill creation and verification

### commit-commands v1.0.0
**Source:** claude-code-plugins
**Commands provided:**
- `/commit` - Structured git commits
- `/commit-push-pr` - Full commit + push + PR workflow
- `/clean_gone` - Clean merged git branches

### pr-review-toolkit v1.0.0
**Source:** claude-code-plugins
**Agents provided:**
- `code-reviewer` - Comprehensive PR review
- `silent-failure-hunter` - Error handling review
- `type-design-analyzer` - Type system review
- `pr-test-analyzer` - Test coverage review
- `code-simplifier` - Code simplification
- `comment-analyzer` - Comment accuracy review

### buildatscale
**Source:** buildatscale-claude-code
**Commands provided:**
- `/ceo` - Executive summary of work in progress
- `/commit` - Structured commit messages
- `/pr` - PR creation with auto-branching

## LSP Plugins

| Plugin | Language | Version |
|--------|----------|---------|
| `swift-lsp` | Swift (SourceKit-LSP) | 1.0.0 |
| `typescript-lsp` | TypeScript/JavaScript | 1.0.0 |
| `pyright-lsp` | Python | 1.0.0 |
| `csharp-lsp` | C# (OmniSharp) | 1.0.0 |
| `clangd-lsp` | C/C++ | 1.0.0 |
