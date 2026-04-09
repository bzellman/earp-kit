#!/usr/bin/env bash
#
# orchestrate.sh
# ZibbyMono Parallel Workflow Orchestrator
#
# Orchestrates multiple Claude Code CLI sessions in tmux panes, each in its
# own git worktree. Creates a 3-column tmux layout (orchestrator | workers |
# terminal+codex), launches Claude sessions, monitors health, and handles
# cleanup on exit.
#
# Usage:
#   ./scripts/orchestrate.sh [OPTIONS] -- "work item 1" "work item 2" ...
#   ./scripts/orchestrate.sh --recover <session-id>
#   ./scripts/orchestrate.sh --cleanup-stale
#   ./scripts/orchestrate.sh --dry-run -- "work item 1" "work item 2"
#
# Options:
#   --max-workers N        Maximum concurrent workers (1-5, default: 3)
#   --max-budget-usd N     Per-worker budget in USD (default: 20)
#   --base-branch REF      Branch to create worktrees from (default: current HEAD)
#   --recover ID           Recover a previous session by ID
#   --cleanup-stale        Remove orphaned worktrees and exit
#   --dry-run              Create layout without launching Claude sessions
#   --yes                  Skip cost confirmation prompt
#   --help                 Show this help message
#
# Work Item Classification:
#   "fix #123"           → routes to /bug-to-pr
#   "bug #123"           → routes to /bug-to-pr
#   "issue #123"         → routes to /bug-to-pr
#   "prd ..."            → routes to /prd-to-pr
#   "build ..."          → routes to /prd-to-pr
#   "implement ..."      → routes to /prd-to-pr
#   "triage ..."         → routes to /triage
#   (anything else)      → orchestrator decides (prompted)
#
# Examples:
#   ./scripts/orchestrate.sh -- "fix #801" "prd audio upload retry" "implement sharing"
#   ./scripts/orchestrate.sh --max-workers 2 --max-budget-usd 10 -- "bug #555"
#   ./scripts/orchestrate.sh --dry-run -- "fix #1" "fix #2" "prd widgets"
#

set -euo pipefail

# --------------------------------------------------------------------------- #
# Constants
# --------------------------------------------------------------------------- #

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly REPO_ROOT
readonly WORKTREE_BASE="$REPO_ROOT/.claude/worktrees"
readonly MANIFEST_DIR="$REPO_ROOT/tmp/orchestrator"
readonly MAX_WORKERS_LIMIT=5
readonly HEALTH_CHECK_INTERVAL=60
readonly WORKER_READY_TIMEOUT=30
readonly WORKER_READY_POLL=1
readonly COST_PER_WORKER_ESTIMATE=8  # USD average estimate per worker

# ANSI colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'  # No Color

# --------------------------------------------------------------------------- #
# Globals (set during execution)
# --------------------------------------------------------------------------- #

SESSION_ID=""
SESSION_DIR=""
STATUS_DIR=""
MONITOR_PID=""
TMUX_SESSION=""
MAX_WORKERS=3
MAX_BUDGET_USD=20
BASE_BRANCH=""
DRY_RUN=false
RECOVER_ID=""
CLEANUP_STALE=false
SKIP_CONFIRM=false
declare -a WORK_ITEMS=()
declare -a WORKER_PANES=()
declare -a WORKER_WORKTREES=()
declare -a WORKER_BRANCHES=()
declare -a WORK_ITEM_CLASSIFICATIONS=()
ORCHESTRATOR_PANE=""
TERMINAL_PANE=""
CODEX_PANE=""

# --------------------------------------------------------------------------- #
# Logging
# --------------------------------------------------------------------------- #

log_info()  { echo -e "${GREEN}[orch]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[orch]${NC} $*" >&2; }
log_error() { echo -e "${RED}[orch]${NC} $*" >&2; }
log_step()  { echo -e "${BLUE}[orch]${NC} ${BOLD}$*${NC}"; }

# --------------------------------------------------------------------------- #
# Usage / Help
# --------------------------------------------------------------------------- #

show_help() {
    cat <<'HELP'
orchestrate.sh - Parallel Claude Code Workflow Orchestrator

SYNOPSIS
    ./scripts/orchestrate.sh [OPTIONS] -- "work item 1" "work item 2" ...
    ./scripts/orchestrate.sh --recover <session-id>
    ./scripts/orchestrate.sh --cleanup-stale

DESCRIPTION
    Orchestrates parallel Claude Code CLI sessions in tmux panes, each in
    its own git worktree. Creates a 3-column tmux layout and manages the
    full lifecycle of worker sessions.

OPTIONS
    --max-workers N        Max concurrent workers (1-5, default: 3)
    --max-budget-usd N     Per-worker budget in USD (default: 20)
    --base-branch REF      Branch to create worktrees from (default: HEAD)
    --recover ID           Recover a previous session by manifest ID
    --cleanup-stale        Remove orphaned worktrees and exit
    --dry-run              Create tmux layout without launching Claude
    --yes                  Skip cost confirmation prompt
    --help                 Show this help message

WORK ITEM ROUTING
    Items are classified by prefix and routed to the appropriate skill:

    "fix #N" / "bug #N" / "issue #N"  -->  /bug-to-pr
    "prd ..." / "build ..." / "implement ..."  -->  /prd-to-pr
    "triage ..."  -->  /triage
    (anything else)  -->  orchestrator decides

EXAMPLES
    # Run three work items in parallel
    ./scripts/orchestrate.sh -- "fix #801" "prd audio retry" "implement sharing"

    # Dry run to test layout
    ./scripts/orchestrate.sh --dry-run -- "fix #1" "fix #2"

    # Recover a crashed session
    ./scripts/orchestrate.sh --recover orch-20260409-1430-a1b2

    # Clean up orphaned worktrees
    ./scripts/orchestrate.sh --cleanup-stale
HELP
}

# --------------------------------------------------------------------------- #
# Argument Parsing
# --------------------------------------------------------------------------- #

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --max-workers)
                MAX_WORKERS="$2"
                shift 2
                ;;
            --max-budget-usd)
                MAX_BUDGET_USD="$2"
                shift 2
                ;;
            --base-branch)
                BASE_BRANCH="$2"
                shift 2
                ;;
            --recover)
                RECOVER_ID="$2"
                shift 2
                ;;
            --cleanup-stale)
                CLEANUP_STALE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --yes)
                SKIP_CONFIRM=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --)
                shift
                while [[ $# -gt 0 ]]; do
                    WORK_ITEMS+=("$1")
                    shift
                done
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information." >&2
                exit 1
                ;;
        esac
    done
}

# --------------------------------------------------------------------------- #
# Validation
# --------------------------------------------------------------------------- #

validate_args() {
    # Check for nested orchestration
    if [[ -n "${ORCHESTRATOR_SESSION:-}" ]]; then
        log_error "Nested orchestration detected (ORCHESTRATOR_SESSION is set)."
        log_error "Cannot run orchestrate.sh from within an orchestrated session."
        exit 1
    fi

    # Validate max-workers
    if ! [[ "$MAX_WORKERS" =~ ^[1-5]$ ]]; then
        log_error "--max-workers must be between 1 and $MAX_WORKERS_LIMIT (got: $MAX_WORKERS)"
        exit 1
    fi

    # Validate max-budget-usd
    if ! [[ "$MAX_BUDGET_USD" =~ ^[0-9]+$ ]] || [[ "$MAX_BUDGET_USD" -lt 1 ]]; then
        log_error "--max-budget-usd must be a positive integer (got: $MAX_BUDGET_USD)"
        exit 1
    fi

    # If recovering, skip work item validation
    if [[ -n "$RECOVER_ID" ]]; then
        return 0
    fi

    # If cleaning stale, skip work item validation
    if [[ "$CLEANUP_STALE" == true ]]; then
        return 0
    fi

    # Must have work items
    if [[ ${#WORK_ITEMS[@]} -eq 0 ]]; then
        log_error "No work items provided. Use -- to separate options from work items."
        echo "Example: ./scripts/orchestrate.sh -- \"fix #801\" \"prd audio retry\"" >&2
        exit 1
    fi

    # Cap workers to item count
    if [[ ${#WORK_ITEMS[@]} -lt "$MAX_WORKERS" ]]; then
        MAX_WORKERS=${#WORK_ITEMS[@]}
        log_info "Adjusted --max-workers to ${MAX_WORKERS} (matching work item count)"
    fi

    # Validate base branch if specified
    if [[ -n "$BASE_BRANCH" ]]; then
        if ! git -C "$REPO_ROOT" rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
            log_error "Base branch '$BASE_BRANCH' does not exist."
            exit 1
        fi
    fi
}

validate_prerequisites() {
    local missing=()

    if ! command -v tmux >/dev/null 2>&1; then
        missing+=("tmux")
    fi

    if ! command -v claude >/dev/null 2>&1; then
        missing+=("claude (Claude Code CLI)")
    fi

    if ! command -v git >/dev/null 2>&1; then
        missing+=("git")
    fi

    if ! command -v openssl >/dev/null 2>&1; then
        missing+=("openssl")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi

    # Must be in a git repo
    if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_error "Not inside a git repository: $REPO_ROOT"
        exit 1
    fi

    # Ensure worktree base directory exists
    mkdir -p "$WORKTREE_BASE"
    mkdir -p "$MANIFEST_DIR"
}

# --------------------------------------------------------------------------- #
# Work Item Classification
# --------------------------------------------------------------------------- #

classify_work_item() {
    local item="$1"
    local lower
    lower="$(echo "$item" | tr '[:upper:]' '[:lower:]')"

    if [[ "$lower" =~ ^(fix|bug|issue)[[:space:]]+#?[0-9] ]]; then
        echo "bug-to-pr"
    elif [[ "$lower" =~ ^(prd|build|implement)[[:space:]] ]]; then
        echo "prd-to-pr"
    elif [[ "$lower" =~ ^triage[[:space:]] ]]; then
        echo "triage"
    else
        echo "unknown"
    fi
}

sanitize_branch_name() {
    local item="$1"
    local prefix="$2"
    local sanitized

    sanitized="$(echo "$item" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[^a-z0-9._/-]/-/g' -e 's/--*/-/g' -e 's/^-//;s/-$//' \
        | cut -c1-50)"

    local candidate="orch/${prefix}/${sanitized}"
    if git -C "$REPO_ROOT" check-ref-format --branch "$candidate" >/dev/null 2>&1; then
        echo "$candidate"
    else
        # Fallback to a hash-based name
        local hash
        hash="$(echo "$item" | openssl dgst -sha256 | cut -c1-8)"
        echo "orch/${prefix}/${hash}"
    fi
}

# --------------------------------------------------------------------------- #
# Session Management
# --------------------------------------------------------------------------- #

generate_session_id() {
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M)"
    local rand
    rand="$(openssl rand -hex 2)"
    SESSION_ID="orch-${timestamp}-${rand}"
    SESSION_DIR="$MANIFEST_DIR/$SESSION_ID"
    STATUS_DIR="$SESSION_DIR/status"
    TMUX_SESSION="$SESSION_ID"
}

create_session_manifest() {
    mkdir -p "$SESSION_DIR" "$STATUS_DIR"

    local manifest="$SESSION_DIR/manifest.json"
    local items_json="["
    local first=true
    for i in "${!WORK_ITEMS[@]}"; do
        local item="${WORK_ITEMS[$i]}"
        local classification="${WORK_ITEM_CLASSIFICATIONS[$i]}"

        if [[ "$first" == true ]]; then
            first=false
        else
            items_json+=","
        fi
        local escaped_item
        escaped_item="${item//\"/\\\"}"
        items_json+="$(cat <<JSON
{
      "index": $i,
      "description": "$escaped_item",
      "classification": "$classification",
      "status": "pending",
      "branch": "",
      "worktree": ""
    }
JSON
)"
    done
    items_json+="]"

    cat > "$manifest" <<JSON
{
  "session_id": "$SESSION_ID",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "repo_root": "$REPO_ROOT",
  "base_branch": "${BASE_BRANCH:-$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)}",
  "base_commit": "$(git -C "$REPO_ROOT" rev-parse HEAD)",
  "max_workers": $MAX_WORKERS,
  "max_budget_usd": $MAX_BUDGET_USD,
  "work_items": $items_json
}
JSON

    log_info "Manifest written: $manifest"
}

# --------------------------------------------------------------------------- #
# Worktree Management
# --------------------------------------------------------------------------- #

prune_worktrees() {
    log_info "Pruning stale git worktrees..."
    git -C "$REPO_ROOT" worktree prune 2>/dev/null || true
}

create_worktree() {
    local worker_index="$1"
    local branch_name="$2"
    local worktree_path="$WORKTREE_BASE/orch-${SESSION_ID}/worker-${worker_index}"

    local base_ref="${BASE_BRANCH:-HEAD}"

    # Retry up to 3 times for lock contention
    local attempt=0
    local max_attempts=3
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))

        if git -C "$REPO_ROOT" worktree add -b "$branch_name" "$worktree_path" "$base_ref" 2>/dev/null; then
            echo "$worktree_path"
            return 0
        fi

        # Check if branch already exists (maybe from a previous failed attempt)
        if git -C "$REPO_ROOT" rev-parse --verify "$branch_name" >/dev/null 2>&1; then
            # Branch exists - try without -b
            if git -C "$REPO_ROOT" worktree add "$worktree_path" "$branch_name" 2>/dev/null; then
                echo "$worktree_path"
                return 0
            fi
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            log_warn "Worktree creation attempt $attempt failed (lock?), retrying in 2s..."
            sleep 2
            git -C "$REPO_ROOT" worktree prune 2>/dev/null || true
        fi
    done

    log_error "Failed to create worktree after $max_attempts attempts: $worktree_path"
    return 1
}

cleanup_stale_worktrees() {
    log_step "Cleaning up stale orchestrator worktrees..."

    prune_worktrees

    local orch_dir="$WORKTREE_BASE"
    local cleaned=0

    # Find orchestrator worktree directories
    for dir in "$orch_dir"/orch-*/; do
        [[ -d "$dir" ]] || continue

        local session_name
        session_name="$(basename "$dir")"

        # Check if there is a tmux session for this
        if tmux has-session -t "$session_name" 2>/dev/null; then
            log_info "Skipping $session_name (tmux session still active)"
            continue
        fi

        # Check for dirty state in any worker worktree
        local has_dirty=false
        for worker_dir in "$dir"/worker-*/; do
            [[ -d "$worker_dir" ]] || continue
            if [[ -d "$worker_dir/.git" ]] || [[ -f "$worker_dir/.git" ]]; then
                if ! git -C "$worker_dir" diff --quiet 2>/dev/null || \
                   ! git -C "$worker_dir" diff --cached --quiet 2>/dev/null; then
                    has_dirty=true
                    log_warn "Dirty worktree: $worker_dir"
                fi
            fi
        done

        if [[ "$has_dirty" == true ]]; then
            log_warn "Skipping $session_name (has uncommitted changes)"
            log_warn "  Manually inspect and remove: rm -rf $dir"
            continue
        fi

        # Safe to remove
        for worker_dir in "$dir"/worker-*/; do
            [[ -d "$worker_dir" ]] || continue
            git -C "$REPO_ROOT" worktree remove --force "$worker_dir" 2>/dev/null || \
                rm -rf "$worker_dir"
        done
        rmdir "$dir" 2>/dev/null || rm -rf "$dir"
        cleaned=$((cleaned + 1))
        log_info "Removed: $session_name"
    done

    prune_worktrees
    log_info "Cleaned $cleaned stale orchestrator worktree(s)."
}

# --------------------------------------------------------------------------- #
# Worker Prompt Rendering
# --------------------------------------------------------------------------- #

render_worker_prompt() {
    local worker_index="$1"
    local work_item="$2"
    local classification="$3"
    local prompt_file="$SESSION_DIR/worker-${worker_index}-prompt.md"

    cat > "$prompt_file" <<PROMPT
# Orchestrated Worker ${worker_index}

You are worker-${worker_index} in orchestration session ${SESSION_ID}.

## Environment
- **Session**: ${SESSION_ID}
- **Worker**: ${worker_index}
- **Work Item**: ${work_item}
- **Classification**: ${classification}
- **Budget**: \$${MAX_BUDGET_USD} USD max

## Rules
1. You are running in a dedicated git worktree. Do NOT modify the main worktree.
2. Work ONLY on your assigned work item. Do not touch unrelated code.
3. Create commits on your branch. Do not push unless explicitly completing a PR.
4. If you need clarification, write to: ${STATUS_DIR}/worker-${worker_index}-blocked.txt
5. When done, write "complete" to: ${STATUS_DIR}/worker-${worker_index}-status.txt

## Status Protocol
Write status updates atomically:
\`\`\`bash
echo "STATUS_TEXT" > /tmp/orch-status-tmp-${worker_index} && mv /tmp/orch-status-tmp-${worker_index} ${STATUS_DIR}/worker-${worker_index}-status.txt
\`\`\`

Valid statuses: ready, working, blocked, complete, failed

## Anti-Nesting Guard
Do NOT invoke /workflow-orchestrator or orchestrate.sh. You are already inside an orchestration.
PROMPT

    echo "$prompt_file"
}

# --------------------------------------------------------------------------- #
# Tmux Layout
# --------------------------------------------------------------------------- #

create_tmux_layout() {
    local num_workers="$1"

    log_step "Creating tmux session: $TMUX_SESSION"

    # 1. Create detached session. Pane 0 = personal terminal (leftmost).
    tmux new-session -d -s "$TMUX_SESSION" -x 260 -y 60

    # Capture pane 0 (personal terminal / orchestrator runner)
    local pane0
    pane0="$(tmux list-panes -t "$TMUX_SESSION" -F '#{pane_id}' | head -1)"

    # 2. Split right for the main work area (~60% right, ~40% left for orchestrator col)
    #    Left = orchestrator status column, Right = everything else
    ORCHESTRATOR_PANE="$(tmux split-window -t "$pane0" -h -p 60 \
        -P -F '#{pane_id}' -t "$TMUX_SESSION")"

    # pane0=left (orchestrator), ORCHESTRATOR_PANE=right (to be split further)
    local right_side="$ORCHESTRATOR_PANE"
    ORCHESTRATOR_PANE="$pane0"

    # 3. Split the right side into middle (workers) and far-right (terminal+codex)
    #    Far-right gets ~30% of the right portion
    local far_right
    far_right="$(tmux split-window -t "$right_side" -h -p 30 \
        -P -F '#{pane_id}' -t "$TMUX_SESSION")"

    # right_side is now the middle (workers) column
    local middle_col="$right_side"

    # 4. Split far-right into terminal (top) and codex (bottom)
    CODEX_PANE="$(tmux split-window -t "$far_right" -v -p 50 \
        -P -F '#{pane_id}' -t "$TMUX_SESSION")"
    TERMINAL_PANE="$far_right"

    # 5. Stack workers vertically in the middle column
    WORKER_PANES=()
    if [[ $num_workers -ge 1 ]]; then
        WORKER_PANES+=("$middle_col")  # First worker gets the existing middle pane
    fi

    local split_target="$middle_col"
    for ((i = 1; i < num_workers; i++)); do
        # Calculate percentage for even distribution
        # Each subsequent split needs a larger percentage to maintain equal sizes
        local pct=$(( 100 * (num_workers - i) / (num_workers - i + 1) ))
        # Invert: we want the NEW pane to be the bottom portion
        pct=$((100 - pct))
        if [[ $pct -lt 10 ]]; then
            pct=20
        fi
        if [[ $pct -gt 90 ]]; then
            pct=80
        fi

        local new_pane
        new_pane="$(tmux split-window -t "$split_target" -v -p "$pct" \
            -P -F '#{pane_id}' -t "$TMUX_SESSION")"
        WORKER_PANES+=("$new_pane")
        split_target="$new_pane"
    done

    # 6. Label panes for identification
    tmux select-pane -t "$ORCHESTRATOR_PANE" -T "orchestrator"
    tmux select-pane -t "$TERMINAL_PANE" -T "terminal"
    tmux select-pane -t "$CODEX_PANE" -T "codex"
    for i in "${!WORKER_PANES[@]}"; do
        tmux select-pane -t "${WORKER_PANES[$i]}" -T "worker-$i"
    done

    # Enable pane titles
    tmux set-option -t "$TMUX_SESSION" pane-border-status top 2>/dev/null || true
    tmux set-option -t "$TMUX_SESSION" pane-border-format \
        " #{pane_title} " 2>/dev/null || true

    # Focus the orchestrator pane
    tmux select-pane -t "$ORCHESTRATOR_PANE"

    log_info "Layout created with ${num_workers} worker pane(s)"
    log_info "  Orchestrator: $ORCHESTRATOR_PANE"
    log_info "  Workers: ${WORKER_PANES[*]}"
    log_info "  Terminal: $TERMINAL_PANE"
    log_info "  Codex: $CODEX_PANE"
}

# --------------------------------------------------------------------------- #
# Worker Launch
# --------------------------------------------------------------------------- #

launch_worker() {
    local worker_index="$1"
    local work_item="$2"
    local classification="$3"
    local pane_id="$4"
    local worktree_path="$5"
    local prompt_file="$6"

    log_info "Launching worker-${worker_index}: ${work_item}"

    # Write initial status
    local tmp_status="/tmp/orch-status-tmp-${worker_index}-$$"
    echo "launching" > "$tmp_status" && mv "$tmp_status" "$STATUS_DIR/worker-${worker_index}-status.txt"

    if [[ "$DRY_RUN" == true ]]; then
        tmux send-keys -t "$pane_id" \
            "echo '[DRY RUN] Worker ${worker_index}: ${work_item}'; echo 'Worktree: ${worktree_path}'; echo 'Classification: ${classification}'; echo 'Would launch claude here.'; bash" Enter
        echo "ready" > "$tmp_status" && mv "$tmp_status" "$STATUS_DIR/worker-${worker_index}-status.txt"
        return 0
    fi

    # Build the claude command
    local claude_cmd="cd '${worktree_path}' && ORCHESTRATOR_SESSION='${SESSION_ID}' claude"
    claude_cmd+=" --dangerously-skip-permissions"
    claude_cmd+=" --bare"
    claude_cmd+=" --append-system-prompt-file '${prompt_file}'"
    claude_cmd+=" --max-budget-usd ${MAX_BUDGET_USD}"

    # Send the command to the tmux pane
    tmux send-keys -t "$pane_id" "$claude_cmd" Enter

    # Wait for Claude to be ready (poll status file or pane output)
    log_info "Waiting for worker-${worker_index} to be ready (timeout: ${WORKER_READY_TIMEOUT}s)..."
    local elapsed=0
    while [[ $elapsed -lt $WORKER_READY_TIMEOUT ]]; do
        # Check if pane is still alive
        if ! tmux list-panes -t "$TMUX_SESSION" -F '#{pane_id}' 2>/dev/null | grep -q "^${pane_id}$"; then
            log_error "Worker-${worker_index} pane died during startup"
            return 1
        fi

        # Check pane content for the Claude prompt indicator ($ or >)
        local pane_content
        pane_content="$(tmux capture-pane -t "$pane_id" -p -S -5 2>/dev/null || true)"
        if echo "$pane_content" | grep -qE '(^>|Human:|claude)' 2>/dev/null; then
            break
        fi

        sleep "$WORKER_READY_POLL"
        elapsed=$((elapsed + WORKER_READY_POLL))
    done

    if [[ $elapsed -ge $WORKER_READY_TIMEOUT ]]; then
        log_warn "Worker-${worker_index} did not show ready indicator within timeout (proceeding anyway)"
    fi

    # Mark ready
    echo "ready" > "$tmp_status" && mv "$tmp_status" "$STATUS_DIR/worker-${worker_index}-status.txt"

    # Inject the skill command if we have a classification
    local skill_cmd=""
    case "$classification" in
        bug-to-pr)   skill_cmd="/bug-to-pr ${work_item}" ;;
        prd-to-pr)   skill_cmd="/prd-to-pr ${work_item}" ;;
        triage)      skill_cmd="/triage ${work_item}" ;;
        unknown)     skill_cmd="${work_item}" ;;
    esac

    if [[ -n "$skill_cmd" ]]; then
        # Small delay to let Claude fully initialize
        sleep 2
        tmux send-keys -t "$pane_id" "$skill_cmd" Enter
        echo "working" > "$tmp_status" && mv "$tmp_status" "$STATUS_DIR/worker-${worker_index}-status.txt"
        log_info "Worker-${worker_index} started: $skill_cmd"
    fi

    return 0
}

# --------------------------------------------------------------------------- #
# Health Monitor
# --------------------------------------------------------------------------- #

start_health_monitor() {
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    (
        while true; do
            sleep "$HEALTH_CHECK_INTERVAL"

            # Check if tmux session still exists
            if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
                break
            fi

            # Capture pane health
            local health_file="$STATUS_DIR/pane-health.txt"
            local tmp_health="/tmp/orch-health-tmp-$$"
            tmux list-panes -t "$TMUX_SESSION" -F '#{pane_id}:#{pane_pid}:#{pane_current_command}:#{pane_dead}' \
                > "$tmp_health" 2>/dev/null && mv "$tmp_health" "$health_file"

            # Check each worker pane
            for i in "${!WORKER_PANES[@]}"; do
                local pane_id="${WORKER_PANES[$i]}"
                local status_file="$STATUS_DIR/worker-${i}-status.txt"

                # Is the pane still alive?
                if ! tmux list-panes -t "$TMUX_SESSION" -F '#{pane_id}' 2>/dev/null | grep -q "^${pane_id}$"; then
                    local alert_tmp="/tmp/orch-alert-tmp-${i}-$$"
                    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) DEAD worker-${i} pane=${pane_id}" \
                        > "$alert_tmp" && mv "$alert_tmp" "$STATUS_DIR/worker-${i}-alert.txt"
                fi

                # Check for stale heartbeat (worker hasn't updated status in 5 min)
                if [[ -f "$status_file" ]]; then
                    local file_age
                    # macOS stat
                    if stat -f %m "$status_file" >/dev/null 2>&1; then
                        local file_mtime
                        file_mtime="$(stat -f %m "$status_file")"
                        local now
                        now="$(date +%s)"
                        file_age=$((now - file_mtime))
                    else
                        file_age=0
                    fi

                    if [[ $file_age -gt 300 ]]; then
                        local current_status
                        current_status="$(cat "$status_file" 2>/dev/null || echo "unknown")"
                        if [[ "$current_status" != "complete" && "$current_status" != "failed" ]]; then
                            local alert_tmp="/tmp/orch-alert-tmp-stale-${i}-$$"
                            echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) STALE worker-${i} status=${current_status} age=${file_age}s" \
                                > "$alert_tmp" && mv "$alert_tmp" "$STATUS_DIR/worker-${i}-stale-alert.txt"
                        fi
                    fi
                fi
            done

            # Write summary timestamp
            local ts_tmp="/tmp/orch-ts-tmp-$$"
            date -u +%Y-%m-%dT%H:%M:%SZ > "$ts_tmp" && mv "$ts_tmp" "$STATUS_DIR/last-health-check.txt"
        done
    ) &
    MONITOR_PID=$!
    log_info "Health monitor started (PID: $MONITOR_PID, interval: ${HEALTH_CHECK_INTERVAL}s)"
}

# --------------------------------------------------------------------------- #
# Orchestrator Status Display
# --------------------------------------------------------------------------- #

display_status_in_pane() {
    if [[ -z "$ORCHESTRATOR_PANE" ]]; then
        return 0
    fi

    # Send a status display script to the orchestrator pane
    local status_script="$SESSION_DIR/status-display.sh"
    cat > "$status_script" <<'STATUSSCRIPT'
#!/usr/bin/env bash
STATUS_DIR="$1"
SESSION_ID="$2"
NUM_WORKERS="$3"

clear
while true; do
    tput cup 0 0 2>/dev/null || true
    echo -e "\033[1m=== Orchestrator: ${SESSION_ID} ===\033[0m"
    echo ""
    date '+%Y-%m-%d %H:%M:%S'
    echo ""

    for ((i = 0; i < NUM_WORKERS; i++)); do
        status_file="$STATUS_DIR/worker-${i}-status.txt"
        status="unknown"
        if [[ -f "$status_file" ]]; then
            status="$(cat "$status_file" 2>/dev/null || echo "unknown")"
        fi

        color="\033[0m"
        case "$status" in
            ready)      color="\033[0;34m" ;;
            working)    color="\033[0;33m" ;;
            complete)   color="\033[0;32m" ;;
            failed)     color="\033[0;31m" ;;
            blocked)    color="\033[0;35m" ;;
            launching)  color="\033[0;36m" ;;
        esac

        echo -e "  Worker ${i}: ${color}${status}\033[0m"

        if [[ -f "$STATUS_DIR/worker-${i}-alert.txt" ]]; then
            echo -e "    \033[0;31m$(cat "$STATUS_DIR/worker-${i}-alert.txt")\033[0m"
        fi
        if [[ -f "$STATUS_DIR/worker-${i}-blocked.txt" ]]; then
            echo -e "    \033[0;35mBLOCKED: $(cat "$STATUS_DIR/worker-${i}-blocked.txt")\033[0m"
        fi
    done

    echo ""
    if [[ -f "$STATUS_DIR/last-health-check.txt" ]]; then
        echo "Last health check: $(cat "$STATUS_DIR/last-health-check.txt")"
    fi

    sleep 5
done
STATUSSCRIPT
    chmod +x "$status_script"

    tmux send-keys -t "$ORCHESTRATOR_PANE" \
        "bash '${status_script}' '${STATUS_DIR}' '${SESSION_ID}' '${#WORKER_PANES[@]}'" Enter
}

# --------------------------------------------------------------------------- #
# Cost Estimation & Confirmation
# --------------------------------------------------------------------------- #

confirm_launch() {
    local num_items=${#WORK_ITEMS[@]}
    local est_cost=$((num_items * COST_PER_WORKER_ESTIMATE))
    local max_cost=$((num_items * MAX_BUDGET_USD))

    echo ""
    echo -e "${BOLD}=== Orchestration Plan ===${NC}"
    echo ""
    echo -e "  Session:     ${CYAN}${SESSION_ID}${NC}"
    echo -e "  Workers:     ${num_items} (max concurrent: ${MAX_WORKERS})"
    echo -e "  Budget:      \$${MAX_BUDGET_USD}/worker"
    echo ""
    echo -e "  ${BOLD}Work Items:${NC}"
    for i in "${!WORK_ITEMS[@]}"; do
        echo -e "    [$i] ${WORK_ITEMS[$i]}  ${BLUE}(${WORK_ITEM_CLASSIFICATIONS[$i]})${NC}"
    done
    echo ""
    echo -e "  ${BOLD}Cost Estimate:${NC}"
    echo -e "    Estimated: ~\$${est_cost} USD"
    echo -e "    Maximum:   \$${max_cost} USD (hard cap)"
    echo ""

    if [[ "$SKIP_CONFIRM" == true ]]; then
        log_info "Skipping confirmation (--yes)"
        return 0
    fi

    echo -n -e "  ${YELLOW}Proceed? [y/N]:${NC} "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        log_info "Cancelled by user."
        exit 0
    fi
}

# --------------------------------------------------------------------------- #
# Recovery
# --------------------------------------------------------------------------- #

recover_session() {
    local recover_id="$1"
    local manifest="$MANIFEST_DIR/$recover_id/manifest.json"

    if [[ ! -f "$manifest" ]]; then
        log_error "No manifest found for session: $recover_id"
        log_error "Expected: $manifest"

        # List available sessions
        echo "" >&2
        echo "Available sessions:" >&2
        for d in "$MANIFEST_DIR"/orch-*/; do
            [[ -d "$d" ]] || continue
            local name
            name="$(basename "$d")"
            local created=""
            if [[ -f "$d/manifest.json" ]]; then
                created="$(grep '"created_at"' "$d/manifest.json" | head -1 | sed 's/.*: "//;s/".*//' || true)"
            fi
            echo "  $name  ($created)" >&2
        done
        exit 1
    fi

    log_step "Recovering session: $recover_id"

    SESSION_ID="$recover_id"
    SESSION_DIR="$MANIFEST_DIR/$SESSION_ID"
    STATUS_DIR="$SESSION_DIR/status"
    TMUX_SESSION="$SESSION_ID"

    # Check if tmux session already exists
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        log_info "Tmux session '$TMUX_SESSION' already exists. Attaching..."
        tmux attach-session -t "$TMUX_SESSION"
        exit 0
    fi

    # Parse manifest for work items
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 required for manifest parsing during recovery"
        exit 1
    fi

    local items_json
    items_json="$(python3 -c "
import json, sys
with open('$manifest') as f:
    m = json.load(f)
for item in m['work_items']:
    status = item.get('status', 'pending')
    if status not in ('complete',):
        print(item['description'])
" 2>/dev/null)"

    if [[ -z "$items_json" ]]; then
        log_info "All work items in session $recover_id are complete. Nothing to recover."
        exit 0
    fi

    # Read config from manifest (single python3 invocation)
    local config_line
    config_line="$(python3 -c "
import json
with open('$manifest') as f:
    m = json.load(f)
print(m.get('max_workers', 3), m.get('max_budget_usd', 20), m.get('base_branch', 'HEAD'))
")"
    read -r MAX_WORKERS MAX_BUDGET_USD BASE_BRANCH <<< "$config_line"

    # Reload work items
    WORK_ITEMS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && WORK_ITEMS+=("$line")
    done <<< "$items_json"

    if [[ ${#WORK_ITEMS[@]} -eq 0 ]]; then
        log_info "No incomplete work items to recover."
        exit 0
    fi

    log_info "Recovering ${#WORK_ITEMS[@]} incomplete work item(s)"
    log_warn "Recovery creates NEW worktrees and workers. Previous worktree state is preserved but not reused."

    # Re-run the main flow with recovered items
    # (session ID is already set, so it will reuse the manifest dir)
    mkdir -p "$STATUS_DIR"
}

# --------------------------------------------------------------------------- #
# Cleanup
# --------------------------------------------------------------------------- #

cleanup() {
    local exit_code=$?
    log_step "Cleaning up session: ${SESSION_ID:-unknown}"

    # 1. Kill health monitor
    if [[ -n "${MONITOR_PID:-}" ]] && kill -0 "$MONITOR_PID" 2>/dev/null; then
        log_info "Stopping health monitor (PID: $MONITOR_PID)"
        kill "$MONITOR_PID" 2>/dev/null || true
        wait "$MONITOR_PID" 2>/dev/null || true
    fi

    # 2. Kill worker processes via pane PIDs
    if [[ -n "${TMUX_SESSION:-}" ]] && tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        for i in "${!WORKER_PANES[@]}"; do
            local pane_id="${WORKER_PANES[$i]}"
            local pane_pid
            pane_pid="$(tmux display-message -t "$pane_id" -p '#{pane_pid}' 2>/dev/null || true)"
            if [[ -n "$pane_pid" && "$pane_pid" != "0" ]]; then
                log_info "Killing worker-${i} process tree (PID: $pane_pid)"
                pkill -P "$pane_pid" 2>/dev/null || true
            fi
        done
    fi

    # 3. Check worktree dirty state before removal
    for i in "${!WORKER_WORKTREES[@]}"; do
        local wt="${WORKER_WORKTREES[$i]}"
        [[ -d "$wt" ]] || continue

        if [[ -d "$wt/.git" ]] || [[ -f "$wt/.git" ]]; then
            if ! git -C "$wt" diff --quiet 2>/dev/null || \
               ! git -C "$wt" diff --cached --quiet 2>/dev/null; then
                log_warn "Worker-${i} worktree has uncommitted changes: $wt"
                log_warn "  Preserving worktree. Clean up manually when ready."
                continue
            fi
        fi

        # Clean worktree
        log_info "Removing worktree: $wt"
        git -C "$REPO_ROOT" worktree remove --force "$wt" 2>/dev/null || rm -rf "$wt"

        # Delete the branch if it was created by us
        if [[ -n "${WORKER_BRANCHES[$i]:-}" ]]; then
            git -C "$REPO_ROOT" branch -D "${WORKER_BRANCHES[$i]}" 2>/dev/null || true
        fi
    done

    # Remove the session worktree parent dir if empty
    local session_wt_dir="$WORKTREE_BASE/orch-${SESSION_ID}"
    if [[ -d "$session_wt_dir" ]]; then
        rmdir "$session_wt_dir" 2>/dev/null || true
    fi

    # Prune
    git -C "$REPO_ROOT" worktree prune 2>/dev/null || true

    # 4. Do NOT delete manifest (needed for --recover)
    if [[ -n "${SESSION_DIR:-}" && -d "$SESSION_DIR" ]]; then
        local ts
        ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        local tmp_ended="/tmp/orch-ended-tmp-$$"
        echo "$ts" > "$tmp_ended" && mv "$tmp_ended" "$SESSION_DIR/ended_at.txt"
        log_info "Session manifest preserved: $SESSION_DIR"
    fi

    # 5. Belt-and-suspenders: kill tmux session
    if [[ -n "${TMUX_SESSION:-}" ]] && tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        log_info "Killing tmux session: $TMUX_SESSION"
        tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true
    fi

    if [[ $exit_code -eq 0 ]]; then
        log_info "Cleanup complete."
    else
        log_warn "Cleanup complete (exit code: $exit_code)."
    fi
}

# --------------------------------------------------------------------------- #
# Main Orchestration Loop
# --------------------------------------------------------------------------- #

run_orchestration() {
    local num_items=${#WORK_ITEMS[@]}

    # Create tmux layout
    create_tmux_layout "$MAX_WORKERS"

    # Prepare and launch workers
    # If more items than workers, we queue the extras
    local queue_start=$MAX_WORKERS
    local active_count=0

    # Launch initial batch
    for ((i = 0; i < MAX_WORKERS && i < num_items; i++)); do
        local item="${WORK_ITEMS[$i]}"
        local classification="${WORK_ITEM_CLASSIFICATIONS[$i]}"
        local branch
        branch="$(sanitize_branch_name "$item" "$i")"
        local pane_id="${WORKER_PANES[$i]}"

        # Create worktree
        log_step "Creating worktree for worker-${i}..."
        local wt_path
        wt_path="$(create_worktree "$i" "$branch")"
        WORKER_WORKTREES+=("$wt_path")
        WORKER_BRANCHES+=("$branch")

        # Render prompt
        local prompt_file
        prompt_file="$(render_worker_prompt "$i" "$item" "$classification")"

        # Launch worker
        launch_worker "$i" "$item" "$classification" "$pane_id" "$wt_path" "$prompt_file"
        active_count=$((active_count + 1))
    done

    # Start health monitor
    start_health_monitor

    # Start status display in orchestrator pane
    display_status_in_pane

    # Attach to tmux session
    log_info ""
    log_info "All workers launched. Attaching to tmux session..."
    log_info "  Use Ctrl-B then D to detach (workers continue running)"
    log_info "  Use Ctrl-C here or close the session to trigger cleanup"
    log_info ""

    # If there are queued items beyond MAX_WORKERS, we monitor and launch them
    # as workers complete. This runs in the foreground.
    if [[ $queue_start -lt $num_items ]]; then
        log_info "Queued items waiting: $((num_items - queue_start))"

        # Background queue processor
        (
            local next_item=$queue_start
            while [[ $next_item -lt $num_items ]]; do
                sleep 10

                # Check for a completed worker we can reuse
                for ((w = 0; w < MAX_WORKERS; w++)); do
                    local status_file="$STATUS_DIR/worker-${w}-status.txt"
                    if [[ -f "$status_file" ]]; then
                        local status
                        status="$(cat "$status_file" 2>/dev/null || echo "")"
                        if [[ "$status" == "complete" || "$status" == "failed" ]]; then
                            # Reuse this worker slot for the next queued item
                            local item="${WORK_ITEMS[$next_item]}"
                            local classification
                            classification="$(classify_work_item "$item")"
                            local branch
                            branch="$(sanitize_branch_name "$item" "$next_item")"
                            local pane_id="${WORKER_PANES[$w]}"

                            log_info "Reusing worker-${w} for queued item: $item"

                            # Create new worktree for queued item
                            local wt_path
                            wt_path="$(create_worktree "$next_item" "$branch")" || continue
                            WORKER_WORKTREES+=("$wt_path")
                            WORKER_BRANCHES+=("$branch")

                            local prompt_file
                            prompt_file="$(render_worker_prompt "$w" "$item" "$classification")"

                            # Kill old process in pane and launch new
                            tmux send-keys -t "$pane_id" C-c 2>/dev/null || true
                            sleep 1
                            launch_worker "$w" "$item" "$classification" "$pane_id" "$wt_path" "$prompt_file"

                            next_item=$((next_item + 1))
                            break
                        fi
                    fi
                done
            done
        ) &
        local queue_pid=$!
    fi

    # Attach to tmux (this blocks until user detaches or session ends)
    tmux attach-session -t "$TMUX_SESSION"

    # If we get here, user detached. Wait a bit for queue processor.
    if [[ -n "${queue_pid:-}" ]] && kill -0 "$queue_pid" 2>/dev/null; then
        kill "$queue_pid" 2>/dev/null || true
        wait "$queue_pid" 2>/dev/null || true
    fi
}

# --------------------------------------------------------------------------- #
# Entry Point
# --------------------------------------------------------------------------- #

main() {
    parse_args "$@"

    # Handle --cleanup-stale
    if [[ "$CLEANUP_STALE" == true ]]; then
        validate_prerequisites
        cleanup_stale_worktrees
        exit 0
    fi

    validate_prerequisites
    validate_args

    # Handle --recover
    if [[ -n "$RECOVER_ID" ]]; then
        recover_session "$RECOVER_ID"
        # If recover_session returned (didn't exit or attach), fall through
        # to normal orchestration with the recovered work items
        if [[ ${#WORK_ITEMS[@]} -eq 0 ]]; then
            exit 0
        fi
    fi

    # Generate session ID if not recovering
    if [[ -z "$SESSION_ID" ]]; then
        generate_session_id
    fi

    # Classify all work items once (avoids repeated subshell forks)
    WORK_ITEM_CLASSIFICATIONS=()
    for item in "${WORK_ITEMS[@]}"; do
        WORK_ITEM_CLASSIFICATIONS+=("$(classify_work_item "$item")")
    done

    # Prune before creating new worktrees
    prune_worktrees

    # Create manifest
    create_session_manifest

    # Cost estimate and confirmation
    confirm_launch

    # Set up cleanup trap (must be after session ID is known)
    trap cleanup EXIT INT TERM HUP

    # Export session ID to prevent nesting
    export ORCHESTRATOR_SESSION="$SESSION_ID"

    # Run orchestration
    run_orchestration
}

main "$@"
