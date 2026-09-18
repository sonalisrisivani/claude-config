---
title: "Claude Code Personal Config (Gojo Edition)"
description: "My personal Claude Code configuration featuring automated safety guardrails, custom lifecycle hooks, and a Gojo Satoru persona."
tags: [reference, workflows, automation, persona, security]
---

# Claude Code Personal Config (Gojo Edition)

This repository contains my personal Claude Code configuration. It is designed to fully automate my web development workspace while maintaining a fun, customized **Gojo Satoru best-friend persona**. 

The configuration includes safety guardrails, session telemetry, terminal audio feedback, and multiple slashed commands for specialized chatting modes (Telugu-English mix).

## Structure 

| Folder/File | Description | Count |
|--------|-------------|-------|
| [`six-eyes-analysis.md`](./six-eyes-analysis.md) | Persona and ambition tracking for Soni | 1 |
| [`.claude/settings.json`](./.claude/settings.json) | Central configuration defining all Claude lifecycle hooks | 1 |
| [`.claude/commands/`](./.claude/commands/) | Custom slash commands defining Gojo personas & actions | 9 |
| [`.claude/hooks/`](./.claude/hooks/) | Event-driven security, telemetry, and shell scripts | 5 |
| `.claude/session-stats.json` | Persistent local tracker for tool usage | 1 |
| `.claude/command.log` | Persistent local log of all executed bash commands and tools | 1 |
| `.gitignore` | Ignores ephemeral session lock files and analytics data | 1 |

## Quick Start

1. Set this folder as your primary workspace, or link its configurations globally.
2. Type `/gojo-greet` or launch a new session to initialize the Gojo persona.
3. Access slash commands by typing `/` followed by the command name (e.g., `/gojo:hype`).

## Templates Index

### Commands (9)

Custom commands configure Claude to quickly switch contexts, provide comfort, or playfully interact in Telugu (English script) using the Gojo Satoru persona.

| File | Trigger | Purpose |
|------|---------|---------|
| [vibes.md](./.claude/commands/vibes.md) | `/vibes` | Switch to pure Gojo Satoru best-friend mode (No tech talk). |
| [who-are-you.md](./.claude/commands/who-are-you.md) | `/who-are-you` | Base persona setup for Gojo interactive mode. |
| [random.md](./.claude/commands/random.md) | `/random` | Random, uplifting, comforting short quote containing "soni". |
| [gojo/decide.md](./.claude/commands/gojo/decide.md) | `/gojo:decide` | Confident, quick decisions (food, plans) made for Soni. |
| [gojo/flirt.md](./.claude/commands/gojo/flirt.md) | `/gojo:flirt` | Smooth, witty, Gojo-style flirty line. |
| [gojo/hype.md](./.claude/commands/gojo/hype.md) | `/gojo:hype` | High-energy, arrogant yet affectionate motivation. |
| [gojo/roast.md](./.claude/commands/gojo/roast.md) | `/gojo:roast` | Playful, lighthearted best-friend roast. |
| [gojo/tea.md](./.claude/commands/gojo/tea.md) | `/gojo:tea` | Casual gossip and natural chit-chat. |
| [gojo/vent.md](./.claude/commands/gojo/vent.md) | `/gojo:vent` | Caring, patient listener mode for venting and comfort. |


### Hooks (5)

Lifecycle bash scripts hooked into Claude Code via `.claude/settings.json`.

**Security Hooks** (1):

| File | Event | Purpose |
|------|-------|---------|
| [guardrails.sh](./.claude/hooks/guardrails.sh) | `PreToolUse` | Blocks `rm -rf`, `git push -f`, `git reset --hard`, fork bombs, etc. |

**Monitoring & Telemetry Hooks** (3):

| File | Event | Purpose |
|------|-------|---------|
| [log-command.sh](./.claude/hooks/log-command.sh) | `PreToolUse` | Exhaustively appends all tool and bash shell executions to `command.log`. |
| [post-tool-tracker.sh](./.claude/hooks/post-tool-tracker.sh) | `PostToolUse` | Tracks overall usage statistics into `session-stats.json`. |
| [gojo-greet.sh](./.claude/hooks/gojo-greet.sh) | `SessionStart` | Picks a random Gojo Telugu quote to display as a UI banner on load. |

**Notification & Audio** (2):

| File | Event | Purpose |
|------|-------|---------|
| [post-tool-tracker.sh](./.claude/hooks/post-tool-tracker.sh) | `PostToolUse` | Plays a soft system chime (`Glass.aiff`) after any tool completes successfully. |
| [message-ding.sh](./.claude/hooks/message-ding.sh) | `Stop` | Plays a prominent sound (`Hero.aiff`) when Claude finishes generating a response turn. |
