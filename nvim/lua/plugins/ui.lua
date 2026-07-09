-- UI 相關外掛設定 / UI-related plugin configuration
return {
  {
    -- noice.nvim：改善命令列、訊息與彈出視窗的 UI
    -- noice.nvim: revamps the cmdline, messages and popup UI
    "folke/noice.nvim",
    opts = function(_, opts)
      -- 過濾掉 LSP「No information available」的雜訊通知
      -- Filter out the noisy LSP "No information available" notification
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      -- 幫 LSP hover 文件加上邊框 / Add a border to LSP hover docs
      opts.presets.lsp_doc_border = true
    end,
  },
  {
    -- nvim-notify：通知彈窗 / nvim-notify: notification popups
    "rcarriga/nvim-notify",
    opts = {
      -- 通知停留時間（毫秒）/ How long a notification stays (ms)
      timeout = 10000,
    },
  },
  {
    -- snacks.nvim：提供啟動畫面 dashboard 等小工具
    -- snacks.nvim: utilities including the startup dashboard
    "folke/snacks.nvim",
    event = "VimEnter",
    opts = function(_, opts)
      -- assets 圖片資料夾（依平台解析 nvim config 路徑）
      -- The assets image folder (resolves the nvim config path per platform)
      local assets_dir = vim.fn.stdpath("config") .. "/assets"
      -- 收集所有支援的圖片檔 / Collect every supported image file
      local images = vim.fn.globpath(assets_dir, "*.{png,jpg,jpeg,gif,webp}", false, true)
      -- 只有裝了 chafa 且至少有一張圖時才渲染圖片
      -- Only render an image when chafa exists and there is at least one image
      local can_render = vim.fn.executable("chafa") == 1 and #images > 0

      opts.dashboard.sections = {}
      if can_render then
        -- 每次啟動隨機挑一張圖 / Pick a random image on each startup
        math.randomseed(os.time())
        local image = images[math.random(#images)]
        table.insert(opts.dashboard.sections, {
          -- 用 chafa 把圖片轉成終端機符號顯示
          -- Use chafa to render the image as terminal symbols
          section = "terminal",
          cmd = "chafa " .. vim.fn.shellescape(image) .. " --format symbols --size 80x10; sleep .1",
          height = 10,
          padding = 1,
          indent = 10,
        })
      else
        -- 沒 chafa 或沒圖時退回預設文字 header
        -- Fall back to the default text header when chafa or images are missing
        table.insert(opts.dashboard.sections, { section = "header" })
      end
      -- 常用動作按鍵區塊 / The keybinding shortcuts block
      table.insert(opts.dashboard.sections, { section = "keys", gap = 1, padding = 1 })
      -- 顯示啟動耗時 / Show startup time
      table.insert(opts.dashboard.sections, { section = "startup" })

      -- 開啟 neo-tree 時關掉 dashboard，避免固定寬度的圖片浮動視窗蓋住側邊欄
      -- Close the dashboard when neo-tree opens, so its fixed-width floating
      -- image window doesn't overlap the sidebar in a narrow window
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          -- 延後到下一個 tick：此時 neo-tree 的 filetype 才剛設定，split 還沒建好，
          -- 這時畫面上可能只有 dashboard 那一個視窗，直接刪 buffer 會撞到 E444
          -- Defer to the next tick: neo-tree has only just set its filetype here,
          -- the split doesn't exist yet, so the dashboard window may still be the
          -- only window — deleting its buffer now would hit E444 (last window)
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.b[buf].snacks_main then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end)
        end,
      })
    end,
  },
}
