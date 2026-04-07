---
name: senior-architect
description: Comprehensive software architecture skill for designing scalable, maintainable systems across web, mobile, and backend stacks (React, Next.js, Node/Express, React Native, Swift, Kotlin, Flutter, Postgres, GraphQL, Go, Python). Use when designing system architecture, making technical decisions, creating architecture diagrams, evaluating trade-offs, or defining integration patterns.
---

# Senior Architect

## Overview
Provide architecture direction, system design patterns, and decision frameworks for multi-platform products. Use bundled scripts to generate starter diagrams, scan project footprints, and summarize dependencies.

## Quick Start
Run a script based on the task:

```bash
python3 scripts/architecture_diagram_generator.py <project-path> [--output diagram.mmd]
python3 scripts/project_architect.py <project-path> [--verbose]
python3 scripts/dependency_analyzer.py <project-path> [--analyze]
```

## Core Capabilities

### 1) Architecture Diagram Generator
Generate a starter Mermaid diagram you can refine.

- **Use when:** You need a quick architecture diagram scaffold.
- **Script:** `scripts/architecture_diagram_generator.py`
- **Reference:** `references/architecture_patterns.md`

### 2) Project Architect
Summarize the project footprint and highlight likely components.

- **Use when:** You need a high-level architecture readout or review.
- **Script:** `scripts/project_architect.py`
- **Reference:** `references/system_design_workflows.md`

### 3) Dependency Analyzer
Detect common dependency files and summarize stack signals.

- **Use when:** You need a fast dependency inventory or tech stack hints.
- **Script:** `scripts/dependency_analyzer.py`
- **Reference:** `references/tech_decision_guide.md`

## Reference Documentation
Load these only when needed:

- `references/architecture_patterns.md` for patterns and anti-patterns
- `references/system_design_workflows.md` for system design process
- `references/tech_decision_guide.md` for stack decisions and trade-offs
