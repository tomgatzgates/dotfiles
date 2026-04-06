#!/bin/sh
set -e

sudo apt update && sudo apt install -y \
  git curl wget jq tree \
  ripgrep fzf btop \
  redis-server \
  build-essential libssl-dev zlib1g-dev

# GitHub CLI (official repo — Ubuntu default is outdated)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# Docker
curl -fsSL https://get.docker.com | sh

# mise (version manager)
command -v mise >/dev/null || curl https://mise.run | sh
