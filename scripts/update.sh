#!/bin/sh
# Update packages on this machine.
# Dispatches to the right package manager based on OS.

OS="$(uname -s)"

case "$OS" in
  Darwin)
    if command -v brew >/dev/null 2>&1; then
      echo "Updating Homebrew packages..."
      brew update && brew upgrade
    else
      echo "brew not found, skipping."
    fi
    ;;
  Linux)
    if command -v apt >/dev/null 2>&1; then
      echo "Updating apt packages..."
      sudo apt update && sudo apt upgrade -y
    else
      echo "apt not found, skipping."
    fi
    ;;
  *)
    echo "Unknown OS: $OS — don't know how to update packages."
    exit 1
    ;;
esac

echo "Done."
