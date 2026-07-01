return {
  {
    "saecki/crates.nvim",
    opts = function(_, opts)
      opts["popup"] = {
        autofocus = true,
        hide_on_select = true,
      }

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
