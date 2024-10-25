if status is-interactive
  # Cursor shape for Vi mode
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_visual block
  set fish_cursor_replace_one underscore

  # Force Vi cursor, because it not changes in WezTerm
  set fish_vi_force_cursor

  set __fish_ls_command eza
end
