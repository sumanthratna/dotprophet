#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Zellij Session
# @raycast.mode silent
# @raycast.packageName Zellij

# Optional parameters:
# @raycast.icon 🪟
# @raycast.argument1 { "type": "text", "placeholder": "Session name" }

# Documentation:
# @raycast.description Open Ghostty attached to a named Zellij session (creates if needed)
# @raycast.author sumanthratna

export PATH="/opt/homebrew/bin:$PATH"

session_name="${1-}"
if [[ -z "${session_name//[[:space:]]/}" ]]; then
  echo "Session name is required" >&2
  exit 1
fi

# We use a temp file + AppleScript instead of `open -na Ghostty.app --args -e ...`
# to avoid spawning a separate Ghostty instance (double dock icon).
#
# Tradeoffs:
# - Race condition: triggering twice quickly can clobber the file, landing both windows on the same session
# - Stale file: if Ghostty fails to open, the next manual window picks up the wrong session
# - Requires System Events accessibility permission for the keystroke
#
# Robust alternative: open -na Ghostty.app --args -e zellij attach --create "$1"
printf '%s\n' "$session_name" > /tmp/zellij-next-session
if pgrep -x Ghostty > /dev/null; then
  osascript -e 'tell application "Ghostty" to activate' -e 'tell application "System Events" to keystroke "n" using command down'
else
  open -a Ghostty
fi
