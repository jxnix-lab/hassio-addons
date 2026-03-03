#!/bin/bash
# ==============================================================================
# Claude Code Add-on: Persistent session wrapper
# Runs Claude Code inside dtach, auto-restarts on exit
# ==============================================================================

SOCKET="/tmp/claude-session.sock"

export HOME="/home/claude"
export PATH="/home/claude/.local/bin:${PATH}"
export CLAUDE_CONFIG_DIR="/home/claude/.claude"

cd /config

while true; do
    # Clean up stale socket
    rm -f "$SOCKET"

    # Run Claude detached (-N = don't attach, block until exit)
    # --continue resumes the most recent conversation
    dtach -N "$SOCKET" -r winch claude --continue

    echo "Claude exited, restarting in 2s..."
    sleep 2
done
