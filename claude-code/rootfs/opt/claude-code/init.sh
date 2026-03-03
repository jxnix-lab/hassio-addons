#!/usr/bin/with-contenv bashio
# ==============================================================================
# Claude Code Add-on: Initialization
# Sets up git, persistent config, and drops CLAUDE.md into /config
# Runs as root during s6 init, ttyd handles user switching at runtime
# ==============================================================================

CLAUDE_HOME="/home/claude"

# --- Persistent Claude config ---
# /data/ persists across addon restarts; image ships with .claude/ and
# .claude.json from the install step — remove them so the symlinks work
mkdir -p /data/.claude
chown claude:claude /data/.claude
rm -rf "${CLAUDE_HOME}/.claude"
ln -sf /data/.claude "${CLAUDE_HOME}/.claude"
# .claude.json lives inside CLAUDE_CONFIG_DIR (/data/.claude/) so no
# separate symlink needed — CLAUDE_CONFIG_DIR handles it

# --- Ensure claude user can write to /config ---
# Match claude user's uid/gid to /config owner so we don't change ownership
CONFIG_UID=$(stat -c %u /config)
CONFIG_GID=$(stat -c %g /config)
if [ "$CONFIG_UID" != "0" ]; then
    usermod -u "$CONFIG_UID" claude 2>/dev/null || true
    groupmod -g "$CONFIG_GID" claude 2>/dev/null || true
    chown -R claude:claude "${CLAUDE_HOME}" /data/.claude 2>/dev/null || true
fi

# --- Git config for claude user ---
su -s /bin/bash claude -c '
    git config --global init.defaultBranch main
    git config --global user.email "claude-code@homeassistant.local"
    git config --global user.name "Claude Code"
    git config --global --add safe.directory /config
'

# --- Git setup (only if no repo exists) ---
if [ ! -d /config/.git ]; then
    bashio::log.info "Initializing git repository in /config..."

    su -s /bin/bash claude -c 'cd /config && git init'

    # Create .gitignore
    cat > /config/.gitignore << 'GITIGNORE'
# Home Assistant internal databases
.storage/
home-assistant_v2.db
home-assistant_v2.db-shm
home-assistant_v2.db-wal

# Secrets - NEVER commit
secrets.yaml

# Cache and generated files
*.log
__pycache__/
.cloud/
tts/
.rhasspy/

# Backups
backups/

# OS metadata
.DS_Store
Thumbs.db

# Claude internal state (persisted in addon data)
.claude/
GITIGNORE

    chown claude:claude /config/.gitignore
    su -s /bin/bash claude -c 'cd /config && git add -A && git commit -m "Initial commit (by Claude Code addon)"'
    bashio::log.info "Git repository initialized with initial commit"
else
    bashio::log.info "Git repository already exists in /config"
fi

# --- Preseed Claude config (enable Remote Control) ---
CLAUDE_CONFIG="/data/.claude/.claude.json"
if [ ! -f "$CLAUDE_CONFIG" ]; then
    echo '{"remoteControlAtStartup": true}' > "$CLAUDE_CONFIG"
    chown claude:claude "$CLAUDE_CONFIG"
    bashio::log.info "Claude config preseeded with Remote Control enabled"
fi

# --- Drop CLAUDE.md (only if it doesn't exist) ---
if [ ! -f /config/CLAUDE.md ]; then
    cp /opt/claude-code/CLAUDE.md.tmpl /config/CLAUDE.md
    chown claude:claude /config/CLAUDE.md
    bashio::log.info "CLAUDE.md added to /config"
fi

bashio::log.info "Initialization complete"
