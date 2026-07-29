#!/usr/bin/env bash
#
# 在 macOS 或 Linux（含 WSL）上安裝/更新這份 dotfiles
# Bootstrap / update these dotfiles on macOS / Linux (incl. WSL).
#
#   ./install.sh            # 沿用目前已連結的選擇 / keep what is linked
#   ./install.sh --herdr    # 只裝並連結 herdr / herdr only
#   ./install.sh --tmux     # 只裝並連結 tmux / tmux only
#   ./install.sh --both     # 兩個都保留 / keep both
#
# 可重複執行（idempotent）：每次都會重新連結所有設定；若有 Homebrew，會補裝
# Brewfile 缺少的套件。遇到既有的「真實檔案」會先自動備份成 .bak-<時間> 再連結。
# Re-running is safe (idempotent): it re-links every config and, if Homebrew is
# present, installs anything missing from the Brewfile. Any existing *real* file
# in the way is backed up to .bak-<timestamp> before linking, so nothing is
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

# 兩個多工器各自的「代表性連結」，偵測與清理都看這兩個路徑。
# The representative link for each multiplexer; detection and cleanup use these.
TMUX_LINK="$HOME/.config/tmux"
HERDR_LINK="$HOME/.config/herdr/config.toml"
DEFAULT_MUX="herdr"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--herdr | --tmux | --both]

Options:
  --herdr      Set up herdr as the terminal multiplexer.
  --tmux       Set up tmux instead.
  --both       Keep both linked and installed.
  -h, --help   Show this help.

With no option the script keeps whatever is already linked, so re-running it as
an updater never changes your setup. On a fresh machine it asks, or picks herdr
when it cannot (no terminal attached). DOTFILES_MUX=<tmux|herdr|both> does the
same job for scripted runs; a flag wins over the variable.

--both is not the same as running with no option: no option means "keep the
current setup", --both means "make it both", which re-links the multiplexer you
previously dropped.

Switching only ever removes symlinks that point into this repo. Your tmux
plugins, herdr session files and any real config file are left untouched.
EOF
}

# 判斷某個路徑是不是「指向這個 repo」的符號連結。
# True when the path is a symlink that resolves into this repo.
links_into_dotfiles() {
  local path="$1" target dir base
  [ -L "$path" ] || return 1
  target="$(readlink "$path")" || return 1
  case "$target" in
    /*) ;;
    *)  target="$(dirname "$path")/$target" ;;
  esac
  dir="$(dirname "$target")"
  base="$(basename "$target")"
  dir="$(cd "$dir" 2>/dev/null && pwd -P)" || return 1
  case "$dir/$base" in
    "$DOTFILES"/*) return 0 ;;
  esac
  return 1
}

# 從「目前連結了什麼」反推選擇，所以重跑 install.sh 更新時不會擅自換掉多工器。
# Infer the choice from what is already linked, so running this as an updater
# never silently switches multiplexers on you.
detect_mux() {
  local have_tmux=no have_herdr=no
  if links_into_dotfiles "$TMUX_LINK";  then have_tmux=yes;  fi
  if links_into_dotfiles "$HERDR_LINK"; then have_herdr=yes; fi
  if [ "$have_tmux" = yes ] && [ "$have_herdr" = yes ]; then
    printf 'both\n'
  elif [ "$have_tmux" = yes ]; then
    printf 'tmux\n'
  elif [ "$have_herdr" = yes ]; then
    printf 'herdr\n'
  fi
}

# 問題寫到 stderr，答案才不會混進 $(ask_mux) 的輸出。
# Prompt on stderr so only the answer lands in $(ask_mux).
ask_mux() {
  local reply
  {
    printf '\n'
    printf 'Which terminal multiplexer should this machine use?\n'
    printf '  1) herdr  (default)\n'
    printf '  2) tmux\n'
    printf '  3) both\n'
    printf 'Choice [1]: '
  } >&2
  if ! read -r reply; then reply=""; fi
  reply="${reply%$'\r'}"   # 從 pty 進來的輸入可能帶 CR / input via a pty may carry CR
  case "$reply" in
    ""|1|herdr) printf 'herdr\n' ;;
    2|tmux)     printf 'tmux\n'  ;;
    3|both)     printf 'both\n'  ;;
    *) return 1 ;;
  esac
}

# ---------- 1. 選擇終端多工器 / Pick the terminal multiplexer ----------
MUX="${DOTFILES_MUX:-}"
MUX_SOURCE="DOTFILES_MUX"
while [ $# -gt 0 ]; do
  case "$1" in
    --tmux)  MUX="tmux";  MUX_SOURCE="--tmux";  shift ;;
    --herdr) MUX="herdr"; MUX_SOURCE="--herdr"; shift ;;
    --both)  MUX="both";  MUX_SOURCE="--both";  shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; printf '\n' >&2; usage >&2; exit 2 ;;
  esac
done

case "$MUX" in
  tmux|herdr|both|"") ;;
  *) err "Unknown multiplexer in DOTFILES_MUX: $MUX (expected tmux, herdr or both)"; exit 2 ;;
esac

step "Choosing the terminal multiplexer"
if [ -n "$MUX" ]; then
  info "Using $MUX (from $MUX_SOURCE)"
else
  MUX="$(detect_mux)"
  if [ -n "$MUX" ]; then
    info "Keeping the current setup: $MUX"
    dim "Switch with: ./install.sh --herdr | --tmux | --both"
  elif [ -t 0 ]; then
    MUX="$(ask_mux)" || { err "Please answer 1, 2 or 3."; exit 2; }
    info "Using $MUX"
  else
    MUX="$DEFAULT_MUX"
    info "Nothing linked yet and no terminal to ask on, defaulting to $MUX"
    dim "Choose explicitly with: ./install.sh --herdr | --tmux | --both"
  fi
fi
# Brewfile 讀這個變數決定要裝哪個多工器。名字一定要有 HOMEBREW_ 前綴，
# 使用者端則是 DOTFILES_MUX，不要混淆。
# 否則 brew 會在評估 Brewfile 前把它從環境裡濾掉。
# The Brewfile reads this to pick packages. The HOMEBREW_ prefix is mandatory:
# brew scrubs other custom variables from the environment before evaluating it.
export HOMEBREW_DOTFILES_MUX="$MUX"

# ---------- 2. 依賴套件（僅在已裝 Homebrew 時）/ Dependencies (only if Homebrew) ----------
step "Checking dependencies"
if command -v brew >/dev/null 2>&1; then
  info "Homebrew found, installing from Brewfile (multiplexer: $MUX)"
  if brew bundle --file="$DOTFILES/Brewfile"; then
    ok "All Brewfile packages are ready"
  else
    warn "Some Brewfile entries failed (e.g. a font already installed manually)"
    dim "This does not affect linking below, continuing."
  fi
else
  info "No Homebrew, skipping dependency install (this is normal, not an error)"
  dim "Install the tools with your package manager first, e.g.:"
  if [ "$MUX" = tmux ] || [ "$MUX" = both ]; then
    dim "  Debian/Ubuntu: sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide"
    dim "  Arch:          sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide"
  else
    dim "  Debian/Ubuntu: sudo apt install stow git neovim fzf ripgrep fd-find tree chafa zoxide"
    dim "  Arch:          sudo pacman -S stow git neovim fzf ripgrep fd tree chafa zoxide"
  fi
  dim "  (stylua and uv aren't in most distro repos, see README.)"
  if [ "$MUX" = herdr ] || [ "$MUX" = both ]; then
    dim "  herdr isn't packaged by distros either:"
    dim "    curl -fsSL https://herdr.dev/install.sh | sh"
  fi
fi

# ---------- 3. 連結步驟需要 GNU stow / stow is required for linking ----------
step "Checking for GNU stow"
if command -v stow >/dev/null 2>&1; then
  sv="$(stow --version 2>/dev/null | head -n1 || true)"
  ok "Found stow (${sv:-unknown})"
else
  err "GNU stow is required for the linking step but is not installed. Install it and re-run."
  exit 1
fi

# ---------- 4. 建立設定檔連結 / Symlink the configs ----------
# 沒被選到的多工器直接讓 stow 跳過，其設定就不會出現在 ~/.config。
# Hide the multiplexer that was not picked, so its config never reaches ~/.config.
# 陣列可能是空的（both），bash 3.2 在 set -u 下需要 ${a[@]+"${a[@]}"} 這種寫法。
# The array can be empty (both); bash 3.2 under set -u needs the ${a[@]+...} guard.
STOW_IGNORE=()
case "$MUX" in
  herdr) STOW_IGNORE=(--ignore='^tmux$')  ;;
  tmux)  STOW_IGNORE=(--ignore='^herdr$') ;;
esac

# 先用「模擬模式」找出會被卡住的既有真實檔案，自動備份後再實際連結。
# Use stow's simulate mode first to find existing real files that would block
# linking, back them up, then link for real.
backup_conflicts() {
  local pkg="$1" target="$2"
  local sim rel path bak
  # --no = 模擬，不動任何檔案；|| true 避免 set -e 因模擬回傳非零而中斷
  # --no = simulate (touches nothing); `|| true` keeps set -e from aborting here
  sim="$(stow --dir "$DOTFILES" --target "$target" \
           ${STOW_IGNORE[@]+"${STOW_IGNORE[@]}"} --no --restow "$pkg" 2>&1 || true)"
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
  out="$(stow --dir "$DOTFILES" --target "$target" \
           ${STOW_IGNORE[@]+"${STOW_IGNORE[@]}"} --restow "$pkg" 2>&1)" && rc=0 || rc=$?
  # 濾掉舊版 stow 對 /mnt/c 外部符號連結（如 ~/.aws）產生的無害 BUG 噪音
  # Drop the harmless BUG noise old stow prints for external /mnt/c symlinks.
  filtered="$(printf '%s\n' "$out" | grep -v 'BUG in find_stowed_path' || true)"
  [ -n "$filtered" ] && printf '%s\n' "$filtered"
  if [ "$rc" -eq 0 ]; then
    ok "$label linked"
  else
    err "$label failed (stow exit $rc), see messages above"
    return "$rc"
  fi
}

# 只移除「指向本 repo」的符號連結，真實檔案與執行期產物一律不動。
# Only removes symlinks pointing into this repo; real files and runtime
# artifacts are never touched.
# 第二個參數是完整的說明句，因為呼叫端的理由各不相同（換多工器 / 清舊殘骸）。
# The second argument is the whole sentence: callers unlink for different
# reasons (switching multiplexer versus clearing an old leftover).
unlink_if_ours() {
  local path="$1" reason="$2"
  if links_into_dotfiles "$path"; then
    rm -f "$path"
    warn "$reason: $path"
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
if [ "$MUX" != tmux ]; then
  mkdir -p "$HOME/.config/herdr"
fi
link_pkg "."   "$HOME/.config" "~/.config configs"
link_pkg "zsh" "$HOME"         "home-level zsh configs"

# 舊版目錄結構與忽略清單在 ~/.config 頂層留下的連結。stow 現在不會再建立它們，
# 但也不會回頭清，只能自己收：
#   .git / .gitignore  舊忽略清單漏掉，害 ~/.config 在 git 眼裡變成這個 repo
#   .neoconf.json      舊結構的殘留，真正的檔案在 ~/.config/nvim/ 底下
# 只認「指向本 repo 的符號連結」，同名的真實檔案或目錄一律不動。
# Links that older layouts and ignore lists left at the top of ~/.config. Stow
# no longer creates them but will not clean them up either, so do it here:
#   .git / .gitignore  missed by the old ignore list, made git treat ~/.config
#                      as this repo
#   .neoconf.json      stale path; the real file lives under ~/.config/nvim/
# Only symlinks into this repo are matched; a real file or directory of the
# same name is never touched.
for stale in .git .gitignore .neoconf.json; do
  unlink_if_ours "$HOME/.config/$stale" \
    "Removed a leftover $stale link that stow no longer creates"
done

# 換過選擇的話，把上一個多工器留下的連結收掉。
# Clean up the link the previous choice left behind, if the choice changed.
case "$MUX" in
  herdr)
    unlink_if_ours "$TMUX_LINK" "Unlinked the tmux config, herdr is the multiplexer now"
    ;;
  tmux)
    unlink_if_ours "$HERDR_LINK" "Unlinked the herdr config, tmux is the multiplexer now"
    # 只有在目錄已空（沒有 socket/log/session.json）時才會成功
    # Succeeds only when the dir is empty (no socket, log or session.json left)
    rmdir "$HOME/.config/herdr" 2>/dev/null || true
    ;;
esac

# ---------- 5. 收尾 / Wrap up ----------
step "Done"
if [ "$BACKUP_COUNT" -gt 0 ]; then
  warn "Backed up $BACKUP_COUNT existing file(s) with suffix .$BACKUP_SUFFIX"
  dim "Delete them once the new setup looks good; to restore, rename a .$BACKUP_SUFFIX file back."
fi
ok "Multiplexer: $MUX"
if [ "$MUX" != herdr ]; then
  dim "tmux plugins live outside this repo: clone TPM once, then press <prefix> + I (see README)."
fi
ok "All done! Open a new shell (or run 'source ~/.zshrc') to pick up changes."
