-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- For conciseness

-- 載入並啟用「別狂按方向鍵」的提醒 / Load and enable the "don't spam motions" nag
local discipline = require("xavier.discipline")
discipline.cowboy()
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- 基本鍵位 / Basic keymaps
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- 視窗管理 / Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- 關閉緩衝區 / Close buffer
keymap.set("n", "<leader>X", "<Cmd>bd<CR>", { desc = "Close current buffer" })
keymap.set("n", "<leader>A", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close all but current buffer" })

-- 分頁列 / BufferLine
keymap.set("n", "<TAB>", "<Cmd>BufferLineCycleNext<CR>", opts)
keymap.set("n", "<S-TAB>", "<Cmd>BufferLineCyclePrev<CR>", opts)
keymap.set("n", "<C-p>", "<Cmd>BufferLinePick<CR>", opts)
