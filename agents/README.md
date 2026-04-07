# Agents Catalog

Agent definitions are markdown files that configure specialized Claude Code agents with domain expertise, constraints, and capabilities.

## iOS Agents (`ios/`)

| Agent | Source | Description |
|-------|--------|-------------|
| `ios-architect.md` | <YOUR_APP> root | Senior iOS architect specializing in Swift 6.0+, SwiftUI, MVVM with @Observable |
| `ios-developer.md` | <YOUR_MONOREPO> | iOS developer agent for day-to-day Swift/SwiftUI implementation |
| `dead-code-agent.md` | <YOUR_MONOREPO> | Specialized agent for finding and removing unused Swift code |

## GCP Agents (`gcp/`)

| Agent | Source | Description |
|-------|--------|-------------|
| `gcp-platform-engineer.md` | <YOUR_MONOREPO> | GCP infrastructure design and implementation (Cloud Run, Cloud SQL, Terraform) |

## How to Use

Agents are placed in `.claude/agents/` within a project. They can be:

1. **Auto-dispatched** by skills like `/feature-dev` based on task type
2. **Explicitly invoked** via Claude Code's agent routing
3. **Referenced in team configs** for multi-agent coordination

## Creating New Agents

An agent markdown file typically contains:

```markdown
# Agent Name

## Role
Description of the agent's expertise and responsibilities.

## Capabilities
- What this agent can do
- Tools it should use
- Domains it covers

## Constraints
- What this agent should NOT do
- Boundaries of its scope
- When to escalate to a human

## Context
Project-specific context the agent needs to know.
```
