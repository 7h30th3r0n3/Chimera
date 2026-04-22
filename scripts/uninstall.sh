#!/usr/bin/env bash
set -euo pipefail

# Chimera uninstaller — removes hybrid Claude + Codex rules from your Claude Code config

GLOBAL_RULE="$HOME/.claude/rules/chimera.md"
PROJECT_RULE=".claude/rules/chimera.md"

usage() {
    echo "Usage: $0 [--global | --project | --all]"
    echo ""
    echo "  --global   Remove from ~/.claude/rules/"
    echo "  --project  Remove from ./.claude/rules/"
    echo "  --all      Remove from both locations"
    echo ""
    echo "No flag: interactive prompt"
}

remove_from() {
    local path="$1"
    local label="$2"
    if [ -f "$path" ]; then
        rm "$path"
        echo "[OK] Removed $label ($path)"
    else
        echo "[~] Not found: $path — skipping"
    fi
}

detect_installs() {
    local found=0
    if [ -f "$GLOBAL_RULE" ]; then
        echo "  [G] Global:  $GLOBAL_RULE"
        found=1
    fi
    if [ -f "$PROJECT_RULE" ]; then
        echo "  [P] Project: $PROJECT_RULE"
        found=1
    fi
    if [ "$found" -eq 0 ]; then
        echo "  No Chimera installation found."
        exit 0
    fi
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

echo "=== Chimera Uninstaller ==="
echo ""
echo "Detected installations:"
detect_installs
echo ""

if [[ "${1:-}" == "--global" ]]; then
    remove_from "$GLOBAL_RULE" "global rules"
elif [[ "${1:-}" == "--project" ]]; then
    remove_from "$PROJECT_RULE" "project rules"
elif [[ "${1:-}" == "--all" ]]; then
    remove_from "$GLOBAL_RULE" "global rules"
    remove_from "$PROJECT_RULE" "project rules"
else
    echo "What to remove?"
    echo ""
    echo "  1) Global  (~/.claude/rules/chimera.md)"
    echo "  2) Project (./.claude/rules/chimera.md)"
    echo "  3) All installations"
    echo ""
    read -rp "Choice [1/2/3]: " choice
    case "$choice" in
        1) remove_from "$GLOBAL_RULE" "global rules" ;;
        2) remove_from "$PROJECT_RULE" "project rules" ;;
        3)
            remove_from "$GLOBAL_RULE" "global rules"
            remove_from "$PROJECT_RULE" "project rules"
            ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

echo ""
echo "Done. Chimera rules removed. Claude Code will use its default sub-agents."
