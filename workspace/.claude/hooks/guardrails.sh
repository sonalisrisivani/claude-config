#!/bin/bash
# ------------------------------------------------------------------
# guardrails.sh
#
# WHEN:    PreToolUse → matcher: "Bash"
# PURPOSE: Safety net before Claude runs any Bash command.
#          Scans the command for dangerous patterns and BLOCKS
#          execution if something destructive is detected.
#
# HOW IT WORKS:
#   1. Reads the JSON payload Claude sends (tool_name + tool_input)
#   2. Extracts the bash command string via jq
#   3. Matches it against a list of dangerous regex patterns
#   4. If a match is found → prints a warning and exits with code 1
#      (exit 1 = Claude Code treats it as BLOCKED and skips the tool)
#   5. If safe → exits with 0 and lets the command proceed
# ------------------------------------------------------------------

# Read JSON input from stdin (provided by Claude Code hook system)
INPUT=$(cat)

# Extract the bash command Claude wants to run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# If no command found, nothing to check — let it pass
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Dangerous patterns to block:
#   - Recursive force deletes of root/home/git dirs (rm -rf /, rm -rf ~, etc.)
#   - Git force push (can silently overwrite remote history)
#   - Git hard reset (discards all uncommitted changes irreversibly)
#   - chmod 777 on root (opens entire filesystem to all users)
#   - mkfs (formats a disk — instant data loss)
#   - Fork bomb :(){:|:&};: (crashes the system by infinitely spawning processes)
#   - Writing directly to a block device like /dev/sda (overwrites the disk)
BLOCKED_PATTERNS=(
  "rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+.*(/|/\*|~|~/\*|\$HOME|\.git|\.\.)"
  "git\s+push\s+.*(--force|-f\b)"
  "git\s+reset\s+--hard"
  "chmod\s+-R\s+777\s+/"
  "mkfs"
  ":\(\)\{\s*:\|:&\s*\};:"
  ">\s*/dev/sd[a-z]"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -Eiq "$pattern"; then
    echo "====================================================" >&2
    echo "🛑 Command Blocked!" >&2
    echo "⚡ Soni! Dangerous command detected: '$COMMAND'" >&2
    echo "🛡️ Safety kosam ee command execute avvakunda aapaanu!" >&2
    echo "====================================================" >&2
    exit 1  # exit 1 = Claude Code blocks tool execution
  fi
done

exit 0  # exit 0 = safe, proceed normally
