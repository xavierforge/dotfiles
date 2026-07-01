#!/usr/bin/env bash
#
# Bootstrap / update these dotfiles on macOS or Linux.
#
#   ./install.sh
#
# Re-running is safe (idempotent): it re-links every config and, if Homebrew
# is present, installs anything missing from the Brewfile. It never installs a
# package manager for you — on Linux use apt/pacman/etc (see README).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

# --- 1. Dependencies (only if Homebrew is already installed) --------------
if command -v brew >/dev/null 2>&1; then
  echo "==> Homebrew found — installing dependencies from Brewfile"
  brew bundle --file="$DOTFILES/Brewfile"
else
  echo "==> Homebrew not found — skipping dependency install."
  echo "    Install the tools with your package manager first, e.g.:"
  echo "      Debian/Ubuntu: sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide"
  echo "      Arch:          sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide"
  echo "    (stylua and uv aren't in most distro repos — see README.)"
fi

# --- 2. stow is required for the linking step ----------------------------
if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU stow is required but not installed. Install it and re-run." >&2
  exit 1
fi

# --- 3. Symlink the configs ----------------------------------------------
mkdir -p "$HOME/.config"
echo "==> Linking ~/.config configs with stow"
stow --target "$HOME/.config" --restow .
echo "==> Linking home-level zsh configs with stow"
stow --target "$HOME" --restow zsh

echo "==> Done. Open a new shell (or 'source ~/.zshrc') to pick up changes."
