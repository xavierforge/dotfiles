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
