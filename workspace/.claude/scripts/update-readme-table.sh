#!/usr/bin/env bash
# ==============================================================================
# update-readme-table.sh
# Fully automates the Structure table in README.md:
# 1. Scans .claude/ for folders.
# 2. Updates counts based on file contents.
# 3. Synchronizes rows (add/remove/sort) with the current file system state.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
README_FILE="$WORKSPACE_ROOT/README.md"
CLAUDE_DIR="$WORKSPACE_ROOT/.claude"

if [ ! -f "$README_FILE" ]; then
    exit 0
fi

python3 - "$WORKSPACE_ROOT" "$README_FILE" "$CLAUDE_DIR" << 'PYEOF'
import os, re, sys

workspace_root = sys.argv[1]
readme_path    = sys.argv[2]
claude_dir     = sys.argv[3]

# Known descriptions for consistent output
DESCRIPTIONS = {
    ".claude/hooks/":          "Event-driven security, logging, and audio alert scripts",
    ".claude/commands/":       "Custom slash commands for task management and system persona",
    ".claude/rules/":          "Behavioral rules for common review patterns",
    ".claude/skills/":         "Reusable knowledge modules",
    ".claude/github-actions/": "CI/CD workflows",
    ".claude/agents/":         "Custom subagent definitions and personas",
    ".claude/scripts/":        "Automation and helper scripts",
    ".claude/stats/":          "Daily telemetry and tool-usage JSON analytics",
    ".claude/":                "Core configuration (`settings.json`, lifetime session stats)",
}

def count_files(dir_path):
    if not os.path.isdir(dir_path): return 0
    total = 0
    for root, _, files in os.walk(dir_path):
        for f in files:
            if f.startswith(".") or f.endswith(".lock"): continue
            total += 1
    return total

# 1. Discover all current folders
tracked = {}
if os.path.isdir(claude_dir):
    for entry in sorted(os.listdir(claude_dir)):
        sub_path = os.path.join(claude_dir, entry)
        if os.path.isdir(sub_path) and not entry.startswith("."):
            key = f".claude/{entry}/"
            tracked[key] = count_files(sub_path)

    # Add root .claude/
    tracked[".claude/"] = sum(1 for item in os.listdir(claude_dir)
                              if os.path.isfile(os.path.join(claude_dir, item))
                              and not item.startswith(".") and not item.endswith((".log", ".lock")))

# 2. Re-generate table content in fixed preferred order
preferred_order = [
    ".claude/hooks/",
    ".claude/commands/",
    ".claude/rules/",
    ".claude/skills/",
    ".claude/github-actions/",
    ".claude/agents/",
    ".claude/scripts/",
    ".claude/stats/",
    ".claude/",
]
extra_keys = sorted([k for k in tracked.keys() if k not in preferred_order])
ordered_keys = [k for k in preferred_order if k in tracked] + extra_keys

table_rows = []
for key in ordered_keys:
    desc = DESCRIPTIONS.get(key, f"Custom {key.replace('.claude/', '').replace('/', '')} modules")
    link = f"[`{key}`]({key})"
    table_rows.append(f"| {link} | {desc} | {tracked[key]} |")

new_table_body = "\n".join(table_rows)

# 3. Replace the entire Structure block cleanly
with open(readme_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace from "Structure\n---------\n\n" up to the divider / next section
structure_pattern = re.compile(
    r"(Structure\n-+\n\n\| Folder \| Description \| Count \|\n\|[-| ]+\|\n)([\s\S]*?)(\n\n—|\n\nFile Locations)",
    re.MULTILINE
)

match = structure_pattern.search(content)
if match:
    content = content[:match.start(2)] + new_table_body + content[match.end(2):]

# 4. Update header counts
content = re.sub(r"### Commands \(\d+\)", f"### Commands ({tracked.get('.claude/commands/', 0)})", content)
content = re.sub(r"### Hooks \(\d+\)",    f"### Hooks ({tracked.get('.claude/hooks/', 0)})",       content)

with open(readme_path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF