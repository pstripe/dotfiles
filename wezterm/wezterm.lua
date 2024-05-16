local wezterm = require('wezterm')
local act     = wezterm.action

return {
  -- Appearance
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  native_macos_fullscreen_mode = true,

  -- Theme
  color_scheme = 'Afterglow',

  -- Key Bindings
  keys = {
    { key = 'h', mods = 'ALT', action = act.ActivateTabRelative(-1) },
    { key = 'l', mods = 'ALT', action = act.ActivateTabRelative(1) },
    { key = 'h', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection('Left') },
    { key = 'j', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection('Up') },
    { key = 'l', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection('Right') },
    { key = 'w', mods = 'ALT', action = act.ActivateKeyTable({ name = 'pane_spawn' }) },
  },
  key_tables = {
    pane_spawn = {
      { key = 'f', action = act.TogglePaneZoomState },
      { key = 'v', action = act.SplitHorizontal({domain="CurrentPaneDomain"}) },
      { key = 's', action = act.SplitVertical({domain="CurrentPaneDomain"}) },
    },
  },

  -- Fonts
  font_size = 12,

  -- Tabs
  tab_max_width = 64,
  use_fancy_tab_bar = false,
}
