-- 編輯器行為相關外掛 / Editor-behaviour plugins
return {
  -- 停用 flash.nvim 的跳躍功能 / Disable the flash.nvim jump feature
  { "folke/flash.nvim", enabled = false },
  -- 用 Ctrl+hjkl 無縫切換 vim 視窗與 tmux 窗格
  -- Seamlessly move between vim splits and tmux panes with Ctrl+hjkl
  { "christoomey/vim-tmux-navigator", event = { "BufReadPre" } },
}
