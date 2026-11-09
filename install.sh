#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.bak.$(date +%s)"
  echo "Old config saved as $TARGET.bak.*"
fi

mkdir -p "$(dirname "$TARGET")"
ln -sfn "$REPO_DIR" "$TARGET"
echo "Ready to go."