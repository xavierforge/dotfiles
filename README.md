# Install

Clone to your home folder, then run the bootstrap script:

```bash
git clone https://github.com/xavierforge/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

> Make sure your login shell is **zsh** (`echo $SHELL`). If it isn't, switch
> with `chsh -s "$(command -v zsh)"` and reopen the terminal — otherwise
> `.zshrc` never loads. macOS already defaults to zsh; many Linux distros don't.

`install.sh` links every config with GNU Stow and, **if Homebrew is present**,
installs the dependencies from the [`Brewfile`](./Brewfile). It never installs
a package manager for you.

> If Stow complains that a target already exists (e.g. you already have a
> `~/.zshrc`), back up or remove that file first — Stow won't overwrite files
> it didn't create.

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
- `herdr` isn't packaged by distros either. With Homebrew it comes from the
  Brewfile; without it, use `curl -fsSL https://herdr.dev/install.sh | sh`
  (see [Herdr](#herdr) below).
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

# Herdr

[Herdr](https://herdr.dev) 是正在取代 tmux 的終端工作區管理器，設定檔為
`herdr/config.toml`，install.sh 會把它連到 herdr 讀取的位置
`~/.config/herdr/config.toml`。

Herdr 由 Homebrew 管理（在 Brewfile 裡），升級走 `brew upgrade herdr`，
**不要**用內建的 `herdr update` — 那個自我更新器是給官方安裝腳本裝在
`~/.local/bin/herdr` 的版本用的，會去覆寫 brew 管理的檔案。同理，
`herdr channel set preview` 的 preview 頻道在 brew 上也拿不到，brew 只跟 stable。
真的要用 preview，就得改回官方安裝腳本：

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

改完設定後讓執行中的 server 重新載入（不必重開 session）：

```bash
herdr server reload-config
```

> `~/.config/herdr/` 同時放 socket、log 與 `session.json`，所以 install.sh 會先
> `mkdir -p` 這個真實目錄，讓 Stow 只連結 `config.toml`。少了這一步，Stow 會在
> 全新機器上把整個目錄折疊成一個指向本 repo 的符號連結，執行期檔案就會被寫進
> dotfiles 裡。

# Other tools
- [Herdr](https://herdr.dev) (terminal workspace manager, 逐步取代 tmux)
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

只列自己客製化的部分。LazyVim / Ghostty / Tmux / Herdr 原生預設快捷鍵不重複列出。

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

## Herdr

Prefix 為 **`Ctrl + S`**，與下方 tmux 一致，兩邊肌肉記憶不用切換。
綁定的來源對應寫在 `herdr/config.toml` 每個設定上方的 `# tmux:` 註解裡。

| Key | Action |
| --- | --- |
| `<prefix> \|` | Split pane 左右 |
| `<prefix> _` | Split pane 上下 |
| `<prefix> c` | 新增 tab |
| `<prefix> ,` | Rename tab |
| `<prefix> r` | 進入 resize 模式（再用 `h/j/k/l` 調整，`Esc` 離開） |
| `<prefix> R` | Reload `config.toml` |
| `Ctrl + h / j / k / l` | 切換 pane（不需 prefix） |
| `<prefix> [` | 進入 copy mode |
| `Alt + 1` ~ `Alt + 9` | 直接切換到第 N 個 tab |

與 tmux 的兩處差異：

- **Resize 是「模式」不是連按**。tmux 是 `<prefix>` 後連按 `h/j/k/l`；herdr 是
  `<prefix> r` 進入模式後再調整，`Esc` 離開。連帶地 reload 從 tmux 的
  `<prefix> r` 移到 `<prefix> R`（herdr 預設）。
- **Session 存檔不需要按鍵**。tmux-resurrect 的 `<prefix> Ctrl+S` / `Ctrl+R`
  由 herdr 的 server/client 架構原生取代。

切換 pane 的 `Ctrl + h/j/k/l` 不需要 prefix，與原本 vim-tmux-navigator 的手感相同。

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
