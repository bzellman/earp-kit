# Tmux Session Orchestrator

Run full Claude Code skill pipelines (`/bug-to-pr`, `/prd-to-pr`, `/triage`) in parallel via tmux, each in its own git worktree with complete skill access.

## Problem

Claude Code sub-agents (spawned via the Agent tool) don't have access to the `Skill` tool. Skills like `/bug-to-pr` and `/prd-to-pr` are multi-stage pipelines that chain other skills internally. When dispatched as sub-agents, they can't invoke those skills, breaking the pipeline.

## Solution

Spawn full, interactive Claude Code CLI sessions in tmux panes. Each session has the complete tool and skill registry. A dedicated orchestrator session monitors workers, gates PRs after CI, and routes to deployment.

## Layout

```
+----------------------+--------------+---------------------+
|                      |  Worker 1    |  Personal Terminal   |
|                      |  /bug-to-pr  |  (your shell)       |
|    Orchestrator      |  #101        |                     |
|    (interactive      +--------------+---------------------+
|     claude)          |  Worker 2    |  Codex Session       |
|                      |  /prd-to-pr  |  (controlled by      |
|    You talk here.    |  image gen   |   orchestrator)      |
|    Gates PRs.        +--------------+                     |
|    Routes deploys.   |  Worker 3    |                     |
|                      |  /triage     |                     |
+----------------------+--------------+---------------------+
     ~40% width          ~30% width       ~30% width
```

## Quick Start

```bash
# Copy to your project
cp scripts/orchestrate/orchestrate.sh <your-repo>/scripts/
cp scripts/orchestrate/orchestrator-prompt.md <your-repo>/scripts/

# Run
./scripts/orchestrate.sh -- "fix #101" "prd for image gen" "triage slack bugs"
```

## Usage

```bash
# Run three work items in parallel
./scripts/orchestrate.sh -- "fix #801" "prd audio retry" "implement sharing"

# Dry run to test layout
./scripts/orchestrate.sh --dry-run -- "fix #1" "fix #2"

# Recover a crashed session
./scripts/orchestrate.sh --recover orch-20260409-1430-a1b2

# Clean up orphaned worktrees
./scripts/orchestrate.sh --cleanup-stale
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--max-workers N` | 3 | Concurrent workers (1-5) |
| `--max-budget-usd N` | 20 | Per-worker cost cap in USD |
| `--base-branch REF` | HEAD | Branch to create worktrees from |
| `--dry-run` | - | Test layout without launching Claude |
| `--recover <id>` | - | Reconnect to or recover a crashed session |
| `--cleanup-stale` | - | Remove orphaned worktrees |
| `--yes` | - | Skip cost confirmation prompt |

## Work Item Routing

Items are classified by prefix and routed to the appropriate skill:

| Pattern | Skill |
|---------|-------|
| `fix #N`, `bug #N`, `issue #N` | `/bug-to-pr` |
| `prd ...`, `build ...`, `implement ...` | `/prd-to-pr` |
| `triage ...` | `/triage` |
| (anything else) | Orchestrator asks you |

## Architecture

- **Workers** run in `--bare` mode (no LSP, hooks, plugins) for fast startup and low resource usage
- **Git worktrees** isolate each worker's code changes (`.worktrees/orch-<session>/worker-<N>`)
- **Status files** (JSON) provide IPC between workers and orchestrator
- **Bash monitor loop** checks pane liveness every 60s, detects crashed workers
- **Cleanup trap** handles SIGINT/SIGTERM, preserves dirty worktrees
- **Queue management** for >5 work items (workers launch as slots free up)

## Requirements

- `tmux` >= 3.0
- `claude` CLI (Claude Code)
- `git` with worktree support
- `jq` for JSON parsing
- Optional: `codex` CLI for the Codex review pane

## Slash Command

To add as a Claude Code slash command, create `.claude/commands/orchestrate.md`:

```markdown
---
description: Launch parallel Claude Code skill pipelines in tmux with git worktree isolation
---

Parse `$ARGUMENTS` for quoted work items and run:

\`\`\`bash
!scripts/orchestrate.sh $ARGUMENTS
\`\`\`

$ARGUMENTS
```

## Design Documents

The orchestrator was designed through a structured counsel process:
- [Design Spec](https://github.com/Zibby-M/ZibbyMono/blob/main/docs/superpowers/specs/2026-04-09-tmux-orchestrator-design.md)
- [Implementation Plan](https://github.com/Zibby-M/ZibbyMono/blob/main/agent-os/specs/2026-04-09-tmux-orchestrator/plan.md) (post-counsel, 12 amendments)
- [Counsel Log](https://github.com/Zibby-M/ZibbyMono/blob/main/agent-os/specs/2026-04-09-tmux-orchestrator/counsel-log.md) (3 reviewers)
