#!/bin/sh
# Pull latest dotfiles and re-run install with the same profile.
# Usage: sync.sh [--minimal|--managed]
set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

echo "Pulling latest dotfiles..."
git -C "$DOTFILES" pull

echo "Re-running install..."
sh "$DOTFILES/install.sh" "$@"
