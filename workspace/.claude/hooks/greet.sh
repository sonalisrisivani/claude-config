#!/bin/bash
# ------------------------------------------------------------------
# gojo-greet.sh
#
# WHEN:    SessionStart (runs once as soon as a Claude session starts)
# PURPOSE: Greets Soni with a custom Gojo Satoru quote banner.
#
# HOW IT WORKS:
#   1. Holds an array of Telugu-infused Gojo quotes.
#   2. Randomly selects one quote.
#   3. Formats it nicely inside a visual text banner.
#   4. Emits JSON formatted with a "systemMessage" key via jq so Claude
#      Code displays it prominently in the terminal at launch.
# ------------------------------------------------------------------

# Gojo Satoru greeting quotes for Soni
QUOTES=(
  "😎 Yo, Soni! What shall we do today?"
  "⚡ Arey Soni, Sup!"
  "🕶️ 'Throughout Heaven and Earth, I alone am the Honored One.' Cheppu mowa, em create cheddam?"
  "🔥 Soni mowa! Hows ur day!"
)

# Pick a random quote
RANDOM_INDEX=$((RANDOM % ${#QUOTES[@]}))
SELECTED_QUOTE="${QUOTES[$RANDOM_INDEX]}"

# Construct the message banner
MESSAGE="====================================================
${SELECTED_QUOTE}
===================================================="

# Output the JSON expected by Claude Code to display a UI banner
jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
