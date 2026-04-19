#!/usr/bin/env bash
# Captures ZELLIJ_SESSION_NAME/ZELLIJ_PANE_ID at hook fire time because the
# click handler runs later in a detached process without those env vars.
set -uo pipefail

payload=$(cat)
IFS=$'\t' read -r msg cwd < <(
    jq -r '[.message // "Claude is awaiting input", .cwd // ""] | @tsv' <<<"$payload"
)
title=${cwd##*/}
title=${title:-Claude Code}

zellij_session=${ZELLIJ_SESSION_NAME:-}
zellij_pane=${ZELLIJ_PANE_ID:-}

result=$(alerter \
    --title "$title" \
    --message "$msg" \
    --sound Glass \
    --timeout 60 \
    --json || true)

activation=$(jq -r '.activationType // empty' <<<"$result")

if [[ $activation == contentsClicked ]]; then
    open -a Ghostty

    if [[ -n $zellij_session && -n $zellij_pane ]]; then
        zellij --session "$zellij_session" \
            action focus-pane-id "$zellij_pane" 2>/dev/null || true
    fi

    if [[ -n $zellij_session ]]; then
        osascript - "$zellij_session" 2>/dev/null <<'EOF' || true
on run argv
    set sessionName to item 1 of argv
    tell application "System Events" to tell process "Ghostty"
        repeat with w in windows
            if name of w contains sessionName then
                perform action "AXRaise" of w
                exit repeat
            end if
        end repeat
    end tell
end run
EOF
    fi
fi
