#!/usr/bin/env bash
set -euo pipefail

# Chimera installer — adds hybrid Claude + Codex rules to your Claude Code config

CHIMERA_RULE="$(dirname "$0")/../.claude/rules/chimera.md"
GLOBAL_RULES_DIR="$HOME/.claude/rules"
PROJECT_RULES_DIR=".claude/rules"

usage() {
    echo "Usage: $0 [--global | --project]"
    echo ""
    echo "  --global   Install to ~/.claude/rules/ (all sessions)"
    echo "  --project  Install to ./.claude/rules/ (current project only)"
    echo ""
    echo "No flag: interactive prompt"
}

install_to() {
    local dest_dir="$1"
    mkdir -p "$dest_dir"
    cp "$CHIMERA_RULE" "$dest_dir/chimera.md"
    echo "[OK] Chimera rules installed to $dest_dir/chimera.md"
}

check_prereqs() {
    local missing=0
    if ! command -v claude &>/dev/null; then
        echo "[!] Claude Code not found. Install: npm install -g @anthropic-ai/claude-code"
        missing=1
    fi
    if ! command -v codex &>/dev/null; then
        echo "[!] Codex CLI not found. Install: npm install -g codex"
        missing=1
    fi
    if [ "$missing" -eq 1 ]; then
        echo ""
        echo "Chimera requires both Claude Code and Codex CLI."
        read -rp "Continue anyway? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
    fi
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

echo "=== Chimera Installer ==="
echo ""

check_prereqs

if [[ "${1:-}" == "--global" ]]; then
    install_to "$GLOBAL_RULES_DIR"
elif [[ "${1:-}" == "--project" ]]; then
    install_to "$PROJECT_RULES_DIR"
else
    echo "Where to install Chimera rules?"
    echo ""
    echo "  1) Global  (~/.claude/rules/) — all Claude Code sessions"
    echo "  2) Project (./.claude/rules/) — current project only"
    echo ""
    read -rp "Choice [1/2]: " choice
    case "$choice" in
        1) install_to "$GLOBAL_RULES_DIR" ;;
        2) install_to "$PROJECT_RULES_DIR" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

echo ""
echo "Done! Start a Claude Code session and it will automatically use Codex as a sub-agent."
echo "Test it: ask Claude to delegate a code review to Codex."
