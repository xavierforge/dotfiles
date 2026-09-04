return {
  "iamcco/markdown-preview.nvim",
  init = function()
    -- 固定 port，綁 127.0.0.1（不對外），透過 ssh -L 8765:127.0.0.1:8765 在 mac 瀏覽器開啟
    vim.g.mkdp_port = "8765"
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_combine_preview = 1
    vim.g.mkdp_auto_close = 0  -- 切換 buffer 時不關閉預覽分頁，配合 combine_preview 重用同一分頁
    vim.g.mkdp_browserfunc = "MkdpTunnelNotify"
    vim.cmd([[
      function! MkdpTunnelNotify(url)
        echom 'markdown-preview: open on mac -> ' . a:url
      endfunction
    ]])
  end,
}
