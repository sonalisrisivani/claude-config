#!/usr/bin/env bash
# ==============================================================================
# auto-update-readme.sh
# Triggered conditionally on PostToolUse. If a file was added/updated/deleted
# under .claude/, it runs the full python counter.
# ==============================================================================

# Background the python script so it doesn't block Claude's tool loops.
# We just check if the last tool changed anything, though checking the exact files
# modified isn't strictly necessary since the python script is fast enough.
# Let's just always run it quietly to guarantee accuracy.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/../scripts/update-readme-table.sh" >/dev/null 2>&1 &
