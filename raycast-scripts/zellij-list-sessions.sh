#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title List Zellij Sessions
# @raycast.mode fullOutput
# @raycast.packageName Zellij

# Optional parameters:
# @raycast.icon 📋

# Documentation:
# @raycast.description List all active Zellij sessions
# @raycast.author sumanthratna

export PATH="/opt/homebrew/bin:$PATH"
zellij list-sessions 2>/dev/null || echo "No active Zellij sessions."
