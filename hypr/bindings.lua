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

-- 顯示目前 focus 在哪個螢幕。通知會跳在 focus 的那個螢幕上，所以「通知出現在哪」
-- 本身就是答案；內文再附上螢幕名稱與 workspace。
-- Show which monitor has focus. The notification pops up on the focused
-- monitor, so where it appears is the answer; the text adds the output name
-- and workspace.
o.bind(
  "SUPER + BACKSLASH",
  "Show focused monitor",
  [[omarchy-notification-send --transient -t 2000 -u low "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | "Focus: \(.name)  (workspace \(.activeWorkspace.name))"')"]]
)

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
