#!/bin/bash
# ==============================================================================
# Claude Code Add-on: ttyd wrapper
# Attaches to the persistent Claude session via dtach
# ==============================================================================

SOCKET="/tmp/claude-session.sock"

export HOME="/home/claude"
export PATH="/home/claude/.local/bin:/opt/claude-code:${PATH}"
export CLAUDE_CONFIG_DIR="/home/claude/.claude"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export LANG="C.UTF-8"

# Wait for the dtach socket to be created by claude-session service
while [ ! -S "$SOCKET" ]; do
    sleep 0.5
done

exec dtach -a "$SOCKET" -r winch
