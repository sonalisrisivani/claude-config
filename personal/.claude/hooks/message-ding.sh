#!/bin/bash
# ------------------------------------------------------------------
# message-ding.sh
#
# WHEN:    Stop (runs whenever Claude finishes a response turn and
#          yields control back to the user)
# PURPOSE: Plays an audible alert sound so you know immediately when
#          Claude has finished answering your prompt.
#
# HOW IT WORKS:
#   1. Fires without blocking the process (backgrounded via &).
#   2. Uses macOS native afplay utility to play Hero.aiff.
# ------------------------------------------------------------------

afplay /System/Library/Sounds/Hero.aiff &

exit 0
