#!/bin/bash

# Gojo Satoru greeting quotes for Soni
QUOTES=(
  "😎 Yo, Soni! The Strongest is here. Em cheddam ivvala?"
  "⚡ Arey Soni, tension padaku. Nenu unnanu ga, bugs anni chill avvalsinde!"
  "🕶️ 'Throughout Heaven and Earth, I alone am the Honored One.' Cheppu mowa, em create cheddam?"
  "🔥 Soni mowa! Let's show them what real limitless looks like!"
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
