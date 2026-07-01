-- 測試框架設定 / Test framework configuration
return {
  {
    -- neotest：在編輯器內執行與檢視測試 / neotest: run and view tests in the editor
    "nvim-neotest/neotest",
    dependencies = {
      -- Vitest 的 adapter / Adapter for Vitest
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
      },
    },
    -- 測試跳轉快捷鍵（]n/[n 下一個/上一個；大寫 N 版本只跳「失敗的」測試）
    -- Test-jump keymaps (]n/[n for next/prev; uppercase N only jumps "failed" tests)
    keys = {
      {
        "]n",
        function()
          require("neotest").jump.next()
        end,
        desc = "Next Test",
      },
      {
        "[n",
        function()
          require("neotest").jump.prev()
        end,
        desc = "Prev Test",
      },
      {
        "]N",
        function()
          require("neotest").jump.next({ status = "failed" })
        end,
        desc = "Next Failed Test",
      },
      {
        "[N",
        function()
          require("neotest").jump.prev({ status = "failed" })
        end,
        desc = "Prev Failed Test",
      },
    },
  },
}
