# Audit Checklist

Read this file during Phase 2 (Audit) for detailed criteria on each check.

## Redundancy Check

### How to Detect Overlap

1. Read YAML frontmatter (`name`, `description`) of every installed skill/agent in:
   - `~/.agentConfig/skills/`
   - `~/.agentConfig/agents/`
   - `.claude/skills./` (repo-local, if exists)
   - `.claude/agents./` (repo-local, if exists)
2. For skills, also scan the first 50 lines of SKILL.md body for domain keywords.
3. Compare domain coverage against the new item.

### Overlap Classification

| Type | How to detect | Recommendation |
|------|--------------|----------------|
| **Exact duplicate** | Same `name` field, or description is >80% similar in meaning | Skip install, notify user |
| **Superset** | New item's described domain fully covers existing item's domain, plus additional areas | Recommend replacing old with new |
| **Partial overlap** | Shared domain keywords (e.g., both mention "SwiftUI views" or "concurrency") but different specializations | Flag overlap areas, let user decide if both are needed |
| **Complementary** | No meaningful domain overlap | Proceed, no flag needed |

### Examples in ZibbyMono

- `swift-concurrency` vs `swift-concurrency-pro`: Pro is a superset — recommend replacing
- `swiftui-pro` vs `swiftui-view-refactor`: Partial overlap — Pro is broader, view-refactor is specialized. Both useful.
- `swift-security-expert` vs `ios-accessibility`: Complementary — different domains entirely

## Value Alignment Check

### Project Tech Stack (read from CLAUDE.md at runtime)

Extract these keywords from CLAUDE.md to build the project's tech profile:
- Languages: Swift, C#
- Frameworks: SwiftUI, .NET 8, ASP.NET Core
- Platforms: iOS, GCP, Cloud Run
- Databases: PostgreSQL
- Auth: Firebase
- UI: Vue 3 (admin panel)
- AI: Vertex AI, Gemini
- IaC: Terraform

### Mismatch Detection

Compare the skill/agent's description and body against the project tech profile. Flag if the skill targets technologies not in the profile:

- React, Next.js, Angular → not in stack (Vue is, but only for admin)
- AWS, Azure → not in stack (GCP is)
- MongoDB, DynamoDB → not in stack (PostgreSQL is)
- Node.js, Express → not in stack (.NET is)

**Important:** Some skills are legitimately cross-platform (e.g., `git-advanced-workflows`, `debugging-strategies`). Only flag skills whose primary domain is a mismatched technology, not skills that happen to use examples from other stacks.

### Advisory Format

```
Advisory: This skill targets [technology], your project uses [alternative].
Install anyway? [yes / skip]
```

## Conflict Detection

### What to Check

Read these project files for conventions:
1. `CLAUDE.md` — coding style, naming, patterns, gotchas
2. `agent-os/standards/` — any files matching the skill's domain

### Common Conflict Patterns

| Skill says | Project says | Conflict |
|-----------|-------------|----------|
| Use `@StateObject` | Use `@Observable` macro (iOS 17+) | State management |
| Use `ObservableObject` | Use `@Observable` macro | State management |
| Use `@EnvironmentObject` | Use `@Environment` with Observable | Dependency injection |
| Use `NavigationView` | Use `NavigationStack` | Navigation |
| Hardcode API URLs | Route through `GCPAPIURLBuilder.swift` | API routing |
| Hardcode AI model names | Config-driven via backend endpoints | AI configuration |
| Use `Dockerfile` | Use `Dockerfile.gcp` | Container builds |
| Project ID `zibby-dev` | Project ID `zibby-24e66` | GCP project IDs |

### Conflict Report Format

```
Conflict: Skill recommends [X], but CLAUDE.md specifies [Y].
  Source: CLAUDE.md line [N] / agent-os/standards/[file]
  This will be addressed in the project-overrides patch.
```
