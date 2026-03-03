#!/bin/bash
# ==============================================================================
# Claude Code Add-on: Persistent session wrapper
# Runs Claude Code inside dtach, auto-restarts on exit
# Falls back to bash shell if not authenticated (first run)
# ==============================================================================

SOCKET="/tmp/claude-session.sock"

export HOME="/home/claude"
export PATH="/home/claude/.local/bin:${PATH}"
export CLAUDE_CONFIG_DIR="/home/claude/.claude"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export LANG="C.UTF-8"

cd /config

# Check if Claude is authenticated
is_authenticated() {
    claude auth status >/dev/null 2>&1
}

while true; do
    rm -f "$SOCKET"

    if is_authenticated; then
        # Authenticated — run Claude with session persistence
        dtach -N "$SOCKET" -r winch bash -c 'claude --continue || claude'
        echo "Claude exited, restarting in 2s..."
        sleep 2
    else
        # Not authenticated — drop into bash so user can run: claude auth login
        echo "=============================================="
        echo " Claude Code is not authenticated."
        echo " Run: claude auth login"
        echo " Then restart the add-on."
        echo "=============================================="
        dtach -N "$SOCKET" -r winch bash
        sleep 1
    fi
done
