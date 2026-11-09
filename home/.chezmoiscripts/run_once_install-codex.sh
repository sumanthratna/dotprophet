#!/usr/bin/env bash
set -euo pipefail
command -v codex >/dev/null || curl -fsSL https://chatgpt.com/codex/install.sh | sh
