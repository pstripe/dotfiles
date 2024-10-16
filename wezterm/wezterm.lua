local wezterm = require('wezterm')
local act     = wezterm.action

local config = {
  -- Appearance
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  -- Theme
  color_scheme = 'Rosé Pine Moon (base16)',

  colors = {
    tab_bar = {
      background = '#232136',
      active_tab = {
        bg_color = '#393552',
        fg_color = '#e0def4',
      },
      inactive_tab = {
        bg_color = '#232136',
        fg_color = '#8f8ba9',
      },
      inactive_tab_hover = {
        bg_color = '#393552',
        fg_color = '#8f8ba9',
        italic = true,
      },
      new_tab = {
        bg_color = '#232136',
        fg_color = '#8f8ba9',
      },
      new_tab_hover = {
        bg_color = '#393552',
        fg_color = '#8f8ba9',
        italic = true,
      },
    },
  },

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

  font = wezterm.font('Cascadia Code NF', {
    weight = 'DemiLight'
  }),

  -- Fonts
  font_size = 13,

  -- Tabs
  tab_max_width = 64,
  use_fancy_tab_bar = false,
}

return config
