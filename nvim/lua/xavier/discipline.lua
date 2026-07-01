-- 培養好習慣的小模組 / A small module to build good habits
local M = {}

-- cowboy()：連按 h/j/k/l 超過 10 次會跳出提醒，戒掉狂按方向鍵的壞習慣
-- cowboy(): nags after 10 repeated h/j/k/l presses to break the habit of spamming motions
function M.cowboy()
  ---@type table?
  local id -- 通知的 id，用來覆蓋前一則 / Notification id, used to replace the previous one
  local ok = true

  for _, key in ipairs({ "h", "j", "k", "l" }) do
    local count = 0 -- 這顆鍵目前連按次數 / Current consecutive press count for this key
    local timer = assert(vim.uv.new_timer())
    local map = key
    vim.keymap.set("n", key, function()
      -- 有帶數字前綴（如 5j）時不計數 / Don't count when a numeric prefix is used (e.g. 5j)
      if vim.v.count > 0 then
        count = 0
      end
      if count >= 10 then
        -- 超過門檻：跳出「Hold it Cowboy!」提醒 / Over the limit: pop the "Hold it Cowboy!" nag
        ok, id = pcall(vim.notify, "Hold it Cowboy!", vim.log.levels.WARN, {
          icon = "🐮",
          replace = id,
          keep = function()
            return count >= 10
          end,
        })
        -- 通知失敗時仍執行原本按鍵動作 / Still perform the original motion if notify fails
        if not ok then
          id = nil
          return map
        end
      else
        -- 未達門檻：計數 +1，並在 2 秒無按鍵後歸零
        -- Under the limit: increment count, reset it after 2s of inactivity
        count = count + 1
        timer:start(2000, 0, function()
          count = 0
        end)
        return map
      end
    end, { expr = true, silent = true })
  end
end
return M
