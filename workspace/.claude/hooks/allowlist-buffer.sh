#!/usr/bin/env bash
# ==============================================================================
# allowlist-buffer.sh
#
# WHEN:    PreToolUse → matcher: "Bash"
# PURPOSE: When Claude runs a Bash command that isn't in the allowlist,
#          this hook inspects it and — if it looks low-risk — logs the
#          suggested allowlist pattern to a pending queue file. This lets
#          you quickly approve frequently-repeated commands later with
#          /allowlist:add instead of manually editing settings.json.
#
# HOW IT WORKS:
#   1. Reads the incoming bash command from stdin JSON
#   2. Derives the minimal Bash(pattern) that would cover it
#   3. Checks if it's already in settings.json allowlist → skips if so
#   4. Checks if the pattern is known-safe (read-only, non-destructive)
#   5. If safe + not yet allowlisted → appends to .claude/allowlist-pending.jsonl
#   6. Always exits 0 (never blocks — guardrails.sh handles blocking)
# ==============================================================================

set -euo pipefail

SETTINGS_FILE=".claude/settings.json"
PENDING_FILE=".claude/allowlist-pending.jsonl"

# Read the hook JSON payload from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$COMMAND" ] && exit 0

# ── Derive the minimal pattern from the command ─────────────────────────────
# Take the first two tokens (e.g. "npm install" → "npm install *")
# with a trailing wildcard only when there are more args.
derive_pattern() {
  local cmd="$1"
  # Strip leading env var assignments (FOO=bar cmd ...)
  cmd=$(echo "$cmd" | sed 's/^[A-Z_][A-Z0-9_]*=[^ ]* //')

  local token1 token2 rest
  token1=$(echo "$cmd" | awk '{print $1}')
  token2=$(echo "$cmd" | awk '{print $2}')
  rest=$(echo "$cmd"   | awk '{$1=$2=""; print $0}' | xargs)

  if [ -z "$token2" ]; then
    echo "Bash($token1)"
  elif [ -z "$rest" ]; then
    echo "Bash($token1 $token2)"
  else
    echo "Bash($token1 $token2 *)"
  fi
}

PATTERN=$(derive_pattern "$COMMAND")

# ── Already allowlisted? Skip quietly ───────────────────────────────────────
if [ -f "$SETTINGS_FILE" ]; then
  existing=$(jq -r '.permissions.allow // [] | .[]' "$SETTINGS_FILE" 2>/dev/null)
  while IFS= read -r entry; do
    [ "$entry" = "$PATTERN" ] && exit 0
  done <<< "$existing"
fi

# ── Safe-command heuristics ─────────────────────────────────────────────────
# Only log patterns that are genuinely low-risk and frequently repeated.
# Interpreters, shells, and mutations are excluded here (guardrails handles blocking).
SAFE_PREFIXES=(
  "npm install"
  "npm ci"
  "npm run"        # only specific scripts — wildcard excluded
  "yarn install"
  "yarn add"
  "pnpm install"
  "pnpm add"
  "bun install"
  "bun add"
  "pip install"
  "pip3 install"
  "brew install"
  "brew upgrade"
  "brew list"
  "brew info"
  "docker ps"
  "docker images"
  "docker logs"
  "docker inspect"
  "kubectl get"
  "kubectl describe"
  "kubectl logs"
  "ls "
  "find "
  "rg "
  "grep "
  "env"
  "printenv"
  "ps "
  "open "
  "pbcopy"
  "pbpaste"
)

is_safe=false
for prefix in "${SAFE_PREFIXES[@]}"; do
  if [[ "$COMMAND" == "$prefix"* ]]; then
    is_safe=true
    break
  fi
done

$is_safe || exit 0

# ── Check if already pending ─────────────────────────────────────────────────
if [ -f "$PENDING_FILE" ]; then
  if grep -qF "\"pattern\":\"$PATTERN\"" "$PENDING_FILE" 2>/dev/null; then
    exit 0
  fi
fi

# ── Append to pending queue ──────────────────────────────────────────────────
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S")
ENTRY=$(jq -nc \
  --arg pattern "$PATTERN" \
  --arg command "$COMMAND" \
  --arg ts "$TIMESTAMP" \
  '{pattern: $pattern, example_command: $command, suggested_at: $ts, status: "pending"}')

echo "$ENTRY" >> "$PENDING_FILE"
exit 0
