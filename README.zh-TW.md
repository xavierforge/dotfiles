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

`install.sh` 會用 GNU Stow 連結所有設定檔，並檢查這些設定需要的工具是不是都裝
好了。缺什麼會直接列出名字，附上這台機器對應的安裝指令（Homebrew、apt、pacman、
dnf、zypper 或 apk），而且可以直接讓腳本幫你執行：

```
▶  Checking dependencies
⚠️  Missing tools: stow zsh fd chafa
   sudo apt-get update && sudo apt-get install -y stow zsh fd-find chafa
Install them now with apt? [Y/n]
```

回答 `n` 就什麼都不裝，設定檔照樣會連結好。跑完之後，還沒裝的東西會在最後再列
一次，不會被中間的訊息捲掉。它不會幫你安裝套件管理器。

```bash
./install.sh --install-deps      # 不問，直接裝缺少的工具
./install.sh --no-install-deps   # 只回報，絕不安裝
```

腳本化的情境可以用 `DOTFILES_INSTALL_DEPS=<yes|no|ask>`。沒有終端機的執行
（被 pipe、CI）一律不會自己安裝，只會把指令印出來。

`install.sh` 還會在 `~/.ssh/sockets` 不存在時幫你建好（權限 `700`）。`~/.ssh/config`
不在這個 repo 裡，但裡面的 `ControlPath` 指向這個目錄，而 ssh 不會自己建立它，全新
機器上少了它，每條連線都會直接失敗（`unix_listener: cannot bind to path`）。

> 如果 Stow 抱怨目標已存在（例如你本來就有 `~/.zshrc`），請先備份或刪掉那個
> 檔案。Stow 不會覆寫不是它建立的檔案。

### 選擇 tmux 或 herdr

這個 repo 同時放了兩套終端多工器的設定，install.sh 只會連結你選的那一套：

```bash
./install.sh --herdr    # 只要 herdr（全新機器的預設）
./install.sh --tmux     # 只要 tmux
./install.sh --both     # 兩個都留著
```

不帶參數直接跑 `./install.sh` 會沿用目前已經連結的那一套，所以拿它當更新腳本
不會偷偷幫你換掉多工器。全新機器上它會互動詢問；沒有終端可問時（例如腳本內
呼叫）就預設 herdr。腳本化的場景可以用 `DOTFILES_MUX=<tmux|herdr|both>` 環境
變數指定，參數優先於變數。

注意 `--both` 跟「不帶參數」不一樣：不帶參數是「維持現狀」，`--both` 是「就是
要兩個」，會把先前拿掉的那一個重新連回來。

切換是非破壞性的：只會移除「指向這個 repo」的符號連結，tmux 外掛、herdr 的
session 檔案，以及任何真實設定檔都不會被動到。沒被選到的那個多工器在 Brewfile
裡會直接跳過，不會被安裝。

### macOS
先裝一次 [Homebrew](https://brew.sh/)，剩下的交給 `./install.sh`
（在 macOS 上 Brewfile 也會一併裝好 Ghostty 與 Nerd Font）。

### Linux
不需要 Homebrew：`./install.sh` 會直接用發行版自己的套件管理器（apt、pacman、
dnf、zypper 或 apk），而且安裝前一定會先問。想自己手動裝的話：

```bash
# Debian/Ubuntu
sudo apt install stow git zsh neovim tmux fzf ripgrep fd-find tree chafa zoxide
# Arch
sudo pacman -S stow git zsh neovim tmux fzf ripgrep fd tree chafa zoxide
```

（用 herdr 的話可以拿掉 `tmux`；腳本只會檢查你選的那一套多工器。）

注意事項：
- 多數發行版的套件庫沒有 `stylua` 與 `uv`，所以腳本只會印出指令：
  `cargo install stylua` 與 [uv 安裝器](https://docs.astral.sh/uv/)。
- `herdr` 同樣沒有發行版套件。有 Homebrew 的話由 Brewfile 提供；沒有的話腳本會
  問你要不要跑 `curl -fsSL https://herdr.dev/install.sh | sh`
  （見下方 [Herdr](#herdr)）。
- Debian/Ubuntu 的 `fd` 執行檔叫 `fdfind`。腳本兩個名字都認得，而且在只有
  `fdfind` 時會自動連結成 `~/.local/bin/fd`，讓 fzf 整合找得到（`.zshrc` 已經
  把那個目錄加進 `PATH`）。

# 更新

```bash
cd ~/dotfiles
git pull
./install.sh          # 重新連結新檔案 + 安裝 Brewfile 新增的相依套件
                      #   （會沿用目前的 tmux/herdr 選擇）
```

其他常用指令：

```bash
brew update && brew upgrade   # 升級所有 Homebrew 套件（macOS）
brew bundle cleanup           # 列出已經不在 Brewfile 裡的套件
                              #   加 --force 才會真的移除
stow --target ~/.config -D .  # 解除所有連結（install 的反向操作）
```

# Tmux 外掛（TPM）

只有選了 `tmux` 或 `both` 才需要看這段。Tmux 外掛由
[TPM](https://github.com/tmux-plugins/tpm) 管理，**不會**納入本 repo 版控。
設定檔連結完成後，做一次設定即可：

```bash
# 1. 把 TPM clone 到 tmux.conf 預期的位置
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. 啟動 tmux，按 `<prefix> + I`（prefix 是 `Ctrl + S`）安裝 `tmux.conf` 裡列出的
   所有外掛。之後用 `<prefix> + U` 更新。

# Herdr

[Herdr](https://herdr.dev) 是正在取代 tmux 的終端工作區管理器，設定檔為
`herdr/config.toml`，`install.sh --herdr` 會把它連到 herdr 讀取的位置
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

主題沿用 herdr 自己的預設（Catppuccin，深色），而且 `auto_switch` 必須維持關閉
（預設就是 `false`）。Ghostty 固定用 Catppuccin Frappe，`auto_switch` 一旦打開，
herdr 主題就會跟著 macOS 外觀切成 latte（白色），和深色的終端機湊在一起。

> `~/.config/herdr/` 同時放 socket、log 與 `session.json`，所以 install.sh 會先
> `mkdir -p` 這個真實目錄，讓 Stow 只連結 `config.toml`。少了這一步，Stow 會在
> 全新機器上把整個目錄折疊成一個指向本 repo 的符號連結，執行期檔案就會被寫進
> dotfiles 裡。

# 其他工具

兩個多工器是二選一（見[選擇 tmux 或 herdr](#選擇-tmux-或-herdr)），其餘工具一律安裝。

- [Herdr](https://herdr.dev)（終端工作區管理器，逐步取代 tmux）
- [Ghostty](https://ghostty.org/)
  - [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)（p10k 圖示必要）
  - Noto Sans Mono CJK TC（CJK 後備字型，漢字才會用台灣字形）
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
  - [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)（在瀏覽器預覽 Markdown，由 LazyVim 的 markdown extra 帶入；ssh 時改走隧道模式，見[遠端 Markdown 預覽（ssh）](#遠端-markdown-預覽ssh)）
- [Omarchy](https://omarchy.org/)（只有 `hypr/bindings.lua`，且只在偵測到 Omarchy
  時連結；見 [Hyprland / Omarchy](#hyprland--omarchy)）

# 遠端 Markdown 預覽（ssh）

在 ssh 進去的遠端主機上開 Neovim 時，`markdown-preview.nvim` 會自動切成隧道模式
（偵測 `SSH_CONNECTION`，本機的 Neovim 不受影響）：預覽伺服器固定綁在遠端的
`127.0.0.1:8765`，不對外開放，並把預覽網址寫到遠端的 `~/.cache/mkdp-url`。

1. 在本機開隧道連上遠端（port 要和遠端一致）：

   ```sh
   ssh -L 8765:127.0.0.1:8765 <ssh-host>
   ```

2. 在遠端的 Neovim 裡對 Markdown 檔執行 `:MarkdownPreview`。
3. 在本機另一個終端執行 `mdp <ssh-host>`（`.zshrc` 提供的函式），它會經 ssh
   讀取網址並用預設瀏覽器開啟。常用的主機可以 `export MDP_HOST=<ssh-host>`，之後
   直接打 `mdp` 即可。

想換 port 的話，在遠端設定 `MKDP_PORT` 環境變數，並把步驟 1 的 `-L` 改成同一個數字。

# ssh 遠端的剪貼簿（OSC 52）

在 ssh 進去的遠端主機上用 Neovim 複製（`y`、`yy` 之類），內容會直接進到你面前這台
機器的系統剪貼簿。LazyVim 偵測到 `SSH_CONNECTION` 時會把 `clipboard` 清空，所以
`nvim/lua/config/options.lua` 把它改回 `unnamedplus`，並明確指定 Neovim 內建的
OSC 52 provider：複製的內容會以終端機跳脫序列送出，而不是卡死在遠端。tmux 之所以
轉得過去，是因為 `tmux.conf` 設了 `set -s set-clipboard on`（預設的 `external` 只
轉發 tmux 自己的複製動作，不會轉發 pane 裡的程式送出的 OSC 52），本機的 Ghostty 再
把它寫進系統剪貼簿。遠端 tmux copy mode 的複製（`v` 之後按 `y`）走的是同一條路，
一樣會回到本機剪貼簿。OSC 52 與終端機無關，不支援的終端機只會忽略這段序列，Neovim
內部的複製貼上照常運作。

貼上不走同一條路。遠端 Neovim 的 `p` 讀的是 Neovim 自己的 register，因為 OSC 52 的
「讀取」是刻意不用的：各家終端機對「讓程式讀我的剪貼簿」處理方式不一致（有的每次
詢問、有的直接拒絕、有的根本沒實作）。要把本機剪貼簿的內容貼到遠端，用終端機自己的
貼上快捷鍵即可（macOS 是 `Cmd + V`，Omarchy 是 `Super + V` 或 `Shift + Insert`）。

# 快捷鍵

只列自己客製化的部分。LazyVim / Ghostty / Tmux / Herdr 原生預設快捷鍵不重複列出。

## Hyprland / Omarchy

只在 Omarchy 機器上連結（`install.sh` 檢查 `/usr/share/omarchy` 或 `$OMARCHY_PATH`
是否存在，其他機器一律略過 `hypr/`）。Omarchy 預設的 `Super + 方向鍵` 保留不動，
這裡是在其上加一組 Vim 的 `h/j/k/l`。刻意不用 `Super + H/J/K/L`：Windows 會攔截
部分 Super 組合（`Win + L` 會鎖定 Windows），所以多加一層 `Shift`。

| Key | Action |
| --- | --- |
| `Super + Shift + H / J / K / L` | 焦點移到 左 / 下 / 上 / 右 的視窗 |
| `Super + Ctrl + Shift + H / J / K / L` | 把視窗往 左 / 下 / 上 / 右 交換 |

改完後用 `hyprctl reload && hyprctl configerrors` 套用並檢查。

## Ghostty

| Key | Action |
| --- | --- |
| `Cmd + C` / `Cmd + V` | 複製 / 貼上 |
| `Ctrl + Insert` | 複製到剪貼簿 |
| `Shift + Insert` | 從剪貼簿貼上 |
| `Cmd + ,` | 開啟設定檔 |
| `Cmd + Shift + ,` | 重新載入設定 |
| `Cmd + Shift + O` / `Ctrl + Alt + O` | 切換背景透明度 |

`Ctrl + Insert` / `Shift + Insert` 是為了 Omarchy：Hyprland 會攔下 `Super + C` /
`Super + V`，對終端機視窗改送這兩組按鍵，所以必須明確綁定（Ghostty 在 Linux 的預設
是把 `Shift + Insert` 綁到滑鼠反白的 primary selection，不是剪貼簿）。

`Ctrl + Alt + O` 是 `Cmd + Shift + O` 的 Linux 版：在 Omarchy 上
`Super + Shift + O` 是開 Obsidian，會先被 Hyprland 攔走，根本進不到終端機。

Ghostty 在 Linux 是單一 instance，改完設定檔要完全重啟才會套用新鍵位：關掉所有
Ghostty 視窗再重新開啟。

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
