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
