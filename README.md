# How to use?
1. Clone this repo to the home folder (`~`)
2. Install [GNU Stow](https://www.gnu.org/software/stow/)
3. Create `~/.config/` if the folder does not exist
4. `cd` into `~/dotfiles`
6. Use stow to create symlinks:
     ```bash
     stow --target ~/.config . # Use `stow --target ~/.config -D .` to delete
     stow zsh
     ```

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
| `Ctrl + A` | Select all (`gg V G`) |
| `Ctrl + D` | Jump to next diagnostic |

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
