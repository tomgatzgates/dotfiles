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
mkdir -p ~/.config/mise
ln -sf "$DOTFILES/mise/config.toml" ~/.config/mise/config.toml
mise trust "$DOTFILES" >/dev/null 2>&1 || true
mkdir -p ~/.config
ln -sf "$DOTFILES/starship/starship.toml" ~/.config/starship.toml

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

# Starship prompt init (idempotent)
for rc in ~/.zshrc ~/.bashrc; do
  [ -f "$rc" ] || continue
  grep -qF "starship init" "$rc" || echo 'eval "$(starship init ${SHELL##*/})"' >> "$rc"
  grep -qF "mise activate" "$rc" || echo 'eval "$(mise activate ${SHELL##*/})"' >> "$rc"
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
      sh "$DOTFILES/mac/mac_defaults.sh"
      ;;
    Linux)
      sh "$DOTFILES/linux/packages.sh"
      ;;
  esac
else
  echo "Minimal profile: skipping package installs."
fi

# LazyVim: bootstrap neovim config if not already present
if command -v nvim >/dev/null 2>&1 && [ ! -d ~/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "LazyVim: installed to ~/.config/nvim"
fi

# 1Password: prompt to sign in before op-backed steps.
# Type "skip" to continue without 1Password features (e.g. on machines without 1Password).
OP_ENABLED=0
if command -v op >/dev/null 2>&1; then
  printf '\n1Password CLI is available. Sign in to 1Password now if needed, then press Enter.\nType "skip" to skip 1Password features: '
  read OP_CHOICE
  if [ "$OP_CHOICE" = "skip" ]; then
    echo "1Password: skipping"
  elif op account get >/dev/null 2>&1; then
    OP_ENABLED=1
    echo "1Password: signed in"
  else
    echo "1Password: not signed in — skipping 1Password features"
  fi
fi

# Restore ~/.ssh/config from 1Password if not present
if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  if [ "$OP_ENABLED" = "1" ]; then
    op document get "ssh-config" > ~/.ssh/config && chmod 600 ~/.ssh/config \
      && echo "ssh/config: restored from 1Password" \
      || echo "ssh/config: op document get failed — copy ssh/config.template to ~/.ssh/config manually"
  else
    echo "ssh/config: skipped — copy ssh/config.template to ~/.ssh/config manually"
  fi
fi

echo "Done ($PROFILE). Open a new shell or run: source $DOTFILES/aliases.sh"
