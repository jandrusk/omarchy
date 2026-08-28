-- begin omarchy-matrix screensaver PATH
-- Prefer ~/.config/omarchy/bin over packaged omarchy-* tools so the
-- Matrix theme can ship a digital-rain screensaver without editing
-- /usr/share/omarchy.
do
  local home = os.getenv("HOME") or ""
  local user_bin = home .. "/.config/omarchy/bin"
  local path = os.getenv("PATH") or ""
  local filtered = {}
  for entry in (path .. ":"):gmatch("([^:]*):") do
    if entry ~= "" and entry ~= user_bin then
      filtered[#filtered + 1] = entry
    end
  end
  hl.env("PATH", user_bin .. ":" .. table.concat(filtered, ":"))
end
-- end omarchy-matrix screensaver PATH
