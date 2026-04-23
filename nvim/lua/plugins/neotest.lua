return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
      },
    },
    -- 測試跳轉快捷鍵（]n/[n 下一個/上一個；大寫 N 版本只跳「失敗的」測試）
    keys = {
      {
        "]n",
        function() require("neotest").jump.next() end,
        desc = "Next Test",
      },
      {
        "[n",
        function() require("neotest").jump.prev() end,
        desc = "Prev Test",
      },
      {
        "]N",
        function() require("neotest").jump.next({ status = "failed" }) end,
        desc = "Next Failed Test",
      },
      {
        "[N",
        function() require("neotest").jump.prev({ status = "failed" }) end,
        desc = "Prev Failed Test",
      },
    },
  },
}
