#!/usr/bin/env bash
#
# 在 macOS 或 Linux（含 WSL）上安裝/更新這份 dotfiles
# Bootstrap / update these dotfiles on macOS / Linux (incl. WSL).
#
#   ./install.sh
#
# 可重複執行（idempotent）：每次都會重新連結所有設定；若有 Homebrew，會補裝
# Brewfile 缺少的套件。遇到既有的「真實檔案」會先自動備份成 .bak-<時間> 再連結。
# Re-running is safe (idempotent): it re-links every config and, if Homebrew is
# present, installs anything missing from the Brewfile. Any existing *real* file
# in the way is backed up to .bak-<timestamp> before linking — nothing is
# clobbered.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

# ---------- 輸出樣式 helpers / output style helpers ----------
# ▶ step   ℹ️ info (normal)   ✅ success   ⚠️ warning (non-fatal)   ❌ error (fatal)
if [ -t 1 ]; then
  C_INFO=$'\033[0;34m'; C_OK=$'\033[0;32m'; C_WARN=$'\033[0;33m'
  C_ERR=$'\033[0;31m';  C_STEP=$'\033[1;36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_INFO=; C_OK=; C_WARN=; C_ERR=; C_STEP=; C_DIM=; C_RST=
fi
step() { printf '\n%s▶  %s%s\n' "$C_STEP" "$*" "$C_RST"; }
info() { printf '%sℹ️  %s%s\n'  "$C_INFO" "$*" "$C_RST"; }
ok()   { printf '%s✅ %s%s\n'   "$C_OK"   "$*" "$C_RST"; }
warn() { printf '%s⚠️  %s%s\n'  "$C_WARN" "$*" "$C_RST"; }
err()  { printf '%s❌ %s%s\n'   "$C_ERR"  "$*" "$C_RST" >&2; }
dim()  { printf '%s   %s%s\n'   "$C_DIM"  "$*" "$C_RST"; }

BACKUP_SUFFIX="bak-$(date +%Y%m%d-%H%M%S)"
BACKUP_COUNT=0

# ---------- 1. 依賴套件（僅在已裝 Homebrew 時）/ Dependencies (only if Homebrew) ----------
step "Checking dependencies"
if command -v brew >/dev/null 2>&1; then
  info "Homebrew found — installing from Brewfile"
  if brew bundle --file="$DOTFILES/Brewfile"; then
    ok "All Brewfile packages are ready"
  else
    warn "Some Brewfile entries failed (e.g. a font already installed manually)"
    dim "This does not affect linking below — continuing."
  fi
else
  info "No Homebrew — skipping dependency install (this is normal, not an error)"
  dim "Install the tools with your package manager first, e.g.:"
  dim "  Debian/Ubuntu: sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide"
  dim "  Arch:          sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide"
  dim "  (stylua and uv aren't in most distro repos — see README.)"
fi

# ---------- 2. 連結步驟需要 GNU stow / stow is required for linking ----------
step "Checking for GNU stow"
if command -v stow >/dev/null 2>&1; then
  sv="$(stow --version 2>/dev/null | head -n1 || true)"
  ok "Found stow (${sv:-unknown})"
else
  err "GNU stow is required for the linking step but is not installed. Install it and re-run."
  exit 1
fi

# ---------- 3. 建立設定檔連結 / Symlink the configs ----------
# 先用「模擬模式」找出會被卡住的既有真實檔案，自動備份後再實際連結。
# Use stow's simulate mode first to find existing real files that would block
# linking, back them up, then link for real.
backup_conflicts() {
  local pkg="$1" target="$2"
  local sim rel path bak
  # --no = 模擬，不動任何檔案；|| true 避免 set -e 因模擬回傳非零而中斷
  # --no = simulate (touches nothing); `|| true` keeps set -e from aborting here
  sim="$(stow --dir "$DOTFILES" --target "$target" --no --restow "$pkg" 2>&1 || true)"
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    path="$target/$rel"
    # 只備份「存在、不是符號連結、也不是目錄」的真實檔案
    # Only back up a real file: it exists, is not a symlink, and is not a dir.
    if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -d "$path" ]; then
      bak="$path.$BACKUP_SUFFIX"
      mv "$path" "$bak"
      warn "Backed up existing real file: $rel  ->  $(basename "$bak")"
      BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
  done < <(printf '%s\n' "$sim" \
             | sed -n 's/.*existing target is neither a link nor a directory: //p')
}

link_pkg() {
  local pkg="$1" target="$2" label="$3"
  local out rc filtered
  backup_conflicts "$pkg" "$target"
  out="$(stow --dir "$DOTFILES" --target "$target" --restow "$pkg" 2>&1)" && rc=0 || rc=$?
  # 濾掉舊版 stow 對 /mnt/c 外部符號連結（如 ~/.aws）產生的無害 BUG 噪音
  # Drop the harmless BUG noise old stow prints for external /mnt/c symlinks.
  filtered="$(printf '%s\n' "$out" | grep -v 'BUG in find_stowed_path' || true)"
  [ -n "$filtered" ] && printf '%s\n' "$filtered"
  if [ "$rc" -eq 0 ]; then
    ok "$label linked"
  else
    err "$label failed (stow exit $rc) — see messages above"
    return "$rc"
  fi
}

step "Linking configs with stow"
mkdir -p "$HOME/.config"
# herdr 會把 socket、log、session.json 寫進自己的設定目錄。先把它建成「真實目錄」，
# stow 才會只連結底下的 config.toml；否則在全新機器上整個目錄會被折疊成指向這個
# repo 的符號連結，執行期產物就會被寫進 dotfiles 裡。
# herdr writes sockets, logs and session.json into its own config dir. Create it
# as a real directory first so stow links just config.toml inside it; otherwise on
# a fresh machine stow folds the whole directory into one symlink into this repo
# and herdr's runtime files end up inside the dotfiles tree.
mkdir -p "$HOME/.config/herdr"
link_pkg "."   "$HOME/.config" "~/.config configs"
link_pkg "zsh" "$HOME"         "home-level zsh configs"

# ---------- 4. 收尾 / Wrap up ----------
step "Done"
if [ "$BACKUP_COUNT" -gt 0 ]; then
  warn "Backed up $BACKUP_COUNT existing file(s) with suffix .$BACKUP_SUFFIX"
  dim "Delete them once the new setup looks good; to restore, rename a .$BACKUP_SUFFIX file back."
fi
ok "All done! Open a new shell (or run 'source ~/.zshrc') to pick up changes."
