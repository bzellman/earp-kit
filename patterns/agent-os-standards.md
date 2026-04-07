# Pattern: Agent-OS Standards-Driven Development

## Overview

A command suite that discovers, indexes, and injects project standards into agent context, ensuring all AI-assisted development follows established patterns.

## The 5 Commands

### `/agent-os:discover-standards`
Scans the codebase for implicit and explicit standards:
- Coding conventions from existing code patterns
- Architecture decisions from directory structure
- Testing patterns from existing test files
- CI/CD patterns from workflow files
- Documentation standards from existing docs

### `/agent-os:index-standards`
Creates a searchable index of discovered standards:
- Categorizes by type (code style, architecture, testing, deployment)
- Ranks by confidence (explicit documentation vs. inferred from code)
- Links standards to source files as evidence

### `/agent-os:inject-standards`
Injects relevant standards into agent context before implementation:
- Filters standards relevant to the current task
- Provides examples from the codebase
- Sets constraints the implementation must follow

### `/agent-os:plan-product`
Plans product features with standards awareness:
- Ensures planned work aligns with existing architecture
- Identifies which standards apply to the planned feature
- Flags potential standard violations early

### `/agent-os:shape-spec`
Shapes implementation specifications using standards:
- Structures the plan in plan mode
- Gathers context from standards index
- Produces a ready-to-execute specification

## Why This Matters

Without standards injection, AI agents write code that "works" but doesn't fit the codebase. They'll use different naming conventions, miss architectural patterns, or ignore testing requirements. Agent-OS ensures consistency by making standards part of the agent's context.

## Integration Points

- Used by: `/prd-taskmaster` (triggers `shape-spec` after PRD creation)
- Used by: `/feature-dev` (injects standards before implementation)
- Feeds into: Implementation agents (ios-developer, gcp-platform-engineer)

## See Also

- `commands/agent-os/` - All 5 command files
- `skills/system/prd-taskmaster/` - Uses shape-spec as handoff
