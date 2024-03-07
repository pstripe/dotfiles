function toggle_layout()
  print(vim.bo.keymap)
  if vim.bo.keymap == 'russian-jcukenwin' then
    vim.bo.keymap = ''
  else
    vim.bo.keymap = 'russian-jcukenwin'
  end
end

vim.keymap.set({'n', 'i'}, 'C-^', toggle_layout)
-- add cool markdown mappings
