local wezterm = require('wezterm')

return {
  color_scheme = 'Afterglow',
  font = wezterm.font('FiraCode Nerd Font Mono', {
    italic = false,
  }),
  font_size = 10,
  scrollback_lines = 0,
  enable_scroll_bar = false,
  enable_tab_bar = false,
  window_decorations = 'RESIZE',
  window_padding = {
    left = 1,
    right = 1,
    top = 1,
    bottom = 0,
  }
}
