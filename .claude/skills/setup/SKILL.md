---
name: setup
description: Set up or update dotfiles on this machine. Trigger on "set up this machine", "run setup", "install dotfiles", "update dotfiles", or /setup.
allowed-tools: Bash
---

# Dotfiles Setup

Orchestrate dotfiles installation on this machine. The logic lives in bash scripts — your job is to call them in the right order, handle decisions, and surface errors.

## Step 1: Detect machine

```bash
hostname && uname -s && uname -m
```

Show the output, then ask the user which profile to use:

> Which profile should I use?
> - **full** — everything including apps (personal machines you own)
> - **minimal** — configs and aliases only, no packages (you decide what to install)
> - **managed** — non-destructive, no packages, system wins on conflicts (work laptop, server)

## Step 2: Confirm dotfiles repo is present

```bash
ls ~/code/dotfiles/install.sh 2>/dev/null && echo "present" || echo "missing"
```

If missing, show the clone command and wait for the user to run it:
```
git clone https://github.com/tomgatzgates/dotfiles ~/code/dotfiles
```
Wait for the user to confirm they've cloned it before proceeding.

## Step 3: 1Password sign-in (full profile only)

Skip this step for minimal and managed profiles.

Tell the user:

> Before running install.sh, open the 1Password app and make sure you're signed in. The install script will pause and prompt you to confirm — or type "skip" to continue without 1Password features (e.g. on a server or machine where 1Password isn't installed).
>
> 1Password is used to restore `~/.ssh/config` from your vault. If you skip it, you'll need to set up `~/.ssh/config` manually from `ssh/config.template`.

Wait for the user to confirm they're ready before continuing.

## Step 4: Run install.sh

For **full**:
```bash
sh ~/code/dotfiles/install.sh
```

For **minimal**:
```bash
sh ~/code/dotfiles/install.sh --minimal
```

For **managed**:
```bash
sh ~/code/dotfiles/install.sh --managed
```

If the script exits non-zero, show the error and stop. Do not proceed to the next step.

## Step 5: Handle gh auth (full profile only)

Skip this step for minimal and managed profiles.

```bash
gh auth status 2>&1
```

If already authenticated, skip to Step 5.

If not authenticated:
1. Tell the user: "gh is installed but not authenticated. Please run `gh auth login` and follow the prompts, then let me know when done."
2. Wait for the user to confirm.
3. Check if credential helpers ended up in the tracked gitconfig (which is now a symlink):
   ```bash
   grep -c '^\[credential' ~/code/dotfiles/gitconfig 2>/dev/null || echo 0
   ```
4. If count > 0, run:
   ```bash
   sh ~/code/dotfiles/scripts/move-credentials.sh
   ```
   This moves the credential blocks into `~/.gitconfig.local` interactively — follow its prompts.

## Step 6: Verify

```bash
sh ~/code/dotfiles/scripts/verify.sh
```

Report the results. If any checks fail, explain what to do based on the output.

## Step 7: Commit and push if needed

```bash
git -C ~/code/dotfiles status --short
```

If there are uncommitted changes, offer to commit and push:
```bash
git -C ~/code/dotfiles add -A
git -C ~/code/dotfiles commit -m "chore: post-install sync on $(hostname)"
git -C ~/code/dotfiles push
```

Ask the user before running git push.

## Done

Tell the user to open a new shell (or run `source ~/code/dotfiles/aliases.sh`) to pick up aliases.
