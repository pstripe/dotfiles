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
    { key = 'p', mods = 'ALT', action = act.ActivateKeyTable({ name = 'pane_spawn' }) }
  },
  key_tables = {
    pane_spawn = {
      { key = 'f', action = act.TogglePaneZoomState },
      { key = 'n', action = act.SplitHorizontal({domain="CurrentPaneDomain"}) },
    },
  },

  -- Fonts
  font_size = 12,
  font = wezterm.font {
    family = 'JetBrains Mono',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },

  -- Tabs
  tab_max_width = 64,
  use_fancy_tab_bar = false,
}
