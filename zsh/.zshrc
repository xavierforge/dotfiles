# =====================
#  P10k 自訂設定 / P10k customization
# =====================
# 啟用 Powerlevel10k 的即時提示字元（instant prompt）。這段應該盡量保持在 ~/.zshrc 的最上方。
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# =====================
#       Homebrew
# =====================
# 把 brew 加進 PATH（要在下面 command -v 檢查工具之前）。
# 路徑因平台而異：macOS ARM=/opt/homebrew、macOS Intel=/usr/local、Linux=/home/linuxbrew/.linuxbrew
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$_brew" ]] && eval "$("$_brew" shellenv)" && break
done
unset _brew


# =====================
#     Plugin Manager
# =====================
# 存放 Zinit 和外掛的資料夾
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# 如果尚未安裝 Zinit，則自動執行下載安裝
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# 載入 Zinit
source "${ZINIT_HOME}/zinit.zsh"

# =====================
#       Plugins
# =====================
# Load powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k
# 基本功能（語法高亮、自動補齊、指令建議）
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
# fzf auto completion menu
zinit light Aloxaf/fzf-tab
zinit light djui/alias-tips
# Oh my Zsh plugins
zinit snippet OMZP::git


# =====================
#      Keybindings
# =====================
# 啟用 vi 模式並將 jk 設為回到一般模式
set -o vi
bindkey -M viins 'jk' vi-cmd-mode
export KEYTIMEOUT=15

# 使用 Ctrl+P / Ctrl+N 根據輸入的字首來搜尋歷史紀錄
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# =====================
#       Aliases
# =====================
# 按需啟動終端多工器，跟著 install.sh 連結了哪一邊走
# herdr：直接執行就會 attach 或建立常駐 session
# tmux ：main 存在就 attach，不存在就開新 session
if [[ -L ~/.config/herdr/config.toml ]]; then
  alias t='herdr'
else
  alias t='tmux new-session -A -s main'
fi

if command -v gls > /dev/null 2>&1; then
  alias ls='gls -hlF --color=auto'
else
  alias ls='ls -hlFG'
fi
alias ..='cd ../'
alias tree="tree -alI 'node_modules|.git'"
alias grep='grep --color=auto'
alias grepFind='grep --exclude-dir=node_modules -nr . -e'
alias mkdir='mkdir -p'
alias codei='code-insiders'
alias cld='claude --dangerously-skip-permissions'

# 預設編輯器
export EDITOR=nvim
export VISUAL=nvim


# =====================
#       History
# =====================
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
export HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups


# =====================
#  Other Customizations
# =====================
# 載入自動補齊功能（一天內使用 cache 加速啟動，超過 24h 才重建 dump）
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zinit cdreplay -q
# Tab 自動補齊設定：忽略大小寫並加上顏色
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'command ls -G $realpath 2>/dev/null || command ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'command ls -G $realpath 2>/dev/null || command ls --color $realpath'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Fuzzy finding shell integration
# 用 fd 當後端：尊重 .gitignore、跳過 .git、含隱藏檔，速度遠快於內建 find
if command -v fd > /dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"          # Ctrl-T 選檔案
  export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'  # Alt-C 選目錄
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
command -v fzf > /dev/null 2>&1 && eval "$(fzf --zsh)"
[[ -o interactive ]] && command -v zoxide > /dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"

# 載入一些 API 金鑰（本機隱藏變數）
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# 將 poetry 執行檔路徑加入環境變數
export PATH=$PATH:$HOME/.local/bin

# 載入 uv 的 shell 自動補齊
command -v uv > /dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"

# bun 自動補齊 / bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun 安裝路徑與 PATH / bun install path and PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "/Users/chihying/.bun/_bun" ] && source "/Users/chihying/.bun/_bun"
