vim.cmd('syntax on')


vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = 'utf-8,cp1251,default'

vim.opt.title = true

-- Spaces & tabs
vim.opt.list = true
vim.opt.listchars = { tab = '► ', trail = '•' }
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- UI
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.scrolloff = 5
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.foldmethod = 'marker'
vim.opt.colorcolumn = "-30,+0"
vim.opt.cursorline = true
vim.opt.textwidth = 130

-- Backup
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = '/tmp/nvim/undo'
-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = 'nosplit'
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.history = 100

vim.opt.hidden = true

vim.opt.wrap = false
vim.opt.sidescroll = 5

-- Key bindings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
--
vim.keymap.set('', 'Q', '<nop>')
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })

-- Functions
function isempty(s)
  return s == nil or s == ''
end

function FnameRelToProjectRoot()
  local Path = require('plenary.path')

  local abs_fname = vim.fn.expand('%:p')
  local work_tree = vim.b.gitsigns_status_dict.root

  local rel_fname = Path:new(abs_fname)
  if not isempty(work_tree) then
    return rel_fname:make_relative(work_tree)
  end

  return rel_fname:absolute()
end

function Upload()
  local rel_fname = FnameRelToProjectRoot()
  local esc_fname = vim.fn.fnameescape(rel_fname)
  vim.api.nvim_command('Nwrite rsync://adm512:data/' .. esc_fname)
end

function Confdata()
  local word = vim.fn.expand("<cword>")

  local result = vim.fn.execute("!ssh -S none adm512 'cd www; php 00pnsmirnov.php confdata " .. word .. "'")
  local buf = vim.api.nvim_create_buf(false, true)

  result = vim.split(result, '\n')

  table.remove(result, 1)
  table.remove(result, 1)
  table.remove(result, 1)
  table.remove(result, 5)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, result)

  local opts = {
    relative = 'cursor',
    width = 30,
    height = 4,
    row = 0,
    col = 0,
    style = 'minimal',
    border = 'single',
  }

  vim.api.nvim_open_win(buf, 0, opts)
end

function IDE()
  local path = FnameRelToProjectRoot() .. ':' .. vim.fn.line('.');
  vim.fn.setreg('+', path)
  print('"' .. path .. '" yanked!')
end

vim.api.nvim_create_autocmd('TextYankPost', { pattern = '*', command = 'lua vim.highlight.on_yank({on_visual=false, timeout=150})' })
