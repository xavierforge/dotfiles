-- 編輯器行為相關外掛 / Editor-behaviour plugins
return {
  -- 停用 flash.nvim 的跳躍功能 / Disable the flash.nvim jump feature
  { "folke/flash.nvim", enabled = false },
  -- 用 Ctrl+hjkl 無縫切換 vim 視窗與 tmux 窗格
  -- Seamlessly move between vim splits and tmux panes with Ctrl+hjkl
  { "christoomey/vim-tmux-navigator", event = { "BufReadPre" } },
  {
    -- 讓 neo-tree 預設就顯示隱藏檔（等同一開啟就按了 H）
    -- Make neo-tree show hidden files by default (as if you'd pressed H)
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- 顯示被過濾的項目（點檔、gitignore 檔）/ Show filtered items (dotfiles, gitignored)
        },
      },
    },
  },
}
