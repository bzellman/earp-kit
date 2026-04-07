#!/bin/bash
# Optional Claude Code session-start hook.
# This script is intentionally generic and safe to publish: it only reports
# local repo context and installed tooling. It does not make network calls.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

print_header() {
    echo "# Claude Code Session Context"
    echo ""
    echo "- Project root: \`$PROJECT_ROOT\`"
    if [ -d "$CLAUDE_DIR" ]; then
        echo "- Claude config: \`$CLAUDE_DIR\`"
    else
        echo "- Claude config: not found at \`$CLAUDE_DIR\`"
    fi
    echo "- Initialized at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

extract_description() {
    local path="$1"
    local description
    description=$(grep "^description:" "$path" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//')
    if [ -z "${description:-}" ] || [ "$description" = "---" ]; then
        description=$(grep "^# " "$path" 2>/dev/null | head -1 | sed 's/^# //')
    fi
    if [ -z "${description:-}" ]; then
        description="No description"
    fi
    printf '%s\n' "$description"
}

list_markdown_directory() {
    local title="$1"
    local directory="$2"
    local prefix="$3"
    local found=false

    if [ ! -d "$directory" ]; then
        return
    fi

    while IFS= read -r -d '' file; do
        if [ "$found" = false ]; then
            echo "## $title"
            echo ""
            found=true
        fi
        local name
        name=$(basename "$file" .md)
        local description
        description=$(extract_description "$file")
        echo "- **${prefix}${name}**: $description"
    done < <(find "$directory" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

    if [ "$found" = true ]; then
        echo ""
    fi
}

list_agents() {
    if [ ! -d "$CLAUDE_DIR/agents" ]; then
        return
    fi

    echo "## Available Agents"
    echo ""
    while IFS= read -r -d '' file; do
        local rel_path
        rel_path="${file#$CLAUDE_DIR/agents/}"
        local name
        name=$(basename "$file" .md)
        local description
        description=$(extract_description "$file")
        echo "- **$name** (\`${rel_path}\`): $description"
    done < <(find "$CLAUDE_DIR/agents" -type f -name '*.md' -print0 | sort -z)
    echo ""
}

list_swarms() {
    local swarm_dir="$CLAUDE_DIR/swarms"
    local found=false

    if [ ! -d "$swarm_dir" ]; then
        return
    fi

    while IFS= read -r -d '' file; do
        if [ "$found" = false ]; then
            echo "## Swarm Configurations"
            echo ""
            found=true
        fi
        local name
        name=$(basename "$file" .json)
        local description
        description=$(jq -r '.description // "No description"' "$file" 2>/dev/null || echo "No description")
        echo "- **$name**: $description"
    done < <(find "$swarm_dir" -maxdepth 1 -type f -name '*.json' -print0 | sort -z)

    if [ "$found" = true ]; then
        echo ""
    fi
}

recent_git_activity() {
    if [ ! -d "$PROJECT_ROOT/.git" ] && [ ! -f "$PROJECT_ROOT/.git" ]; then
        return
    fi

    echo "## Git Snapshot"
    echo ""
    echo "- Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
    echo "- Recent commits:"
    git log --oneline -5 2>/dev/null | sed 's/^/  /' || true
    local changes
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    echo "- Uncommitted files: ${changes:-0}"
    echo ""
}

tool_status() {
    echo "## Tooling"
    echo ""
    for tool in git gh jq python3 node dotnet swift xcodebuild gcloud docker; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "- **$tool**: available"
        else
            echo "- **$tool**: not found"
        fi
    done
    echo ""
}

print_footer() {
    echo "## Next Steps"
    echo ""
    echo "- Review repo-specific permissions before enabling automation."
    echo "- Copy only the skills, commands, and workflows this project actually needs."
    echo "- Keep this hook opt-in; do not auto-enable shell hooks in shared templates."
    echo ""
}

print_header
list_markdown_directory "Available Slash Commands" "$CLAUDE_DIR/commands" "/"
list_agents
list_swarms
recent_git_activity
tool_status
print_footer

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    {
        echo "APP_PROJECT_ROOT=$PROJECT_ROOT"
        echo "APP_CLAUDE_DIR=$CLAUDE_DIR"
    } >> "$CLAUDE_ENV_FILE"
fi

exit 0
