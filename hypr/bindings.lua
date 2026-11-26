-- Omarchy (Hyprland) 個人快捷鍵覆寫。只有偵測到 Omarchy 時 install.sh 才會連結
-- 這個檔案到 ~/.config/hypr/bindings.lua；其他機器一律略過。
-- Personal Omarchy (Hyprland) keybinding overrides. install.sh links this file
-- to ~/.config/hypr/bindings.lua only when Omarchy is detected; every other
-- machine skips it.
--
-- 查看目前所有綁定 / list every current binding:
--   omarchy menu keybindings --print
-- 改完套用並檢查 / apply and validate after editing:
--   hyprctl reload && hyprctl configerrors

-- Vim 的 h/j/k/l 對應 左/下/上/右。不直接用 SUPER + H/J/K/L：Windows 會攔截
-- 部分 Super 組合（尤其 Win + L 會鎖定 Windows），所以多加一層 SHIFT。
-- Omarchy 預設的方向鍵綁定（SUPER + 方向鍵）保留不動。
-- Vim's h/j/k/l map to left/down/up/right. Plain SUPER + H/J/K/L is avoided
-- because Windows intercepts some Super combos (Win + L locks Windows), so
-- SHIFT is added on top. Omarchy's default arrow-key bindings stay untouched.

-- Vim-style window focus
o.bind("SUPER + SHIFT + H", "Focus window left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Focus window down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Focus window up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Focus window right", hl.dsp.focus({ direction = "r" }))

-- Vim-style window swapping
o.bind("SUPER + CTRL + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + CTRL + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + CTRL + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

-- Ctrl+Space 交給 fcitx5 當中英切換鍵（見 ~/.config/fcitx5/config）。Omarchy 預設在
-- 終端機裡把 Ctrl+Space 當成「切回英文、讓 tmux 收到 prefix」，會跟切換互搶，所以移除。
-- herdr 的 prefix 是 Ctrl+S，不受影響。
-- Ctrl+Space is fcitx5's input-method toggle (see ~/.config/fcitx5/config).
-- Omarchy's default forces direct input in terminals for a tmux prefix, which
-- fights the toggle, so drop it. herdr uses Ctrl+S as its prefix.
hl.unbind("CTRL + SPACE")

-- 顯示目前 focus 在哪：focus 的視窗邊框加粗閃一下，同時在 focus 的螢幕跳出 OSD
-- （螢幕名稱與 workspace）。不用通知：通知那疊會留在第一則出現的螢幕直到清空，
-- 所以換螢幕後再按，通知還是跳在舊螢幕。OSD 每次開啟都重新選 focus 的螢幕，
-- 先 close 是為了讓還沒消失的上一個 OSD 也重選。
-- Show where focus is: pulse the focused window's border and pop an OSD (output
-- name and workspace) on the focused monitor. Notifications are no good here:
-- the stack stays on the monitor of its first toast until it empties, so a
-- press after switching monitors still landed on the old one. The OSD picks
-- the focused monitor on every open; closing first makes a still-visible OSD
-- pick again too.
local function show_focus()
  local monitor = hl.get_active_monitor()
  local workspace = hl.get_active_workspace()
  if monitor then
    local message = "Focus: " .. monitor.name .. (workspace and ("  ·  workspace " .. workspace.name) or "")
    hl.exec_cmd("omarchy-shell -q osd close; omarchy-osd -d 1500 -m '" .. message .. "'")
  end

  local window = hl.get_active_window()
  if window then
    local target = "address:" .. window.address
    hl.dispatch(hl.dsp.window.set_prop({ window = target, prop = "border_size", value = "8" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.window.set_prop({ window = target, prop = "border_size", value = "unset" }))
    end, { timeout = 700, type = "oneshot" })
  end
end

o.bind("SUPER + BACKSLASH", "Show focused monitor and window", show_focus)

-- 切換螢幕 focus：SUPER + [ / ]，和上面的 SUPER + \ 三顆相鄰。Omarchy 預設的
-- CTRL + ALT + (SHIFT +) TAB 保留不動。
-- Monitor focus on SUPER + [ / ], next to SUPER + \ above. Omarchy's default
-- CTRL + ALT + (SHIFT +) TAB stays untouched.
o.bind("SUPER + BRACKETLEFT", "Focus on previous monitor", hl.dsp.focus({ monitor = "-1" }))
o.bind("SUPER + BRACKETRIGHT", "Focus on next monitor", hl.dsp.focus({ monitor = "+1" }))

-- 把視窗搬到另一個螢幕：同一組 [ / ] 再加 SHIFT（focus 不加、搬動加 SHIFT）。
-- Omarchy 預設的 SUPER + SHIFT + CTRL + 方向鍵保留不動。
-- Move the window to another monitor: the same [ / ] keys plus SHIFT (plain to
-- focus, SHIFT to move). Omarchy's default SUPER + SHIFT + CTRL + arrows stay.
o.bind("SUPER + SHIFT + BRACKETLEFT", "Move window to previous monitor", o.workspaces.move_window_to_monitor("-1"))
o.bind("SUPER + SHIFT + BRACKETRIGHT", "Move window to next monitor", o.workspaces.move_window_to_monitor("+1"))

-- 螢幕縮放快捷鍵太容易誤觸（一按就從 2x 跳到 4x），移除；縮放改從 Display 面板
-- （SUPER + CTRL + D）調整。按鍵名稱跟著鍵盤配置走，所以沿用 Omarchy 的 keyboard.key。
-- The monitor scaling keys are too easy to hit by accident, so drop them;
-- scaling stays available in the Display panel (SUPER + CTRL + D). The key
-- name follows the keyboard layout, hence Omarchy's keyboard.key.
local slash = require("default.hypr.keyboard").key("SLASH")
hl.unbind("SUPER + " .. slash)
hl.unbind("SUPER + ALT + " .. slash)

-- 用鍵盤捲動（捲動模式）：SUPER + ' 進入，之後不用按修飾鍵，j / k 捲一格、
-- d / u 捲半頁、h / l 左右捲，按住會連續捲；Esc、q 或再按一次 SUPER + ' 離開。
-- 做成模式而不是「按住 SUPER + 某鍵」，是因為 SUPER 還按著時送出的滾輪事件會被
-- Omarchy 的「SUPER + 滾輪切換 workspace」攔走。捲的是游標底下的視窗。
-- 需要 ydotool 與它的 daemon（ydotool.service，帳號要在 input 群組）。
-- Keyboard scrolling as a mode: SUPER + ' enters it, then with no modifier
-- j / k scroll a notch, d / u half a page, h / l sideways, and holding
-- repeats; Esc, q, or SUPER + ' again leaves. It is a mode rather than
-- "hold SUPER + key" because wheel events sent while SUPER is down get
-- swallowed by Omarchy's "SUPER + wheel switches workspace". The window under
-- the cursor is what scrolls. Needs ydotool and its daemon (ydotool.service,
-- with the user in the input group).
local function wheel(x, y)
  return "ydotool mousemove -w -x " .. x .. " -y " .. y
end

local function scroll_mode(on)
  return function()
    hl.dispatch(hl.dsp.submap(on and "scroll" or "reset"))
    local message = on and "Scroll mode:  j/k  d/u  h/l   (Esc to exit)" or "Scroll mode off"
    hl.exec_cmd("omarchy-shell -q osd close; omarchy-osd -d " .. (on and 2500 or 800) .. " -m '" .. message .. "'")
  end
end

o.bind("SUPER + APOSTROPHE", "Scroll mode", scroll_mode(true))

hl.define_submap("scroll", function()
  o.bind("J", "Scroll down", wheel(0, -1), { repeating = true })
  o.bind("K", "Scroll up", wheel(0, 1), { repeating = true })
  o.bind("D", "Scroll down half a page", wheel(0, -6), { repeating = true })
  o.bind("U", "Scroll up half a page", wheel(0, 6), { repeating = true })
  o.bind("H", "Scroll left", wheel(-1, 0), { repeating = true })
  o.bind("L", "Scroll right", wheel(1, 0), { repeating = true })
  o.bind("ESCAPE", "Leave scroll mode", scroll_mode(false))
  o.bind("Q", "Leave scroll mode", scroll_mode(false))
  o.bind("SUPER + APOSTROPHE", "Leave scroll mode", scroll_mode(false))
end)
