-- Quit the Night City screensaver on any real input.
-- Arm after a short delay so the cursor-hide / map doesn't wake it immediately.

local armed = false

local function cleanup()
  os.execute("hyprctl eval 'hl.config({ cursor = { invisible = false } })' >/dev/null 2>&1")
  os.execute("hyprctl keyword cursor:invisible false >/dev/null 2>&1")
  os.execute("pkill -f '[o]rg.omarchy.screensaver' >/dev/null 2>&1")
end

local function quit()
  if not armed then
    return
  end
  cleanup()
  mp.command("quit")
end

mp.add_timeout(0.7, function()
  armed = true
end)

mp.register_event("shutdown", function()
  os.execute("hyprctl eval 'hl.config({ cursor = { invisible = false } })' >/dev/null 2>&1")
  os.execute("hyprctl keyword cursor:invisible false >/dev/null 2>&1")
end)

local keys = {
  "any_unicode",
  "space",
  "enter",
  "esc",
  "tab",
  "bs",
  "left",
  "right",
  "up",
  "down",
  "pgup",
  "pgdwn",
  "home",
  "end",
  "mouse_btn0",
  "mouse_btn1",
  "mouse_btn2",
  "mouse_btn3",
  "wheeldn",
  "wheelup",
  "wheelleft",
  "wheelright",
  "mouse_move",
}

for i, key in ipairs(keys) do
  mp.add_forced_key_binding(key, "cyberpunk-ss-quit-" .. i, quit)
end
