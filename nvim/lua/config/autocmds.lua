-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- 讓背景透明（搭配 ghostty 的 background-opacity 產生毛玻璃效果）
local function make_transparent()
  local groups = {
    "Normal",
    "NormalNC",
    "LineNr",
    "Folded",
    "NonText",
    "SpecialKey",
    "VertSplit",
    "SignColumn",
    "EndOfBuffer",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = make_transparent })
-- autocmds.lua 在 VeryLazy 才載入，colorscheme 已經設好，補執行一次
make_transparent()
