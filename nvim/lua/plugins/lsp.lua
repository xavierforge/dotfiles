-- LSP / linter / 工具安裝相關設定 / LSP, linter and tool-install configuration
return {
  {
    -- mason.nvim：管理 LSP、linter、formatter 等外部工具
    -- mason.nvim: manages external tools like LSP servers, linters, formatters
    "mason-org/mason.nvim",
    opts = {
      -- 確保這些工具已安裝 / Make sure these tools are installed
      ensure_installed = {
        "mypy",
      },
      ui = {
        -- Mason 視窗的狀態圖示 / Status icons in the Mason window
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    -- nvim-lint：非 LSP 的額外 linter / nvim-lint: extra non-LSP linters
    "mfussenegger/nvim-lint",
    opts = {
      -- 依檔案類型指定 linter / Assign linters per filetype
      linters_by_ft = {
        python = { "mypy" },
      },
    },
  },
  {
    -- nvim-lspconfig：LSP 伺服器設定 / nvim-lspconfig: LSP server setup
    "neovim/nvim-lspconfig",
    opts = {
      -- 開啟 inlay hints（型別/參數提示）/ Enable inlay hints (types/params)
      inlay_hints = { enabled = true },
    },
  },
}
