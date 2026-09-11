-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- 縮排設定 / Indent settings
opt.tabstop = 4 -- 一個 Tab 顯示為幾格 / How many columns a Tab shows as
opt.softtabstop = 4 -- 編輯時 Tab/退格對應的空白數 / Spaces a Tab/Backspace edits
opt.shiftwidth = 4 -- 自動縮排每一層的寬度 / Width of each auto-indent level
opt.backspace = "indent,eol,start" -- 讓退格鍵可跨越縮排/行首 / Let Backspace cross indent/eol/start

-- 在第 80 字元處畫一條參考線 / Draw a ruler at column 80
opt.colorcolumn = "80"

-- tmux 3.7 會延後 (defer) 同步輸出 (DECSET 2026) 的畫面更新，導致在 tmux 內
-- 打字後畫面不重繪、要切 pane 才顯示。只在 tmux 環境關掉 termsync 即可修正；
-- 素的 Ghostty 保留 termsync 以獲得更順的重繪。
-- tmux 3.7 defers synchronized-output (DECSET 2026) redraws, so edits don't repaint
-- until you switch panes. Disable termsync only inside tmux to fix it.
if vim.env.TMUX ~= nil then
  opt.termsync = false
end

-- 使用新版 ruff（設成 "ruff_lsp" 會用舊版實作）
-- Use the new ruff (set to "ruff_lsp" for the old LSP implementation)
vim.g.lazyvim_python_ruff = "ruff"

-- SSH 遠端的剪貼簿：LazyVim 在有 SSH_CONNECTION 時會把 clipboard 設成空，
-- 所以 y 只進 nvim 自己的 register，永遠到不了本機。這裡改成 unnamedplus 並明確
-- 指定 OSC 52 provider（Neovim 0.10+ 內建），讓 y 透過終端機把文字送回本機剪貼簿。
-- OSC 52 是終端機無關的標準，多數現代終端機都支援；不支援的會直接忽略，不影響
-- nvim 內部的 yank/paste。paste 刻意不用 OSC 52 讀取，因為各終端機對「程式讀取
-- 剪貼簿」的處理不一致（有的每次詢問、有的預設拒絕、有的不支援），p 改讀 nvim
-- 內部最後一次 yank 的內容；要貼本機剪貼簿的東西用終端機自己的貼上快捷鍵即可。
-- Clipboard over SSH: LazyVim clears 'clipboard' when SSH_CONNECTION is set, so
-- y never leaves nvim. Force unnamedplus + the built-in OSC 52 provider so yanks
-- reach the local clipboard through the terminal. OSC 52 is terminal-agnostic
-- and widely supported; terminals without it ignore the sequence and in-editor
-- yank/paste keeps working. Paste deliberately avoids the OSC 52 read because
-- terminals handle clipboard reads inconsistently (prompt, deny, or unsupported);
-- p falls back to nvim's own register and the terminal's paste shortcut handles
-- pasting from the local clipboard.
if vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52 (ssh)",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
  opt.clipboard = "unnamedplus"
end
