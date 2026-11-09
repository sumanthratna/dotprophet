#!/usr/bin/env bash
# Node 22 (provides npm, corepack and pnpm) via nvm, which chezmoi installs to ~/.nvm.
set -eo pipefail
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install 22
nvm alias default 22
