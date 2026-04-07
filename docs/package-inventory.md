# Package Inventory

Catalog of npm, pip, and global packages powering the agentic SDLC.

## Global npm Packages

| Package | Version | Category | Purpose |
|---------|---------|----------|---------|
| `@google/gemini-cli` | 0.1.9 | AI CLI | Google Gemini CLI for multi-model workflows |
| `apollo` | 2.34.0 | GraphQL | Apollo GraphQL CLI for schema management |
| `firebase-tools` | 15.5.1 | Cloud | Firebase CLI for hosting, functions, auth |
| `genkit-cli` | 1.12.0 | Agent Framework | Google Genkit for building AI agent flows |
| `task-master-ai` | 0.43.0 | Agent Orchestration | AI-powered task orchestration and planning |
| `typescript` | 5.9.3 | Build | TypeScript compiler |
| `pyright` | 1.1.408 | Build | Python type checker (used by LSP plugin) |
| `xcodebuildmcp` | 2.3.0 | MCP Server | Xcode build/test/simulator MCP integration |

## Claude Code Plugins

| Plugin | Version | Source | Category |
|--------|---------|--------|----------|
| `superpowers` | 5.0.7 | claude-plugins-official | Workflow orchestration (brainstorming, TDD, plans, review) |
| `frontend-design` | - | claude-plugins-official | Production-grade UI generation |
| `code-simplifier` | 1.0.0 | claude-plugins-official | Code clarity and refactoring |
| `agent-sdk-dev` | 1.0.0 | claude-code-plugins | Agent SDK app scaffolding |
| `code-review` | 1.0.0 | claude-code-plugins | PR review guidance |
| `commit-commands` | 1.0.0 | claude-code-plugins | Git commit/push/PR automation |
| `feature-dev` | 1.0.0 | claude-code-plugins | Guided feature development |
| `pr-review-toolkit` | 1.0.0 | claude-code-plugins | Comprehensive PR review agents |
| `ralph-wiggum` | 1.0.0 | claude-code-plugins | Test-driven development helper |
| `security-guidance` | 1.0.0 | claude-code-plugins | Security best practices |
| `buildatscale` | - | buildatscale-claude-code | CEO summaries, commit, PR commands |

## Claude Code Workflow Plugins

| Plugin | Version | Purpose |
|--------|---------|---------|
| `code-documentation` | 1.2.0 | Technical docs, tutorials, code review |
| `business-analytics` | 1.2.0 | KPI frameworks, dashboards |
| `content-marketing` | 1.2.0 | Content strategy, SEO |
| `python-development` | 1.2.1 | Django, FastAPI, async patterns |
| `javascript-typescript` | 1.2.1 | JS/TS patterns, testing |
| `systems-programming` | 1.2.0 | Go, Rust, C/C++ |
| `shell-scripting` | 1.2.1 | Bash, POSIX shell, Bats testing |
| `developer-essentials` | 1.0.0 | Git, debugging, auth, SQL, E2E testing |

## LSP Plugins

| Plugin | Version | Language |
|--------|---------|----------|
| `swift-lsp` | 1.0.0 | Swift (SourceKit-LSP) |
| `typescript-lsp` | 1.0.0 | TypeScript/JavaScript |
| `pyright-lsp` | 1.0.0 | Python |
| `csharp-lsp` | 1.0.0 | C# (OmniSharp) |
| `clangd-lsp` | 1.0.0 | C/C++ |

## MCP Server Ecosystem

We recommend Docker MCP as the primary integration. See `configs/mcp-servers/README.md`.

| Server | Protocol | Integration |
|--------|----------|-------------|
| Docker MCP (recommended) | Local | Container build, run, management |
| xcodebuild MCP | Local (npx) | iOS builds, simulator, UI automation, screenshots |

## Maintenance Notes

- **superpowers** is the most critical plugin - version 5.0.7 provides the core workflow skills (brainstorming, TDD, plan execution, code review, git worktrees)
- **xcodebuildmcp** is actively maintained by Sentry - updates frequently with Xcode releases
- **buildatscale** plugins are community-maintained - check for updates quarterly
- **LSP plugins** should be updated when language toolchain versions change (Xcode, Node, Python, .NET)
- **Docker MCP** is built into Claude Code and requires no additional installation
