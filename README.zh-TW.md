[English](./README.md) | [繁體中文](./README.zh-TW.md)

# 安裝

Clone 到家目錄，然後執行 bootstrap 腳本：

```bash
git clone https://github.com/xavierforge/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

> 確認登入 shell 是 **zsh**（`echo $SHELL`）。若不是，用
> `chsh -s "$(command -v zsh)"` 切換後重開終端機，否則 `.zshrc` 根本不會載入。
> macOS 預設就是 zsh，但很多 Linux 發行版不是。

`install.sh` 會用 GNU Stow 連結所有設定檔，**如果系統上有 Homebrew**，就順便
安裝 [`Brewfile`](./Brewfile) 裡的相依套件。它不會幫你安裝套件管理器。

> 如果 Stow 抱怨目標已存在（例如你本來就有 `~/.zshrc`），請先備份或刪掉那個
> 檔案。Stow 不會覆寫不是它建立的檔案。

### macOS
先裝一次 [Homebrew](https://brew.sh/)，剩下的交給 `./install.sh`
（在 macOS 上 Brewfile 也會一併裝好 Ghostty 與 Nerd Font）。

### Linux
不需要 Homebrew。先用發行版原生的套件管理器裝好工具，再執行 `./install.sh`
（它會跳過 Brewfile，只做設定檔連結）：

```bash
# Debian/Ubuntu
sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide
# Arch
sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide
```

注意事項：
- 多數發行版的套件庫沒有 `stylua` 與 `uv`，請改用 `cargo install stylua` 和
  [uv 安裝器](https://docs.astral.sh/uv/)。
- `herdr` 同樣沒有發行版套件。有 Homebrew 的話由 Brewfile 提供；沒有的話用
  `curl -fsSL https://herdr.dev/install.sh | sh`（見下方 [Herdr](#herdr)）。
- Debian/Ubuntu 的 `fd` 執行檔叫 `fdfind`，建個 symlink 讓 fzf 整合找得到：
  `ln -s "$(command -v fdfind)" ~/.local/bin/fd`。

# 更新

```bash
cd ~/dotfiles
git pull
./install.sh          # 重新連結新檔案 + 安裝 Brewfile 新增的相依套件
```

其他常用指令：

```bash
brew update && brew upgrade   # 升級所有 Homebrew 套件（macOS）
brew bundle cleanup           # 列出已經不在 Brewfile 裡的套件
                              #   加 --force 才會真的移除
stow --target ~/.config -D .  # 解除所有連結（install 的反向操作）
```

# Tmux 外掛（TPM）

Tmux 外掛由 [TPM](https://github.com/tmux-plugins/tpm) 管理，**不會**納入本
repo 版控。設定檔連結完成後，做一次設定即可：

```bash
# 1. 把 TPM clone 到 tmux.conf 預期的位置
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. 啟動 tmux，按 `<prefix> + I`（prefix 是 `Ctrl + S`）安裝 `tmux.conf` 裡列出的
   所有外掛。之後用 `<prefix> + U` 更新。

# Herdr

[Herdr](https://herdr.dev) 是正在取代 tmux 的終端工作區管理器，設定檔為
`herdr/config.toml`，install.sh 會把它連到 herdr 讀取的位置
`~/.config/herdr/config.toml`。

Herdr 由 Homebrew 管理（在 Brewfile 裡），升級走 `brew upgrade herdr`，
**不要**用內建的 `herdr update`，那個自我更新器是給官方安裝腳本裝在
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

# 其他工具
- [Herdr](https://herdr.dev)（終端工作區管理器，逐步取代 tmux）
- [Ghostty](https://ghostty.org/)
  - [MesloLGS Nerd Font](https://github.com/romkatv/powerlevel10k#fonts)（p10k 圖示必要）
- [Zsh](https://www.zsh.org/)
  - [zinit](https://github.com/zdharma-continuum/zinit)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
  - [fzf](https://github.com/junegunn/fzf)
  - [uv](https://github.com/astral-sh/uv)（選用）
  - [tree](https://formulae.brew.sh/formula/tree)（選用）
- [Tmux](https://github.com/tmux/tmux)
  - [tpm](https://github.com/tmux-plugins/tpm)（外掛管理器）
- [NeoVim](https://neovim.io/)
  - [chafa](https://hpjansson.org/chafa/)（dashboard 圖片渲染必要）

# 快捷鍵

只列自己客製化的部分。LazyVim / Ghostty / Tmux / Herdr 原生預設快捷鍵不重複列出。

## Ghostty

| Key | Action |
| --- | --- |
| `Cmd + C` / `Cmd + V` | 複製 / 貼上 |
| `Cmd + ,` | 開啟設定檔 |
| `Cmd + Shift + ,` | 重新載入設定 |
| `Cmd + Shift + O` | 切換背景透明度 |

## Zsh

| Key | Action |
| --- | --- |
| `jk` *(insert)* | 回到 normal mode（vi-mode） |
| `Ctrl + P` | 往前搜尋歷史指令（前綴比對） |
| `Ctrl + N` | 往後搜尋歷史指令（前綴比對） |
| `t` *(command)* | 連接／建立 tmux session `main` |

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
| `<prefix> Ctrl + S` | 儲存 session（tmux-resurrect） |
| `<prefix> Ctrl + R` | 還原 session（tmux-resurrect） |
| `Ctrl + h / j / k / l` | Seamless 切換 vim/tmux 窗格（vim-tmux-navigator） |
| `v` *(copy-mode)* | 開始選取 |
| `y` *(copy-mode)* | 複製選取內容 |

## Neovim

Leader 為 `<space>`（LazyVim 預設）。

### 一般

| Key | Action |
| --- | --- |
| `jk` *(insert)* | 離開 insert mode |
| `<leader>nh` | 清除搜尋高亮 |

### 視窗 / 分割

| Key | Action |
| --- | --- |
| `<leader>sv` | 垂直分割 |
| `<leader>sh` | 水平分割 |
| `<leader>se` | 平均分配分割大小 |
| `<leader>sx` | 關閉目前分割 |

### Buffers（BufferLine）

| Key | Action |
| --- | --- |
| `Tab` | 下一個 buffer |
| `Shift + Tab` | 上一個 buffer |
| `Ctrl + P` | 挑選 buffer |
| `<leader>X` | 關閉目前 buffer |
| `<leader>A` | 關閉除目前以外的所有 buffer |

### Treesitter（漸進式選取）

| Key | Action |
| --- | --- |
| `S` | 開始／擴大選取範圍 |
| `Backspace` | 縮小選取範圍 |

### 測試（Neotest）

| Key | Action |
| --- | --- |
| `]n` / `[n` | 下一個／上一個測試 |
| `]N` / `[N` | 下一個／上一個**失敗**的測試 |

### Rust（crates.nvim）

| Key | Action |
| --- | --- |
| `<leader>cf` | Crate features 彈出視窗 |
| `<leader>cd` | Crate dependencies 彈出視窗 |
| `<leader>cH` | 開啟 crate 首頁 |
| `<leader>cG` | 開啟 crate repository |
| `<leader>cD` | 開啟 crate 文件 |
| `<leader>cC` | 在 crates.io 開啟 |
