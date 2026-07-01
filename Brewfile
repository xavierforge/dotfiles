# Brewfile — install every dependency in one shot:
#   cd ~/dotfiles && brew bundle
# Check what's missing without installing:  brew bundle check --verbose

# --- Core ---
brew "stow"        # symlink manager for these dotfiles
brew "git"
brew "neovim"
brew "tmux"

# --- Shell & navigation ---
brew "fzf"         # fuzzy finder
brew "zoxide"      # smarter cd
brew "fd"          # fast find (fzf backend)
brew "ripgrep"     # fast grep (fzf / telescope backend)
brew "tree"
brew "coreutils"   # GNU coreutils -> `gls`, used by the ls alias

# --- Dev tooling ---
brew "stylua"      # Lua formatter (see nvim/stylua.toml)
brew "chafa"       # renders the Neovim dashboard image
brew "uv"          # Python package/venv manager

# --- Apps & fonts (macOS only; casks don't exist on Linux) ---
if OS.mac?
  cask "ghostty"
  cask "font-meslo-lg-nerd-font"  # Nerd Font for p10k / tmux glyphs
end
