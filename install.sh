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
Usage: ./install.sh [--herdr | --tmux | --both] [--install-deps | --no-install-deps]

Options:
  --herdr             Set up herdr as the terminal multiplexer.
  --tmux              Set up tmux instead.
  --both              Keep both linked and installed.
  --install-deps      Install missing tools without asking (uses sudo).
  --no-install-deps   Never install anything, only report what is missing.
  -h, --help          Show this help.

With no option the script keeps whatever is already linked, so re-running it as
an updater never changes your setup. On a fresh machine it asks, or picks herdr
when it cannot (no terminal attached). DOTFILES_MUX=<tmux|herdr|both> does the
same job for scripted runs; a flag wins over the variable.

--both is not the same as running with no option: no option means "keep the
current setup", --both means "make it both", which re-links the multiplexer you
previously dropped.

Switching only ever removes symlinks that point into this repo. Your tmux
plugins, herdr session files and any real config file are left untouched.

Missing tools are detected on every run. With a terminal attached the script
offers to install them with the system package manager (apt, pacman, dnf,
zypper, apk) or, on macOS, from the Brewfile; otherwise it prints the exact
command. DOTFILES_INSTALL_DEPS=<yes|no|ask> matches the flags above. Whatever is
still missing at the end is listed again, so the list never scrolls away.
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
# yes = 直接裝，no = 完全不裝，ask = 互動時才問（非互動等於 no）
# yes = install without asking, no = never install, ask = prompt when interactive
INSTALL_DEPS="${DOTFILES_INSTALL_DEPS:-ask}"
while [ $# -gt 0 ]; do
  case "$1" in
    --tmux)  MUX="tmux";  MUX_SOURCE="--tmux";  shift ;;
    --herdr) MUX="herdr"; MUX_SOURCE="--herdr"; shift ;;
    --both)  MUX="both";  MUX_SOURCE="--both";  shift ;;
    --install-deps)    INSTALL_DEPS="yes"; shift ;;
    --no-install-deps) INSTALL_DEPS="no";  shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; printf '\n' >&2; usage >&2; exit 2 ;;
  esac
done

case "$INSTALL_DEPS" in
  yes|no|ask) ;;
  1|true)  INSTALL_DEPS="yes" ;;
  0|false) INSTALL_DEPS="no"  ;;
  *) err "Unknown value in DOTFILES_INSTALL_DEPS: $INSTALL_DEPS (expected yes, no or ask)"; exit 2 ;;
esac

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

# ---------- 2. 依賴套件 / Dependencies ----------
# 每行一個必備工具 / one required tool per line:
#   <偵測用指令 / command to probe>|<apt>|<pacman>|<dnf>|<zypper>|<apk>|<brew>
required_tools() {
  cat <<'EOF'
stow|stow|stow|stow|stow|stow|stow
git|git|git|git|git|git|git
zsh|zsh|zsh|zsh|zsh|zsh|zsh
nvim|neovim|neovim|neovim|neovim|neovim|neovim
fzf|fzf|fzf|fzf|fzf|fzf|fzf
rg|ripgrep|ripgrep|ripgrep|ripgrep|ripgrep|ripgrep
fd|fd-find|fd|fd-find|fd|fd|fd
tree|tree|tree|tree|tree|tree|tree
chafa|chafa|chafa|chafa|chafa|chafa|chafa
zoxide|zoxide|zoxide|zoxide|zoxide|zoxide|zoxide
EOF
  if [ "$MUX" = tmux ] || [ "$MUX" = both ]; then
    printf 'tmux|tmux|tmux|tmux|tmux|tmux|tmux\n'
  fi
}

have_cmd() {
  case "$1" in
    # Debian/Ubuntu 的 fd-find 裝出來的執行檔叫 fdfind
    # Debian/Ubuntu's fd-find installs the binary as fdfind
    fd) command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 ;;
    *)  command -v "$1" >/dev/null 2>&1 ;;
  esac
}

# PKG_FIELD 是這個套件管理員在上面表格中的欄位編號。
# PKG_FIELD is this package manager's column number in the table above.
PKG_MGR=""; PKG_FIELD=""
if   command -v brew    >/dev/null 2>&1; then PKG_MGR="brew";   PKG_FIELD=7
elif command -v apt-get >/dev/null 2>&1; then PKG_MGR="apt";    PKG_FIELD=2
elif command -v pacman  >/dev/null 2>&1; then PKG_MGR="pacman"; PKG_FIELD=3
elif command -v dnf     >/dev/null 2>&1; then PKG_MGR="dnf";    PKG_FIELD=4
elif command -v zypper  >/dev/null 2>&1; then PKG_MGR="zypper"; PKG_FIELD=5
elif command -v apk     >/dev/null 2>&1; then PKG_MGR="apk";    PKG_FIELD=6
fi

# Homebrew 一律不用 sudo / Homebrew must never run under sudo
if [ "$(id -u)" -eq 0 ] || [ "$PKG_MGR" = brew ]; then SUDO=""; else SUDO="sudo"; fi

# 用 PKG_MGR 的語法組出「安裝這些套件」的完整指令，好讓使用者直接複製貼上。
# Build the full "install these packages" command for PKG_MGR, so it can be
# copy-pasted as-is.
install_cmd_for() {
  local pkgs="$1" s="${SUDO:+$SUDO }"
  case "$PKG_MGR" in
    brew)   printf 'brew install %s' "$pkgs" ;;
    apt)    printf '%sapt-get update && %sapt-get install -y %s' "$s" "$s" "$pkgs" ;;
    pacman) printf '%spacman -S --needed --noconfirm %s' "$s" "$pkgs" ;;
    dnf)    printf '%sdnf install -y %s' "$s" "$pkgs" ;;
    zypper) printf '%szypper install -y %s' "$s" "$pkgs" ;;
    apk)    printf '%sapk add %s' "$s" "$pkgs" ;;
  esac
}

# 掃一遍表格，把「指令不存在」的工具收進 MISSING_CMDS / MISSING_PKGS。
# Walk the table and collect every tool whose command is absent.
MISSING_CMDS=""; MISSING_PKGS=""
collect_missing() {
  local line cmd pkg
  MISSING_CMDS=""; MISSING_PKGS=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    cmd="${line%%|*}"
    have_cmd "$cmd" && continue
    MISSING_CMDS="$MISSING_CMDS $cmd"
    if [ -n "$PKG_FIELD" ]; then
      pkg="$(printf '%s\n' "$line" | cut -d'|' -f"$PKG_FIELD")"
      MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
  done <<EOF
$(required_tools)
EOF
  MISSING_CMDS="${MISSING_CMDS# }"
  MISSING_PKGS="${MISSING_PKGS# }"
}

# 沒裝成的東西留到最後再報一次，才不會被中間的訊息洗掉。
# Anything still missing is repeated at the very end, so it does not scroll away.
# bash 3.2（macOS 內建）在 set -u 下碰空陣列會炸，所以另外數一個計數器。
# bash 3.2 (the one macOS ships) trips over empty arrays under set -u, hence the
# separate counter.
TODO=(); TODO_COUNT=0
todo() { TODO+=("$1"); TODO_COUNT=$((TODO_COUNT + 1)); }

# $1 = 問句 / question. 只有互動時才問；非互動一律當作「否」。
# Only ask when interactive; a non-interactive run always answers "no".
confirm() {
  local reply
  [ -t 0 ] || return 1
  printf '%s [Y/n] ' "$1" >&2
  if ! read -r reply; then printf '\n' >&2; return 1; fi
  reply="${reply%$'\r'}"
  case "$reply" in
    ""|y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

# Debian/Ubuntu 只給 fdfind，但 .zshrc 的 fzf 整合找的是 fd。
# Debian/Ubuntu ship only fdfind, while the fzf integration in .zshrc looks for fd.
link_fdfind() {
  command -v fdfind >/dev/null 2>&1 || return 0
  command -v fd     >/dev/null 2>&1 && return 0
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  ok "Linked fdfind -> ~/.local/bin/fd (Debian calls the fd binary fdfind)"
}

step "Checking dependencies"
if [ "$PKG_MGR" = brew ]; then
  if [ "$INSTALL_DEPS" = no ]; then
    info "Homebrew found, but skipping the Brewfile (--no-install-deps)"
  else
    info "Homebrew found, installing from Brewfile (multiplexer: $MUX)"
    if brew bundle --file="$DOTFILES/Brewfile"; then
      ok "All Brewfile packages are ready"
    else
      warn "Some Brewfile entries failed (e.g. a font already installed manually)"
      dim "This does not affect linking below, continuing."
    fi
  fi
  collect_missing
  if [ -n "$MISSING_CMDS" ]; then
    warn "Missing tools: $MISSING_CMDS"
    dim "$(install_cmd_for "$MISSING_PKGS")"
    todo "Missing tools: $MISSING_CMDS  ->  $(install_cmd_for "$MISSING_PKGS")"
  else
    ok "All required tools are installed"
  fi
else
  collect_missing
  if [ -z "$MISSING_CMDS" ]; then
    ok "All required tools are installed"
  elif [ -z "$PKG_MGR" ]; then
    warn "Missing tools: $MISSING_CMDS"
    dim "No supported package manager found (apt, pacman, dnf, zypper, apk)."
    dim "Install those tools with your package manager, then re-run this script."
    todo "Missing tools: $MISSING_CMDS (install them with your package manager)"
  else
    warn "Missing tools: $MISSING_CMDS"
    INSTALL_LINE="$(install_cmd_for "$MISSING_PKGS")"
    dim "$INSTALL_LINE"
    RUN_IT=no
    case "$INSTALL_DEPS" in
      yes) RUN_IT=yes ;;
      no)  info "Skipping the install (--no-install-deps)" ;;
      *)   if confirm "Install them now with $PKG_MGR?"; then RUN_IT=yes; fi ;;
    esac
    if [ "$RUN_IT" = yes ]; then
      if sh -c "$INSTALL_LINE"; then
        collect_missing
        [ -z "$MISSING_CMDS" ] && ok "All required tools are installed"
      else
        warn "The install command failed (exit $?)"
      fi
    fi
    if [ -n "$MISSING_CMDS" ]; then
      todo "Missing tools: $MISSING_CMDS  ->  $(install_cmd_for "$MISSING_PKGS")"
    fi
  fi
  link_fdfind
fi

# 這幾個大多數發行版都沒包，只能各自安裝，所以單獨檢查並給出指令。
# These are not packaged by most distros, so check them separately and print the
# exact command for each one.
# 有 Homebrew 的話這幾個 Brewfile 都有，指令就給 brew 版本。
# With Homebrew the Brewfile covers these, so quote the brew command instead.
if [ "$PKG_MGR" = brew ]; then
  STYLUA_CMD="brew install stylua"
  UV_CMD="brew install uv"
else
  STYLUA_CMD="cargo install stylua"
  UV_CMD="curl -LsSf https://astral.sh/uv/install.sh | sh"
fi
if ! command -v stylua >/dev/null 2>&1; then
  warn "stylua is missing (Lua formatter for the Neovim config)"
  dim "  $STYLUA_CMD"
  todo "stylua  ->  $STYLUA_CMD"
fi
if ! command -v uv >/dev/null 2>&1; then
  warn "uv is missing (Python package/venv manager)"
  dim "  $UV_CMD"
  todo "uv  ->  $UV_CMD"
fi
if [ "$MUX" != tmux ] && ! command -v herdr >/dev/null 2>&1; then
  warn "herdr is missing, and it is the multiplexer this run links"
  if [ "$PKG_MGR" = brew ]; then
    dim "  brew install herdr"
    todo "herdr  ->  brew install herdr"
  else
    dim "  curl -fsSL https://herdr.dev/install.sh | sh"
    HERDR_RUN=no
    if command -v curl >/dev/null 2>&1; then
      case "$INSTALL_DEPS" in
        yes) HERDR_RUN=yes ;;
        no)  ;;
        *)   if confirm "Run the official herdr installer now?"; then HERDR_RUN=yes; fi ;;
      esac
    else
      dim "  (curl is not installed, so this run cannot fetch it for you)"
    fi
    if [ "$HERDR_RUN" = yes ]; then
      if curl -fsSL https://herdr.dev/install.sh | sh; then
        ok "herdr installed"
      else
        warn "The herdr installer failed (exit $?)"
      fi
    fi
    command -v herdr >/dev/null 2>&1 \
      || todo "herdr  ->  curl -fsSL https://herdr.dev/install.sh | sh"
  fi
fi

# ---------- 3. 連結步驟需要 GNU stow / stow is required for linking ----------
step "Checking for GNU stow"
if command -v stow >/dev/null 2>&1; then
  sv="$(stow --version 2>/dev/null | head -n1 || true)"
  ok "Found stow (${sv:-unknown})"
else
  err "GNU stow is required for the linking step but is not installed."
  if [ -n "$PKG_MGR" ]; then
    dim "$(install_cmd_for stow)"
  else
    dim "Install it with your package manager (macOS: brew install stow), then re-run this script."
  fi
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
if [ "$TODO_COUNT" -gt 0 ]; then
  warn "Still to install (nothing below was installed by this run):"
  for item in ${TODO[@]+"${TODO[@]}"}; do
    dim "$item"
  done
  dim "The configs are linked either way; those tools just stay unavailable."
fi
ok "Multiplexer: $MUX"
if [ "$MUX" != herdr ]; then
  dim "tmux plugins live outside this repo: clone TPM once, then press <prefix> + I (see README)."
fi
ok "All done! Open a new shell (or run 'source ~/.zshrc') to pick up changes."
