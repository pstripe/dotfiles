local go = vim.o;
local bo = vim.bo;
local wo = vim.wo;

vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')


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
go.scrolloff = 7
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

-- Indent
bo.autoindent = true
bo.smartindent = true

go.history = 100

go.hidden = true

wo.wrap = false
go.sidescroll = 5


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
  print(FnameRelToProjectRoot() .. ':' .. vim.fn.line('.'))
end

vim.cmd([[autocmd BufWrite *.php %s/\s\+$//e]])
