-- 只在 ssh 遠端 session 套用：本機 nvim 維持 plugin 預設（隨機 port、直接開瀏覽器）。
-- Only applies inside an ssh session; local nvim keeps the plugin defaults (random port, open browser directly).
-- 本機的 127.0.0.1:<port> 是 ssh 隧道入口，本機 nvim 若也綁同一個 port 會 EADDRINUSE，故本機不走這段。
if not (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then
  return {}
end

-- port 可用環境變數 MKDP_PORT 覆寫（預設 8765），需與本機 `ssh -L <port>:127.0.0.1:<port>` 一致
local port = vim.env.MKDP_PORT or "8765"
local url_file = vim.fn.expand("~/.cache/mkdp-url")

return {
  "iamcco/markdown-preview.nvim",
  init = function()
    -- 固定 port，綁 127.0.0.1（不對外），透過 ssh 隧道在本機瀏覽器開啟
    vim.g.mkdp_port = port
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_combine_preview = 1
    vim.g.mkdp_auto_close = 0  -- 切換 buffer 時不關閉預覽分頁，配合 combine_preview 重用同一分頁
    vim.g.mkdp_browserfunc = "MkdpTunnelNotify"
    -- 網址是 /page/<bufnr>，每次不同；寫進 ~/.cache/mkdp-url 讓本機端的 `mdp` 指令（見 .zshrc）讀取後開啟
    vim.cmd([[
      function! MkdpTunnelNotify(url)
        let l:url = substitute(a:url, 'localhost', '127.0.0.1', '')
        call mkdir(expand('~/.cache'), 'p')
        call writefile([l:url], expand('~/.cache/mkdp-url'))
        echom 'markdown-preview: run `mdp <this-host>` on your local machine (or open ' . l:url . ' through the tunnel)'
      endfunction
    ]])
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function() os.remove(url_file) end,
    })
  end,
}
