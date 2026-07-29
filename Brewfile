# Brewfile — 一次裝好所有依賴 / install every dependency in one shot:
#   cd ~/dotfiles && brew bundle
# 只檢查缺什麼不安裝 / Check what's missing without installing:  brew bundle check --verbose

# --- 核心 / Core ---
brew "stow"        # symlink manager for these dotfiles
brew "git"
brew "neovim"

# 終端多工器由 install.sh 決定，透過 HOMEBREW_DOTFILES_MUX 傳進來。
# 一定要用 HOMEBREW_ 開頭：brew 會把其他自訂環境變數濾掉，Brewfile 讀不到。
# 直接跑 `brew bundle` 沒帶變數時預設兩個都裝，`brew bundle cleanup` 才不會
# 誤判成「該移除」。
# install.sh picks the multiplexer and passes it in as
# HOMEBREW_DOTFILES_MUX. The HOMEBREW_ prefix is required: brew scrubs other
# custom variables out of the environment before the Brewfile is evaluated.
# A bare `brew bundle` defaults to both, so `brew bundle cleanup` never reads an
# unset variable as "uninstall the other one".
mux = ENV["HOMEBREW_DOTFILES_MUX"] || "both"
brew "tmux"  if %w[tmux both].include?(mux)   # terminal multiplexer
brew "herdr" if %w[herdr both].include?(mux)  # terminal workspace manager, 逐步取代 tmux

# --- Shell 與導覽 / Shell & navigation ---
brew "fzf"         # fuzzy finder
brew "zoxide"      # smarter cd
brew "fd"          # fast find (fzf backend)
brew "ripgrep"     # fast grep (fzf / telescope backend)
brew "tree"
brew "coreutils"   # GNU coreutils -> `gls`, used by the ls alias

# --- 開發工具 / Dev tooling ---
brew "stylua"      # Lua formatter (see nvim/stylua.toml)
brew "chafa"       # renders the Neovim dashboard image
brew "uv"          # Python package/venv manager

# --- 應用程式與字型 / Apps & fonts (macOS only; casks don't exist on Linux) ---
if OS.mac?
  cask "ghostty"
  # Nerd Font for p10k / tmux glyphs.
  # 若已手動裝過同名字型，這行會衝突失敗；install.sh 會忽略並繼續。
  # Conflicts (and fails) if the same font was installed manually;
  # install.sh treats that as non-fatal and carries on.
  cask "font-meslo-lg-nerd-font"
end
