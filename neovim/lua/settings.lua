local go = vim.o;
local bo = vim.bo;
local wo = vim.wo;

vim.cmd('syntax on')


go.compatible = false
go.autoread = true

go.lazyredraw = true
go.encoding = 'UTF-8'
go.fileencodings = 'utf-8,cp1251,default'

go.title = true
go.ttyfast = true
go.redrawtime = 40000

-- Spaces & tabs
wo.list = true
go.listchars = 'tab:► ,trail:•'
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
go.undodir='/tmp/nvim/undo'
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

-- File
go.path = go.path .. 'www/**'

-- NetRW


-- Key bindings
vim.keymap.set('', 'Q', '<NOP>')
vim.keymap.set('', '<leader>y', '"+y')
vim.keymap.set('', '<leader>p', '"+p')

-- Functions
function isempty(s)
  return s == nil or s == ''
end

function FnameRelToProjectRoot()
  local Path = require('plenary.path')

  local abs_fname = vim.fn.expand('%:p')
  local work_tree = vim.fn.FugitiveWorkTree()

  local rel_fname = Path:new(abs_fname)
  if not isempty(work_tree) then
    return rel_fname:make_relative(work_tree)
  end

  return rel_fname:absolute()
end

function IDE()
  local path = FnameRelToProjectRoot() .. ':' .. vim.fn.line('.');
  vim.fn.setreg('+', path)
  print('"' .. path .. '" yanked!')
end

vim.api.nvim_create_autocmd('BufWrite', { pattern = '*.php', command = '%s/\\s\\+$//e' })
vim.api.nvim_create_autocmd('TextYankPost', { pattern = '*', command = 'lua vim.highlight.on_yank({on_visual=false, timeout=150})' })
