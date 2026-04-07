# Commands Catalog

Slash commands are user-invoked actions placed in `.claude/commands/` directories. Users trigger them with `/<command-name>` in Claude Code.

## Agent-OS Commands (`agent-os/`)

Standards-driven development framework.

| Command | Description |
|---------|-------------|
| `/agent-os:discover-standards` | Scan codebase for implicit and explicit standards |
| `/agent-os:index-standards` | Create searchable index of discovered standards |
| `/agent-os:inject-standards` | Inject relevant standards into agent context |
| `/agent-os:plan-product` | Plan features with standards awareness |
| `/agent-os:shape-spec` | Structure implementation spec using standards |

## Operations Commands (`ops/`)

Cost, performance, and security management.

| Command | Description |
|---------|-------------|
| `/cost-optimize` | Identify and implement cost optimizations |
| `/cost-report` | Generate cost analysis report |
| `/perf-check` | Quick performance check |
| `/perf-optimize` | Implement performance optimizations |
| `/perf-report` | Generate detailed performance report |
| `/security-scan` | Run security analysis |
| `/pr-flow` | Guided PR creation workflow |

## iOS Commands (`ios/`)

| Command | Description |
|---------|-------------|
| `/ios-build` | Build and test iOS project |
| `/ios-design` | Design iOS screens and components |

## Design-OS Commands (`design-os/`)

Product design lifecycle from vision to export.

| Command | Pipeline Stage | Description |
|---------|---------------|-------------|
| `/design-os:product-vision` | Strategy | Define product vision and value proposition |
| `/design-os:product-roadmap` | Strategy | Break vision into prioritized phases |
| `/design-os:data-model` | Foundation | Define backing data model |
| `/design-os:design-tokens` | Foundation | Establish design tokens (colors, spacing, typography) |
| `/design-os:design-shell` | Structure | Create app shell (navigation, layout) |
| `/design-os:design-screen` | Structure | Design individual screens |
| `/design-os:shape-section` | Detail | Design sections/components within screens |
| `/design-os:sample-data` | Detail | Generate realistic sample data |
| `/design-os:screenshot-design` | Output | Capture design screenshots |
| `/design-os:export-product` | Output | Export complete product design |

## How to Use

Commands are placed in `.claude/commands/` within a project. They can be:

1. **Invoked directly** with `/<command-name>` in Claude Code
2. **Chained** by skills (e.g., `/prd-taskmaster` triggers `/agent-os:shape-spec`)
3. **Nested** in subdirectories for namespacing (e.g., `commands/agent-os/shape-spec.md`)
