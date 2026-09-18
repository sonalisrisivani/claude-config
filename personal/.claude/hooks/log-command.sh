#!/bin/bash
# ------------------------------------------------------------------
# log-command.sh
#
# WHEN:    PreToolUse → matcher: ".*" (runs for every tool)
# PURPOSE: Logs every Claude Code tool execution to a session log file.
#          Includes a timestamp, the tool name, and a summary of the
#          input arguments. This creates a chronological audit trail
#          (command.log) useful for debugging and retrospectively seeing
#          what actions Claude performed.
#
# HOW IT WORKS:
#   1. Determines its own directory (the hooks folder).
#   2. Reads the JSON payload from stdin (tool_name, tool_input).
#   3. Extracts the command string for Bash tools; otherwise logs the
#      whole tool_input object as a compact JSON string.
#   4. Appends a line to ../command.log.
# ------------------------------------------------------------------

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../command.log"

# Read JSON input from stdin (provided by Claude Code hook)
INPUT=$(cat)

# Extract tool name and input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "Unknown"' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ -n "$COMMAND" ]; then
  # Standard bash command – log the raw command string
  echo "[$TIMESTAMP] [Bash] $COMMAND" >> "$LOG_FILE"
elif [ "$TOOL_NAME" != "Unknown" ]; then
  # Other tools (Read, Write, Edit, WebSearch, etc.) – log the input JSON
  SUMMARY=$(echo "$INPUT" | jq -c '.tool_input' 2>/dev/null)
  echo "[$TIMESTAMP] [$TOOL_NAME] $SUMMARY" >> "$LOG_FILE"
fi
