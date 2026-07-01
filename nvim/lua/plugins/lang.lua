-- 語言專屬外掛設定 / Language-specific plugin configuration
return {
  {
    -- crates.nvim：在 Cargo.toml 內管理 Rust 套件版本
    -- crates.nvim: manage Rust crate versions inside Cargo.toml
    "saecki/crates.nvim",
    opts = function(_, opts)
      -- 彈出視窗行為：自動聚焦、選取後自動關閉
      -- Popup behaviour: auto-focus and hide after selecting
      opts["popup"] = {
        autofocus = true,
        hide_on_select = true,
      }

      -- crates.nvim 的快捷鍵（皆為 <leader>c 開頭）
      -- crates.nvim keymaps (all prefixed with <leader>c)
      local keymap = vim.keymap
      local keymap_opts = { silent = true }
      keymap_opts.desc = "Show crate features popup"
      keymap.set("n", "<leader>cf", "<CMD>Crates show_features_popup<CR>", keymap_opts)
      keymap_opts.desc = "Show crate dependencies popup"
      keymap.set("n", "<leader>cd", "<CMD>Crates show_dependencies_popup<CR>", keymap_opts)
      keymap_opts.desc = "Open crate homepage"
      keymap.set("n", "<leader>cH", "<CMD>Crates open_homepage<CR>", keymap_opts)
      keymap_opts.desc = "Open crate repository"
      keymap.set("n", "<leader>cG", "<CMD>Crates open_repository<CR>", keymap_opts)
      keymap_opts.desc = "Open crate documentation"
      keymap.set("n", "<leader>cD", "<CMD>Crates open_documentation<CR>", keymap_opts)
      keymap_opts.desc = "Open crates.io"
      keymap.set("n", "<leader>cC", "<CMD>Crates open_cratesio<CR>", keymap_opts)
    end,
  },
}
