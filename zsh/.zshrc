# =====================
#  P10k 自訂設定
# =====================
# 啟用 Powerlevel10k 的即時提示字元（instant prompt）。這段應該盡量保持在 ~/.zshrc 的最上方。
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


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
# 按需啟動 tmux：main 存在就 attach，不存在就開新 session
alias t='tmux new-session -A -s main'

if command -v gls > /dev/null 2>&1; then
  alias ls='gls -hlF --color=auto'
else
  alias ls='ls -hlFG'
fi
alias ..='cd ../'
alias tree="tree -alI 'node_modules|.git'"
alias grep='grep --color=always'
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
command -v fzf > /dev/null 2>&1 && eval "$(fzf --zsh)"
[[ -o interactive ]] && command -v zoxide > /dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"

# 載入一些 API 金鑰（本機隱藏變數）
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# 將 poetry 執行檔路徑加入環境變數
export PATH=$PATH:$HOME/.local/bin

# 載入 uv 的 shell 自動補齊
command -v uv > /dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"
