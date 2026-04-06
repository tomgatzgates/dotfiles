#!/bin/sh
# Move [credential] blocks from the tracked gitconfig into ~/.gitconfig.local.
# Run once after `gh auth login` on a machine where ~/.gitconfig is symlinked
# to dotfiles/gitconfig — to prevent credential helpers from polluting the repo.
#
# Idempotent: skips if no credential blocks are found in the tracked file.

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
GITCONFIG="$DOTFILES/gitconfig"

if ! grep -q '^\[credential' "$GITCONFIG" 2>/dev/null; then
  echo "No [credential] blocks found in tracked gitconfig. Nothing to do."
  exit 0
fi

echo "Found [credential] blocks in $GITCONFIG."
echo ""
echo "Credential lines to move:"
grep -n '^\[credential\]\|\[credential ' "$GITCONFIG"
echo ""

# Extract all credential blocks (section header + following lines until next section)
awk '/^\[credential/{found=1} found{print} /^\[/ && !/^\[credential/{found=0}' "$GITCONFIG" \
  | grep -v '^\[credential' | head -0 || true

# Use a Python-free awk approach to extract credential sections
CRED_CONTENT="$(awk '
  /^\[credential/ { in_cred=1; block=$0; next }
  in_cred && /^\[/ { print block; in_cred=0 }
  in_cred { block=block"\n"$0 }
  END { if (in_cred) print block }
' "$GITCONFIG")"

CRED_HEADERS="$(grep '^\[credential' "$GITCONFIG")"

echo "These blocks will be appended to ~/.gitconfig.local:"
echo "$CRED_HEADERS"
echo ""

printf "Proceed? [y/N] "
read -r REPLY
case "$REPLY" in
  [Yy]*)
    # Append credential blocks to ~/.gitconfig.local
    {
      echo ""
      echo "# Credential helpers (moved from dotfiles/gitconfig by move-credentials.sh)"
      awk '
        /^\[credential/ { in_cred=1; block=$0; next }
        in_cred && /^\[/ { print block; in_cred=0 }
        in_cred { block=block"\n"$0 }
        END { if (in_cred) print block }
      ' "$GITCONFIG"
    } >> ~/.gitconfig.local
    echo "Appended to ~/.gitconfig.local."

    # Remove credential blocks from tracked gitconfig
    # Use a temp file to rewrite without credential sections
    TMPFILE="$(mktemp)"
    awk '
      /^\[credential/ { in_cred=1; next }
      in_cred && /^\[/ { in_cred=0 }
      !in_cred { print }
    ' "$GITCONFIG" > "$TMPFILE"
    mv "$TMPFILE" "$GITCONFIG"
    echo "Removed from $GITCONFIG."

    echo ""
    echo "Verifying gh auth still works..."
    gh auth status && echo "gh auth: OK" || echo "gh auth: FAILED — check ~/.gitconfig.local"
    ;;
  *)
    echo "Aborted."
    exit 1
    ;;
esac
