Claude Code Workspace Configuration
==================================

Annotated configurations tailored for this specific project. This workspace acts as an isolated, secure, and productivity-optimized environment for Claude Code, featuring local task-tracking, security guardrails, and telemetry.

Structure
---------

| Folder | Description | Count |
|--------|-------------|-------|
| [`.claude/hooks/`](.claude/hooks/) | Event-driven security, logging, and audio alert scripts | 8 |
| [`.claude/commands/`](.claude/commands/) | Custom slash commands for task management and system persona | 5 |
| [`.claude/rules/`](.claude/rules/) | Behavioral rules for common review patterns | 0 |
| [`.claude/skills/`](.claude/skills/) | Reusable knowledge modules | 0 |
| [`.claude/github-actions/`](.claude/github-actions/) | CI/CD workflows | 0 |
| [`.claude/agents/`](.claude/agents/) | Custom subagent definitions and personas | 0 |
| [`.claude/scripts/`](.claude/scripts/) | Automation and helper scripts | 1 |
| [`.claude/stats/`](.claude/stats/) | Daily telemetry and tool-usage JSON analytics | 1 |
| [`.claude/`](.claude/) | Core configuration (`settings.json`, lifetime session stats) | 2 |

—


File Locations
--------------

| Type | Project Location | Global Fallback |
|------|------------------|-----------------|
| Commands | `.claude/commands/` | `~/.claude/commands/` |
| Hooks | `.claude/hooks/` | `~/.claude/hooks/` |
| Config | `.claude/settings.json` | `~/.claude/settings.json` |
| Tasks | `tasks/` & `todo.txt` | — |

Templates Index
---------------

### Commands (5)

**Task Management**

| File | Trigger | Purpose |
|------|---------|---------|
| [`todo/addtask.md`](.claude/commands/todo/addtask.md) | `/todo:addtask` | Appends task to `todo.txt` and generates a detailed JSON log entry. |
| [`todo/showtasklog.md`](.claude/commands/todo/showtasklog.md) | `/todo:showtasklog` | Displays a clean, readable summary of pending and completed tasks. |
| [`todo/plantaskexecution.md`](.claude/commands/todo/plantaskexecution.md) | `/todo:plantaskexecution` | Breaks down pending tasks into actionable multi-step markdown execution plans. |

**Permissions**

| File | Trigger | Purpose |
|------|---------|---------|
| [`allowlist/add.md`](.claude/commands/allowlist/add.md) | `/allowlist:add` | Reviews buffered safe-command suggestions and adds approved patterns to `settings.json`. |

**Personas & System**

| File | Trigger | Purpose |
|------|---------|---------|
| [`who-are-you.md`](.claude/commands/who-are-you.md) | `/who-are-you` | Custom workspace introduction and persona setup. |

### Hooks (8)

**Security & Safety Hooks** (2 bash):

| File | Event | Purpose |
|------|-------|---------|
| [`guardrails.sh`](.claude/hooks/guardrails.sh) | PreToolUse | Intercepts `Bash` calls and instantly blocks destructive commands (e.g., `rm -rf /`, `git push --force`). |
| [`allowlist-buffer.sh`](.claude/hooks/allowlist-buffer.sh) | PreToolUse | Silently logs safe, frequently-prompted commands to a pending queue for batch allowlisting via `/allowlist:add`. |

**Monitoring Hooks** (3 bash):

| File | Event | Purpose |
|------|-------|---------|
| [`log-command.sh`](.claude/hooks/log-command.sh) | PreToolUse | Maintains a chronological audit trail (`command.log`) of every tool call. |
| [`log-daily-stats.sh`](.claude/hooks/log-daily-stats.sh) | PostToolUse | Appends rich JSON tool usage data to a daily `.jsonl` file. |
| [`post-tool-tracker.sh`](.claude/hooks/post-tool-tracker.sh) | PostToolUse | Increments lifetime tool usage counters in `session-stats.json`. |

**Productivity & Automation Hooks** (3 bash):

| File | Event | Purpose |
|------|-------|---------|
| [`greet.sh`](.claude/hooks/greet.sh) | SessionStart | Welcomes the user with a custom banner when the session boots. |
| [`message-ding.sh`](.claude/hooks/message-ding.sh) | Stop | Plays a native macOS audio chime (`Hero.aiff`) when Claude finishes answering. |
| [`auto-update-readme.sh`](.claude/hooks/auto-update-readme.sh) | PostToolUse | Triggers the README structure table auto-updater after file changes. |

### Config (3)

| File | Purpose |
|------|---------|
| [`.claude/settings.json`](.claude/settings.json) | Core settings linking hooks, model mappings (`sonali-combo`), and `permissions.allow` auto-grants (bypassing prompts for safe git/gh commands). |
| [`.gitignore`](.gitignore) | Ignores local stats, execution logs, and lockfiles to keep repo clean. |
| [`todo.txt`](todo.txt) | Human-readable markdown list defining pending tasks. |