# Install

Clone to your home folder, then run the bootstrap script:

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` links every config with GNU Stow and, **if Homebrew is present**,
installs the dependencies from the [`Brewfile`](./Brewfile). It never installs
a package manager for you.

### macOS
Install [Homebrew](https://brew.sh/) once, then `./install.sh` handles the rest
(the Brewfile also pulls in Ghostty and the Nerd Font on macOS).

### Linux
Homebrew is not required — install the tools with your native package manager
first, then run `./install.sh` (it will skip the Brewfile and just link configs):

```bash
# Debian/Ubuntu
sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide
# Arch
sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide
```

Notes:
- `stylua` and `uv` aren't in most distro repos — install via `cargo install stylua`
  and the [uv installer](https://docs.astral.sh/uv/).
- On Debian/Ubuntu the `fd` binary is named `fdfind`; symlink it so the fzf
  integration finds it: `ln -s "$(command -v fdfind)" ~/.local/bin/fd`.

# Update

```bash
cd ~/dotfiles
git pull
./install.sh          # re-links new files + installs any new Brewfile deps
```

Other handy commands:

```bash
brew update && brew upgrade   # upgrade all Homebrew packages (macOS)
brew bundle cleanup           # list packages no longer in the Brewfile
                              #   add --force to actually uninstall them
stow --target ~/.config -D .  # unlink everything (reverse of install)
```

# Tmux plugins (TPM)

Tmux plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and are
**not** tracked in this repo. After the configs are linked, set it up once:

```bash
# 1. Clone TPM into the location tmux.conf expects
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. Start tmux, then press `<prefix> + I` (prefix is `Ctrl + S`) to install every
   plugin listed in `tmux.conf`. Use `<prefix> + U` to update them later.

# Other tools
- [Ghostty](https://ghostty.org/)
  - [MesloLGS Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) (p10k 圖示必要)
- [Zsh](https://www.zsh.org/)
  - [zinit](https://github.com/zdharma-continuum/zinit)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
  - [fzf](https://github.com/junegunn/fzf)
  - [uv](https://github.com/astral-sh/uv) (optional)
  - [tree](https://formulae.brew.sh/formula/tree) (optional)
- [Tmux](https://github.com/tmux/tmux)
  - [tpm](https://github.com/tmux-plugins/tpm) (plugin manager)
- [NeoVim](https://neovim.io/)
  - [chafa](https://hpjansson.org/chafa/) (dashboard 圖片渲染必要)

# Keybindings

只列自己客製化的部分。LazyVim / Ghostty / Tmux 原生預設快捷鍵不重複列出。

## Ghostty

| Key | Action |
| --- | --- |
| `Cmd + C` / `Cmd + V` | Copy / Paste |
| `Cmd + ,` | Open config |
| `Cmd + Shift + ,` | Reload config |
| `Cmd + Shift + O` | Toggle background opacity |

## Zsh

| Key | Action |
| --- | --- |
| `jk` *(insert)* | Exit to normal mode (vi-mode) |
| `Ctrl + P` | History search backward (prefix match) |
| `Ctrl + N` | History search forward (prefix match) |
| `t` *(command)* | Attach/create tmux session `main` |

## Tmux

Prefix 已從預設 `Ctrl+B` 改為 **`Ctrl + S`**。以下 `<prefix>` 代表按一次 prefix 後再按的鍵。

| Key | Action |
| --- | --- |
| `<prefix> \|` | Split pane 左右 |
| `<prefix> _` | Split pane 上下 |
| `<prefix> h / j / k / l` | Resize pane（可連按） |
| `<prefix> r` | Reload `tmux.conf` |
| `<prefix> Ctrl + S` | Save session (tmux-resurrect) |
| `<prefix> Ctrl + R` | Restore session (tmux-resurrect) |
| `Ctrl + h / j / k / l` | Seamless 切換 vim/tmux 窗格 (vim-tmux-navigator) |
| `v` *(copy-mode)* | Begin selection |
| `y` *(copy-mode)* | Copy selection |

## Neovim

Leader 為 `<space>`（LazyVim 預設）。

### General

| Key | Action |
| --- | --- |
| `jk` *(insert)* | Exit insert mode |
| `<leader>nh` | Clear search highlights |

### Windows / Splits

| Key | Action |
| --- | --- |
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close current split |

### Buffers (BufferLine)

| Key | Action |
| --- | --- |
| `Tab` | Next buffer |
| `Shift + Tab` | Previous buffer |
| `Ctrl + P` | Pick buffer |
| `<leader>X` | Close current buffer |
| `<leader>A` | Close all buffers except current |

### Treesitter (incremental selection)

| Key | Action |
| --- | --- |
| `S` | Start / expand selection |
| `Backspace` | Shrink selection |

### Tests (Neotest)

| Key | Action |
| --- | --- |
| `]n` / `[n` | Next / previous test |
| `]N` / `[N` | Next / previous **failed** test |

### Rust (crates.nvim)

| Key | Action |
| --- | --- |
| `<leader>cf` | Crate features popup |
| `<leader>cd` | Crate dependencies popup |
| `<leader>cH` | Open crate homepage |
| `<leader>cG` | Open crate repository |
| `<leader>cD` | Open crate documentation |
| `<leader>cC` | Open on crates.io |
