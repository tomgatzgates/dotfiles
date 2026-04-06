# dotfiles

Tom's dotfiles repo. Manages shell aliases, git config, and packages across multiple machines.

## Profiles

| Profile | Use for |
|---|---|
| `full` | Personal machines you own — installs everything including apps |
| `minimal` | Machines you use but don't want to load up — configs and aliases only |
| `managed` | Work laptops or servers you don't fully control — non-destructive, system wins on conflict |

## Setup on a new machine

Run the setup skill:

```
/setup
```

Claude will detect the machine, confirm the profile, run install.sh, handle gh auth, and verify everything.

## Key files

| File | Purpose |
|---|---|
| `install.sh` | Main installer — `--minimal` or `--managed` flags |
| `aliases.sh` | Shell aliases (sourced by .zshrc/.bashrc) |
| `gitconfig` | Git config (symlinked to ~/.gitconfig) |
| `gitconfig.local.template` | Template for `~/.gitconfig.local` (not tracked) |
| `linux/packages.sh` | Ubuntu packages including gh CLI |
| `mac/Brewfile` | Homebrew bundle |
| `scripts/verify.sh` | Check this machine is set up correctly |
| `scripts/sync.sh` | Pull latest + re-run install |
| `scripts/update.sh` | Update packages (apt or brew) |
| `scripts/move-credentials.sh` | Move gh credential helpers out of tracked gitconfig |

## Machine-local overrides

`~/.gitconfig.local` and `~/.aliases.local` are never tracked. Use them for credentials, work email overrides, or machine-specific aliases.
