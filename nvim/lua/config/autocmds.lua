-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- 讓背景透明（搭配 ghostty 的 background-opacity 產生毛玻璃效果）
-- Make the background transparent (pairs with ghostty's background-opacity for a frosted-glass look)
local function make_transparent()
  -- 需要清除背景色的 highlight 群組 / Highlight groups whose background we clear
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
  -- 把每個群組的背景設為 NONE / Set each group's background to NONE
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

-- 每次切換配色時重新套用透明背景 / Re-apply transparency whenever the colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", { callback = make_transparent })
-- autocmds.lua 在 VeryLazy 才載入，colorscheme 已經設好，補執行一次
-- autocmds.lua loads on VeryLazy after the colorscheme is set, so run it once now
make_transparent()
