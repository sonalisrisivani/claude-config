#!/bin/bash

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
  # Standard bash command
  echo "[$TIMESTAMP] [Bash] $COMMAND" >> "$LOG_FILE"
elif [ "$TOOL_NAME" != "Unknown" ]; then
  # Other tools (Read, Write, Edit, WebSearch, etc.)
  SUMMARY=$(echo "$INPUT" | jq -c '.tool_input' 2>/dev/null)
  echo "[$TIMESTAMP] [$TOOL_NAME] $SUMMARY" >> "$LOG_FILE"
fi
