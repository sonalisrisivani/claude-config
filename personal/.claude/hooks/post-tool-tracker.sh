#!/bin/bash
# ------------------------------------------------------------------
# post-tool-tracker.sh
#
# WHEN:    PostToolUse → matcher: ".*" (runs after any tool succeeds)
# PURPOSE: Tracks cumulative tool usage across sessions in
#          session-stats.json and plays a short subtle audio chime
#          whenever a tool call completes.
#
# HOW IT WORKS:
#   1. Reads the hook JSON payload containing tool_name.
#   2. If session-stats.json doesn't exist, initializes it.
#   3. Safely updates session-stats.json using jq and a temp file:
#      - Increments total_tools_used counter.
#      - Updates the last_updated timestamp.
#      - Increments the count for the specific tool_name.
#   4. Triggers macOS system sound in background (afplay Glass.aiff &).
# ------------------------------------------------------------------

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATS_FILE="$SCRIPT_DIR/../session-stats.json"

# Input JSON from Claude
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "Unknown"' 2>/dev/null)

if [ "$TOOL_NAME" == "Unknown" ] || [ -z "$TOOL_NAME" ]; then
  exit 0
fi

# Ensure stats file exists with basic structure
if [ ! -f "$STATS_FILE" ]; then
  echo '{"total_tools_used": 0, "last_updated": "", "by_tool": {}}' > "$STATS_FILE"
fi

# Use a temporary file to safely update JSON via jq
TMP_FILE=$(mktemp)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

jq --arg tool "$TOOL_NAME" --arg time "$TIMESTAMP" '
  .total_tools_used += 1 |
  .last_updated = $time |
  .by_tool[$tool] = ((.by_tool[$tool] // 0) + 1)
' "$STATS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATS_FILE"

# Play subtle chime in background
afplay /System/Library/Sounds/Glass.aiff &

# Optional: macOS notification banner
# Uncomment if you want desktop banners instead of just sounds
# osascript -e "display notification \"Finished using $TOOL_NAME\" with title \"Claude (Gojo)\"" &

exit 0
