# Claude Code for Home Assistant

Run [Claude Code](https://claude.ai/claude-code) as a Home Assistant add-on, giving you an AI-powered terminal assistant with full access to your HA configuration.

## What it does

This add-on runs a persistent Claude Code session that starts automatically with Home Assistant. Claude can:

- Read and edit your Home Assistant YAML configuration
- Create and modify automations, scripts, and scenes
- Debug configuration issues and validate changes
- Use git to track all changes with easy rollback

## Getting started

1. **Install** the add-on from the add-on store
2. **Start** the add-on — Claude Code launches automatically
3. **Open** the "Claude Code" panel in your HA sidebar
4. **Authenticate** — on first run, follow the OAuth flow to sign in with your Anthropic account
5. **Enable Remote Control** (optional) — access your session from claude.ai/code or the Claude mobile app

## How it works

- **Persistent session** — Claude runs continuously in the background via `dtach`. Closing the browser tab doesn't kill the session; reopening it reattaches instantly.
- **Auto-restart** — if Claude exits (via `/exit`, crash, or network timeout), it automatically restarts and resumes the previous conversation with `--continue`.
- **Remote Control** — enabled by default. Access your session from any device via [claude.ai/code](https://claude.ai/code) or the Claude mobile app.
- **Git tracking** — git is automatically initialized in `/config` if not already set up, so all changes are tracked and reversible.
- **CLAUDE.md** — a context file is placed in `/config` to give Claude knowledge of Home Assistant conventions and safety guardrails.
- **Non-root** — Claude runs as a non-root user to avoid changing file ownership in `/config`.
- **Persistent config** — authentication, session history, and memory persist across add-on restarts (stored in `/data`).

## Safety

- Claude is instructed to **always validate** config with `ha core check` before applying changes
- Claude is instructed to **always commit** before making changes, so you can roll back
- `secrets.yaml`, `.storage/`, and database files are off-limits
- All changes are tracked in git history

## Requirements

- An Anthropic account with a Max plan (for Remote Control) or Pro plan
- Internet connectivity (for Anthropic API)
