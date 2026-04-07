# Upstream Attribution

This repo includes adapted workflow ideas, bundled skills, and plugin references that originated elsewhere. The goal of this file is to make those sources explicit for public reuse.

## Agent OS

- Original framework attribution: Brian Casel / Builder Methods
- Official site: https://buildermethods.com/agent-os
- Upstream repo: https://github.com/buildermethods/agent-os
- How it is used here: the `agent-os/` commands and related standards-driven planning patterns are adapted from that public framework and reorganized for this repo's broader agentic SDLC catalog

## Design OS

- Original framework attribution: Brian Casel / Builder Methods
- Official site: https://buildermethods.com/design-os
- How it is used here: the `design-os/` command suite and pattern docs are included as an adapted workflow reference
- Usage note: this is the least battle-tested part of the repo in my own workflow; it is included because the approach looks promising, not because it has the same production mileage as the engineering and delivery paths

## Superpowers

- Original author: Jesse Vincent
- Upstream repo: https://github.com/obra/superpowers
- Marketplace repo used in practice: https://github.com/obra/superpowers-marketplace
- How it is used here: referenced as the primary plugin source for brainstorming, planning, review, worktrees, and parallel-agent workflows

## PRD-Taskmaster

- Bundled skill source: https://github.com/anombyte93/prd-taskmaster
- License in bundled source: MIT
- How it is used here: included as a bundled system skill for PRD generation and issue publishing

## iOS Simulator Skill

- Original author: Conor Luddy
- Upstream repo: https://github.com/conorluddy/ios-simulator-skill
- Related upstream projects referenced in the bundled docs:
  - https://github.com/conorluddy/xc-mcp
  - https://github.com/conorluddy/xclaude-plugin
- License in bundled source: MIT
- How it is used here: included as a bundled iOS simulator automation skill with its original license and upstream README/docs retained in-tree

### Task Master dependency

- Product docs: https://docs.task-master.dev/
- Upstream repo: https://github.com/eyaltoledano/claude-task-master
- How it is used here: `prd-taskmaster` references Task Master / `task-master-ai` as the downstream task orchestration toolchain

## Attribution Guidance for Reusers

- Keep this file or an equivalent credits section if you redistribute the repo or heavily adapt these components.
- Preserve upstream LICENSE files for bundled components where they are included in-tree.
- Avoid implying that Builder Methods, Jesse Vincent, Conor Luddy, anombyte93, or the Task Master project officially maintain or endorse this repo.
