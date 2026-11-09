#!/usr/bin/env bash
set -euo pipefail
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
