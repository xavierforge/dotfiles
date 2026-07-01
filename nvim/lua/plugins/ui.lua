return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      opts.presets.lsp_doc_border = true
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 10000,
    },
  },
  {
    "folke/snacks.nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local assets_dir = vim.fn.stdpath("config") .. "/assets"
      local images = vim.fn.globpath(assets_dir, "*.{png,jpg,jpeg,gif,webp}", false, true)
      local can_render = vim.fn.executable("chafa") == 1 and #images > 0

      opts.dashboard.sections = {}
      if can_render then
        math.randomseed(os.time())
        local image = images[math.random(#images)]
        table.insert(opts.dashboard.sections, {
          section = "terminal",
          cmd = "chafa " .. vim.fn.shellescape(image) .. " --format symbols --size 80x10; sleep .1",
          height = 10,
          padding = 1,
          indent = 10,
        })
      else
        table.insert(opts.dashboard.sections, { section = "header" })
      end
      table.insert(opts.dashboard.sections, { section = "keys", gap = 1, padding = 1 })
      table.insert(opts.dashboard.sections, { section = "startup" })
    end,
  },
}
