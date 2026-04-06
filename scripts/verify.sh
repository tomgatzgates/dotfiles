#!/bin/sh
# Verify dotfiles are correctly set up on this machine.
# Exits 0 if all checks pass, 1 if any fail.

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=1
STATUS=0

check() {
  label="$1"
  result="$2"  # "ok" or "fail: <message>"
  if [ "$result" = "ok" ]; then
    printf "  [ok] %s\n" "$label"
  else
    printf " [!!] %s — %s\n" "$label" "${result#fail: }"
    STATUS=1
  fi
}

echo "Verifying dotfiles on $(hostname) ($(uname -s)/$(uname -m))..."
echo ""

# gitconfig: symlink or include
if [ -L ~/.gitconfig ]; then
  target="$(readlink ~/.gitconfig)"
  if [ "$target" = "$DOTFILES/gitconfig" ]; then
    check "~/.gitconfig" "ok"
  else
    check "~/.gitconfig" "fail: symlink points to $target, expected $DOTFILES/gitconfig"
  fi
elif [ -f ~/.gitconfig ] && grep -qF "dotfiles/gitconfig" ~/.gitconfig 2>/dev/null; then
  check "~/.gitconfig" "ok (managed include)"
else
  check "~/.gitconfig" "fail: not a symlink to dotfiles and no include found — run install.sh"
fi

# gitignore_global: symlink
if [ -L ~/.gitignore_global ]; then
  check "~/.gitignore_global" "ok"
elif [ -f ~/.gitignore_global ]; then
  check "~/.gitignore_global" "fail: exists but is not a symlink — run install.sh"
else
  check "~/.gitignore_global" "fail: missing — run install.sh"
fi

# gitconfig.local: exists (not required for managed)
if [ -L ~/.gitconfig ]; then
  if [ -f ~/.gitconfig.local ]; then
    check "~/.gitconfig.local" "ok"
  else
    check "~/.gitconfig.local" "fail: missing — run install.sh to bootstrap it"
  fi
fi

# aliases.sh sourced in shell rc
ALIASES_SOURCED=0
for rc in ~/.zshrc ~/.bashrc; do
  [ -f "$rc" ] || continue
  if grep -qF "dotfiles/aliases.sh" "$rc" 2>/dev/null; then
    ALIASES_SOURCED=1
    break
  fi
done
if [ "$ALIASES_SOURCED" = "1" ]; then
  check "aliases.sh sourced" "ok"
else
  check "aliases.sh sourced" "fail: not found in ~/.zshrc or ~/.bashrc — run install.sh"
fi

# ~/.local/bin in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:"*)
    check "~/.local/bin in PATH" "ok"
    ;;
  *)
    check "~/.local/bin in PATH" "fail: not in PATH — open a new shell or source aliases.sh"
    ;;
esac

# gh auth (if gh is installed)
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    check "gh auth" "ok"
  else
    check "gh auth" "fail: not authenticated — run: gh auth login"
  fi
else
  printf "  [--] gh auth (gh not installed, skipping)\n"
fi

echo ""
if [ "$STATUS" = "0" ]; then
  echo "All checks passed."
else
  echo "Some checks failed. Run install.sh to fix, or see above for specific steps."
fi

exit "$STATUS"
