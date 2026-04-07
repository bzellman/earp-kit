# MCP Server Configurations

Model Context Protocol (MCP) servers extend Claude Code with tool integrations. These are configured in `.claude/settings.json` or at the system level.

## Recommended: Docker MCP

We recommend using Docker's MCP tooling as the primary MCP integration. It provides container build, run, and management capabilities and is included via Claude Code's built-in Docker integration - no additional setup required.

Docker MCP covers the most common development workflows (building images, running containers, managing compose stacks) and integrates cleanly with CI/CD pipelines.

## Active MCP Servers

### xcodebuild MCP
- **Package:** `xcodebuildmcp@2.3.0` (global npm)
- **Purpose:** iOS builds, simulator management, UI automation, screenshots, LLDB debugging
- **Config:** Auto-discovered by Claude Code when installed globally
- **Docs:** https://github.com/getsentry/XcodeBuildMCP

### Docker MCP
- **Purpose:** Container build, run, and management
- **Config:** Included via Claude Code's built-in Docker integration

## MCP Server Configuration Example

In `.claude/settings.json`:

```json
{
  "mcpServers": {
    "your-server": {
      "command": "npx",
      "args": ["your-mcp-package"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

## Other MCP Servers

The Gemini CLI (`@google/gemini-cli@0.1.9`) can be installed globally for multi-model workflows but is not required for any skill or command in this catalog.
