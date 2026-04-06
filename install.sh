#!/bin/sh
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Profile: full (default), minimal, or managed
PROFILE="full"
for arg in "$@"; do
  case "$arg" in
    --minimal) PROFILE="minimal" ;;
    --managed) PROFILE="managed" ;;
  esac
done

# Architecture and OS detection
OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$PROFILE" = "managed" ]; then
  # Managed: non-destructive, errors are warnings not failures
  set +e

  # Add a gitconfig include rather than symlinking (don't overwrite system config)
  if [ -f ~/.gitconfig ]; then
    if grep -qF "dotfiles/gitconfig" ~/.gitconfig 2>/dev/null; then
      echo "gitconfig: include already present, skipping"
    else
      printf '\n[include]\n  path = %s/gitconfig\n' "$DOTFILES" >> ~/.gitconfig \
        && echo "gitconfig: added include to existing ~/.gitconfig" \
        || echo "gitconfig: could not write to ~/.gitconfig, skipping"
    fi
  else
    printf '[include]\n  path = %s/gitconfig\n' "$DOTFILES" > ~/.gitconfig \
      && echo "gitconfig: created ~/.gitconfig with include" \
      || echo "gitconfig: could not create ~/.gitconfig, skipping"
  fi

  # gitignore_global: only symlink if not already present
  if [ ! -f ~/.gitignore_global ]; then
    ln -sf "$DOTFILES/gitignore_global" ~/.gitignore_global \
      && echo "gitignore_global: symlinked" \
      || echo "gitignore_global: could not symlink, skipping"
  else
    echo "gitignore_global: already exists, skipping"
  fi

  # Source aliases idempotently
  for rc in ~/.zshrc ~/.bashrc; do
    [ -f "$rc" ] || continue
    grep -qF "dotfiles/aliases.sh" "$rc" \
      && echo "aliases: already in $rc" \
      || { echo "source $DOTFILES/aliases.sh" >> "$rc" \
        && echo "aliases: added to $rc"; } \
      || echo "aliases: could not write to $rc, skipping"
  done

  echo "Done (managed). Open a new shell or run: source $DOTFILES/aliases.sh"
  exit 0
fi

# full and minimal profiles
ln -sf "$DOTFILES/gitconfig" ~/.gitconfig
ln -sf "$DOTFILES/gitignore_global" ~/.gitignore_global

# Bootstrap ~/.gitconfig.local for machine-local overrides (credential helpers, etc.)
if [ ! -f ~/.gitconfig.local ]; then
  cat > ~/.gitconfig.local <<'EOF'
# Machine-local git settings — NOT tracked in dotfiles.
# This file is included by dotfiles/gitconfig.
# Add credential helpers, work email overrides, etc. here.
# See gitconfig.local.template in the dotfiles repo for examples.
EOF
  echo "Created ~/.gitconfig.local"
fi

# Source aliases from shell configs (idempotent)
for rc in ~/.zshrc ~/.bashrc; do
  [ -f "$rc" ] || continue
  grep -qF "dotfiles/aliases.sh" "$rc" || echo "source $DOTFILES/aliases.sh" >> "$rc"
done

# Full install: packages and apps
if [ "$PROFILE" = "full" ]; then
  case "$OS" in
    Darwin)
      # Set correct Homebrew prefix for Apple Silicon vs Intel
      if [ "$ARCH" = "arm64" ]; then
        BREW_PREFIX="/opt/homebrew"
      else
        BREW_PREFIX="/usr/local"
      fi
      if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for the rest of this script
        eval "$("$BREW_PREFIX/bin/brew" shellenv)"
      fi
      brew bundle --file="$DOTFILES/mac/Brewfile"
      ;;
    Linux)
      sh "$DOTFILES/linux/packages.sh"
      ;;
  esac
else
  echo "Minimal profile: skipping package installs."
fi

echo "Done ($PROFILE). Open a new shell or run: source $DOTFILES/aliases.sh"
