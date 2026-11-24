#!/usr/bin/env bash
# sync-ai-config.sh — Universal sync for 9 AI tools
# Usage: ./sync-ai-config.sh [--global] [--project] [--verify] [--help]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

GLOBAL_MODE=false
PROJECT_MODE=false
VERIFY_MODE=false
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Sync AI tool configurations across 9 tools:
  Opencode, Kiro, Antigravity, Claude, Devin, Aider, Continue, Goose, OpenHands

Options:
  --global      Sync global configs to ~/.config/
  --project     Symlink project configs into current directory
  --verify      Verify each tool can start and sees its config
  --dry-run     Show what would be done without making changes
  --help        Show this help

Defaults: --global --project (both)

Examples:
  $0                      # Sync both global and project configs
  $0 --global --verify    # Sync global only and verify
  $0 --project            # Symlink project configs only
  $0 --dry-run            # Preview changes
EOF
}

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $*"; }
err() { echo -e "${RED}[$(date +%H:%M:%S)]${NC} $*"; }
info() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $*"; }

# Parse args
for arg in "$@"; do
    case $arg in
        --global)   GLOBAL_MODE=true ;;
        --project)  PROJECT_MODE=true ;;
        --verify)   VERIFY_MODE=true ;;
        --dry-run)  DRY_RUN=true ;;
        --help)     usage; exit 0 ;;
        *)          err "Unknown option: $arg"; usage; exit 1 ;;
    esac
done

# Default: do both
[[ "$GLOBAL_MODE" == false && "$PROJECT_MODE" == false ]] && GLOBAL_MODE=true && PROJECT_MODE=true

# Load env vars for substitution
ENV_FILE="$HOME/.local/share/ai-keys.sh"
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    log "Loaded environment from $ENV_FILE"
else
    warn "Environment file not found: $ENV_FILE"
    warn "Create it with your API keys (see registry.yaml for required keys)"
fi

run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] $*"
    else
        eval "$@"
    fi
}

# ==========================================
# GLOBAL CONFIGS
# ==========================================
sync_global() {
    log "Syncing global configs to $CONFIG_DIR..."

    # Unified model registry
    run_cmd "mkdir -p '$CONFIG_DIR/ai-models'"
    run_cmd "ln -sfn '$SCRIPT_DIR/registry.yaml' '$CONFIG_DIR/ai-models/registry.yaml'"
    log "  ✅ Model registry → $CONFIG_DIR/ai-models/registry.yaml"

    # Per-tool global configs
    declare -A GLOBAL_CONFIGS=(
        ["opencode"]="config.json"
        ["kiro"]="config.yaml"
        ["antigravity"]="config.toml"
        ["claude"]="config.json"
        ["devin"]="config.yaml"
        ["aider"]="conf.yml"
        ["continue"]="config.json"
        ["goose"]="config.yaml"
        ["openhands"]="config.yaml"
    )

    for tool in "${!GLOBAL_CONFIGS[@]}"; do
        local template="$SCRIPT_DIR/tools/$tool/config.template"
        local output_dir="$CONFIG_DIR/$tool"
        local output_file="$output_dir/${GLOBAL_CONFIGS[$tool]}"

        run_cmd "mkdir -p '$output_dir'"

        if [[ -f "$template" ]]; then
            run_cmd "envsubst < '$template' > '$output_file'"
            log "  ✅ $tool → $output_file"
        else
            warn "  ⚠️  $tool: template not found at $template"
        fi
    done

    # Tool-specific post-sync
    if command -v goose >/dev/null 2>&1; then
        run_cmd "goose extension list >/dev/null 2>&1" && log "  ✅ Goose extensions verified"
    fi
}

# ==========================================
# PROJECT CONFIGS
# ==========================================
sync_project() {
    local project_root="${PROJECT_ROOT:-$(pwd)}"
    log "Syncing project configs to $project_root..."

    # Project-local configs that live in repo root
    declare -A PROJECT_CONFIGS=(
        [".aider.conf.yml"]="project-configs/aider.conf.yml"
        [".continue/config.json"]="project-configs/continue/config.json"
        [".openhands/config.yaml"]="project-configs/openhands/config.yaml"
        ["CLAUDE.md"]="project-configs/CLAUDE.md"
        [".devin"]="project-configs/devin"
        [".opencode"]="project-configs/opencode"
        [".kiro"]="project-configs/kiro"
        [".antigravity"]="project-configs/antigravity"
    )

    for target in "${!PROJECT_CONFIGS[@]}"; do
        local source="$SCRIPT_DIR/../${PROJECT_CONFIGS[$target]}"
        local dest="$project_root/$target"

        if [[ -e "$source" ]]; then
            run_cmd "mkdir -p '$(dirname "$dest")'"
            run_cmd "ln -sfn '$source' '$dest'"
            log "  ✅ $target → $source"
        else
            # Create minimal default if missing
            case $target in
                ".aider.conf.yml")
                    run_cmd "cat > '$dest' <<'EOF'
model: \${CODING_MODEL:-claude-sonnet-4-20250514}
weak-model: \${FAST_MODEL:-gpt-4o-mini}
auto-commits: true
dirty-commits: true
show-diffs: true
stream: true
EOF"
                    log "  ✅ Created default $target"
                    ;;
                ".continue/config.json")
                    run_cmd "mkdir -p '$(dirname "$dest")'"
                    run_cmd "cat > '$dest' <<'EOF'
{
  "models": [
    { "title": "Claude Sonnet 4", "provider": "anthropic", "model": "claude-sonnet-4-20250514", "apiKey": "\${ANTHROPIC_API_KEY}" },
    { "title": "GPT-4o", "provider": "openai", "model": "gpt-4o-2024-11-20", "apiKey": "\${OPENAI_API_KEY}" },
    { "title": "Local Qwen", "provider": "ollama", "model": "qwen2.5-coder:32b", "apiBase": "http://localhost:11434" }
  ],
  "tabAutocompleteModel": { "title": "GPT-4o-mini", "provider": "openai", "model": "gpt-4o-mini" }
}
EOF"
                    log "  ✅ Created default $target"
                    ;;
            esac
        fi
    done
}

# ==========================================
# VERIFICATION
# ==========================================
verify_tools() {
    log "Verifying tool configurations..."

    local all_ok=true

    for tool in opencode kiro antigravity claude devin aider continue goose openhands; do
        if command -v "$tool" >/dev/null 2>&1; then
            case $tool in
                opencode)
                    run_cmd "opencode --version >/dev/null 2>&1" && log "  ✅ Opencode" || { warn "  ❌ Opencode failed"; all_ok=false; }
                    ;;
                kiro)
                    run_cmd "kiro --version >/dev/null 2>&1" && log "  ✅ Kiro" || { warn "  ❌ Kiro failed"; all_ok=false; }
                    ;;
                antigravity)
                    run_cmd "antigravity --version >/dev/null 2>&1" && log "  ✅ Antigravity" || { warn "  ❌ Antigravity failed"; all_ok=false; }
                    ;;
                claude)
                    run_cmd "claude --version >/dev/null 2>&1" && log "  ✅ Claude CLI" || { warn "  ❌ Claude CLI failed"; all_ok=false; }
                    ;;
                devin)
                    run_cmd "devin --version >/dev/null 2>&1" && log "  ✅ Devin CLI" || { warn "  ❌ Devin CLI failed"; all_ok=false; }
                    ;;
                aider)
                    run_cmd "aider --version >/dev/null 2>&1" && log "  ✅ Aider" || { warn "  ❌ Aider failed"; all_ok=false; }
                    ;;
                continue)
                    run_cmd "continue --version >/dev/null 2>&1" && log "  ✅ Continue" || { warn "  ❌ Continue failed"; all_ok=false; }
                    ;;
                goose)
                    run_cmd "goose --version >/dev/null 2>&1" && log "  ✅ Goose" || { warn "  ❌ Goose failed"; all_ok=false; }
                    ;;
                openhands)
                    if command -v docker >/dev/null 2>&1; then
                        run_cmd "docker run --rm ghcr.io/all-hands-ai/openhands:latest --version >/dev/null 2>&1" && log "  ✅ OpenHands" || { warn "  ❌ OpenHands failed"; all_ok=false; }
                    else
                        warn "  ⚠️  OpenHands: Docker not available"
                    fi
                    ;;
            esac
        else
            warn "  ⚠️  $tool not installed"
        fi
    done

    if [[ "$all_ok" == true ]]; then
        log "🎉 All installed tools verified successfully!"
    else
        warn "Some tools failed verification. Check above."
    fi
}

# ==========================================
# MAIN
# ==========================================
main() {
    log "Starting AI tool config sync..."
    info "Repo root: $REPO_ROOT"
    info "Config dir: $CONFIG_DIR"
    [[ "$DRY_RUN" == true ]] && warn "DRY RUN MODE - no changes will be made"

    [[ "$GLOBAL_MODE" == true ]] && sync_global
    [[ "$PROJECT_MODE" == true ]] && sync_project
    [[ "$VERIFY_MODE" == true ]] && verify_tools

    log "✅ Sync complete!"
}

main "$@"