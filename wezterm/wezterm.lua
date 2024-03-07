local wezterm = require('wezterm')
local act = wezterm.action

return {
  color_scheme = 'Afterglow',
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  keys = {
    { key = 'h', mods = 'ALT', action = act.ActivateTabRelative(-1) },
    { key = 'l', mods = 'ALT', action = act.ActivateTabRelative(1) },
  }
}
