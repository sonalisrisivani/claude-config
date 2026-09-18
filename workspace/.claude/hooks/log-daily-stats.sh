#!/bin/bash
# log-daily-stats.sh - Appends a daily JSONL record of tool usage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATS_DIR="$WORKSPACE_DIR/.claude/stats"
mkdir -p "$STATS_DIR"
STATS_FILE="$STATS_DIR/stats-$(date +%F).jsonl"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "Unknown"' 2>/dev/null)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
UNIX_TS=$(date +%s)

if [ "$TOOL_NAME" != "Unknown" ] && [ -n "$TOOL_NAME" ]; then
  SUMMARY=$(echo "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null)
  jq -n \
    --arg tool "$TOOL_NAME" \
    --arg ts "$UNIX_TS" \
    --arg time "$TIMESTAMP" \
    --arg cwd "$PWD" \
    --argjson input "$SUMMARY" \
    '{tool: $tool, timestamp: $time, ts: ($ts | tonumber), cwd: $cwd, input: $input}' >> "$STATS_FILE" 2>/dev/null
fi

exit 0
