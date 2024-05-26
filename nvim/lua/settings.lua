local go = vim.o;
local bo = vim.bo;
local wo = vim.wo;

vim.cmd('syntax on')


go.compatible = false
go.autoread = true

go.lazyredraw = true
go.encoding = 'utf-8'
go.fileencodings = 'utf-8,cp1251,default'

go.title = true
go.ttyfast = true
go.redrawtime = 40000

-- Spaces & tabs
wo.list = true
vim.opt.listchars = { tab = '► ', trail = '•' }
go.expandtab = true
go.softtabstop = 2
go.shiftwidth = 2
go.tabstop = 2

-- UI
go.termguicolors = true
go.laststatus = 2
go.scrolloff = 3
go.splitright = true
go.splitbelow = true
wo.number = true
wo.relativenumber = true
go.showcmd = true
wo.foldmethod = 'marker'
wo.colorcolumn = "-20,+0"
wo.cursorline = true
bo.textwidth = 100

-- Backup
go.backup = false
go.writebackup = false
bo.swapfile = false
bo.undofile = true
go.undodir = '/tmp/nvim/undo'
-- Search
go.hlsearch = true
go.incsearch = true
go.inccommand = 'nosplit'
go.ignorecase = true
go.smartcase = true

go.history = 100

go.hidden = true

wo.wrap = false
go.sidescroll = 5

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
