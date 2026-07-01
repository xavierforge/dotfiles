-- 語法解析（Treesitter）設定 / Syntax parsing (Treesitter) configuration
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- 依語法結構逐步擴大/縮小選取範圍
      -- Grow/shrink the selection by syntax node
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "S", -- 開始選取 / Start selection
          node_incremental = "S", -- 擴大一個節點 / Expand by one node
          scope_incremental = false, -- 停用 scope 擴大 / Disable scope expansion
          node_decremental = "<bs>", -- 縮小一個節點 / Shrink by one node
        },
      },
    },
  },
}
