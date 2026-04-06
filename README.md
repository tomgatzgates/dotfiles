# dotfiles

Dotfiles for Mac and Ubuntu. Supports full, minimal, and managed profiles.

## Quick start on a new machine

```sh
git clone https://github.com/tomgatzgates/dotfiles ~/code/dotfiles
cd ~/code/dotfiles && claude
```

Then run `/setup` — Claude will detect the machine, pick the right profile, run the installer, and verify everything.

## Manual install

```sh
# Full install (apps + configs)
~/code/dotfiles/install.sh

# Minimal (configs and aliases only — you decide what to install)
~/code/dotfiles/install.sh --minimal

# Managed (non-destructive — work laptops, servers you don't fully control)
~/code/dotfiles/install.sh --managed
```

## Keeping machines in sync

After changing aliases, git config, etc — commit and push. On other machines:

```sh
sh ~/code/dotfiles/scripts/sync.sh           # pull + re-run install (full)
sh ~/code/dotfiles/scripts/sync.sh --minimal # pull + re-run install (minimal)
```

To update packages:

```sh
sh ~/code/dotfiles/scripts/update.sh  # runs brew upgrade or apt upgrade depending on OS
```

## Machine-local overrides

`~/.gitconfig.local` and `~/.aliases.local` are never tracked. Use them for:
- Credential helpers (`gh auth login` writes here after setup)
- Work email overrides
- Machine-specific aliases or env vars

`install.sh` creates `~/.gitconfig.local` automatically. See `gitconfig.local.template` for examples.

The tracked `gitconfig` includes it via:
```ini
[include]
  path = ~/.gitconfig.local
```

## Structure

```
install.sh                    # installer (--minimal, --managed flags)
aliases.sh                    # shell aliases sourced by .zshrc/.bashrc
gitconfig                     # git config (symlinked to ~/.gitconfig)
gitconfig.local.template      # template for ~/.gitconfig.local (not tracked)
gitignore_global              # global gitignore (symlinked to ~/.gitignore_global)
mac/Brewfile                  # Homebrew bundle (includes gh)
linux/packages.sh             # Ubuntu packages (includes gh from official repo)
scripts/verify.sh             # check this machine is set up correctly
scripts/sync.sh               # pull latest + re-run install
scripts/update.sh             # update packages (brew or apt)
scripts/move-credentials.sh   # move gh credential helpers out of tracked gitconfig
.claude/skills/setup/         # /setup skill for Claude
```
