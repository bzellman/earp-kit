# Skills Catalog

Skills are trigger-matched capabilities that activate based on pattern matching in user messages or task context.

## System-Level Skills (`system/`)

These are installed at `~/.agentConfig/skills/` and available across all projects.

| Skill | Trigger | Description |
|-------|---------|-------------|
| `atlas` | Control ChatGPT Atlas desktop app | macOS AppleScript control for Atlas tabs/bookmarks |
| `brand-guidelines` | Brand colors, style guidelines | Applies brand colors and typography to artifacts |
| `bug-to-pr` | Bug report to fix PR | 8-stage pipeline: triage -> RCA -> counsel -> implement -> simplify -> review -> deploy |
| `chatgpt-apps` | ChatGPT Apps SDK | Build MCP server + widget UI applications |
| `code-simplifier` | Simplify code | Reviews changed code for clarity, consistency, reuse |
| `dead-code-cleanup` | Dead code removal | Safely removes dead Swift code using isolated git worktree |
| `figma` | Figma URLs, design-to-code | Fetches Figma context and translates to production code |
| `find-skills` | "how do I", "find a skill" | Discovers and installs agent skills |
| `gh-fix-ci` | Debug failing CI checks | Inspects GH Actions logs, diagnoses, drafts fix plan |
| `install-tooling` | "install", "add skill", "add agent" | Project-aware skill/agent installer with redundancy detection, value alignment, conflict checking, and auto-patching |
| `ios-design` | SwiftUI design | Design system compliance with Apple HIG |
| `ios-simulator-skill` | iOS simulator operations | Build, run, test on iOS simulators; bundled from `conorluddy/ios-simulator-skill` |
| `microsoft-foundry` | Microsoft AI platform integration | Microsoft AI platform integration |
| `openai-docs` | OpenAI API docs | Fetches up-to-date OpenAI documentation |
| `pdf` | PDF files | Read, create, review PDFs with rendering |
| `pr-handoff-to-codex` | PR ready for review | 4-agent adversarial Codex review |
| `prd-taskmaster` | "PRD", "product requirements" | Generates PRD, publishes as GitHub issue; bundled from `anombyte93/prd-taskmaster` |
| `prd-to-pr` | End-to-end PRD to PR | Full pipeline: PRD -> spec -> implement -> review -> deploy |
| `remotion-best-practices` | Remotion video | Best practices for React video creation |
| `security-threat-model` | Threat model a codebase | Repository-grounded threat modeling |
| `self-healing-deploy` | "ship it", "deploy this" | 7-phase autonomous merge-to-production |
| `senior-architect` | System architecture design | Multi-platform architecture guidance |
| `triage` | Batch work items | Processes bugs/features/ideas into GitHub issues |
| `video-report` | Generate video report | Creates reports about video content |
| `workflow-orchestrator` | Run 2+ pipelines in parallel | Orchestrates concurrent `/prd-to-pr` or `/bug-to-pr` pipelines |

## Project-Level Skills (`project/`)

These are scoped to specific projects and contain project-specific context.

### <YOUR_MONOREPO> (`project/<YOUR_MONOREPO_DIR>/`)

| Skill | Description |
|-------|-------------|
| `app-ios-build` | Repo-local iOS build runner template for your monorepo |
| `brand-guidelines` | App-specific brand colors and typography |
| `dead-code-cleanup` | Swift dead code removal for <YOUR_MONOREPO> |
| `ios-design` | <YOUR_APP> iOS design system compliance |
| `self-healing-deploy` | Deploy pipeline configured for <YOUR_MONOREPO> |

### <YOUR_MOBILE_APP> (`project/<YOUR_MOBILE_APP>/`)

| Skill | Description |
|-------|-------------|
| `frontend-design` | React/Tailwind frontend design for Design OS |
