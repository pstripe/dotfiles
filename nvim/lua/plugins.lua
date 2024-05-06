local function bootstrap_mini_deps()
  -- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
  local path_package = vim.fn.stdpath('data') .. '/site/'
  local mini_path = path_package .. 'pack/deps/start/mini.nvim'
  if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
      'git', 'clone', '--filter=blob:none',
      'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
  end

  -- Set up 'mini.deps' (customize to your liking)
  require('mini.deps').setup({ path = { package = path_package } })
end

bootstrap_mini_deps()


local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Theme
now(function()
  add('sainnhe/sonokai')
  vim.cmd.colorscheme('sonokai')
end)

-- UI
now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify()
end)

now(function()
  add({
    source = 'folke/todo-comments.nvim',
    depends = { 'nvim-lua/plenary.nvim' }
  })
  require('todo-comments').setup()
end)

now(function()
  add({
    source = 'goolord/alpha-nvim',
    depends = { 'nvim-tree/nvim-web-devicons' },
  })
  require('alpha').setup(require('alpha.themes.startify').config)
end)


now(function()
  add('folke/which-key.nvim')

  vim.opt.timeout = true
  vim.opt.timeoutlen = 300
  require('which-key').setup()
end)

now(function()
  add({
    source = 'hoob3rt/lualine.nvim',
    depends = { 'kyazdani42/nvim-web-devicons' },
  })

  vim.opt.cmdheight = 2
  vim.opt.showmode = false

  require('lualine').setup({
    options = {
      theme = 'palenight',
    },
    sections = {
      lualine_a = { {
        'mode',
        fmt = function(str) return str:sub(1, 1) end
      } },
      lualine_b = { {
        'filename',
        path = 1,
      } },
      lualine_c = {},
    },
    tabline = {
      lualine_a = { 'branch', 'diff' },
      lualine_z = { 'tabs' },
    },
    extensions = {
      'fugitive',
      'nvim-tree',
      'quickfix',
    }
  })
end)


-- Git
now(function()
  add('lewis6991/gitsigns.nvim')
  require('gitsigns').setup({
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      vim.keymap.set('n', '<leader>gp', gs.preview_hunk)
      vim.keymap.set('n', '<leader>gb', function() gs.blame_line({full = true}) end, { buffer = bufnr })

      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr })
    end
  })
end)

now(function()
  add({
    source = 'sindrets/diffview.nvim',
    depends = { 'nvim-lua/plenary.nvim' }
  })
end)

now(function()
  add('tpope/vim-fugitive')
  vim.keymap.set('n', '<leader>gyb', "<cmd>call setreg('+', FugitiveHead())<CR><cmd>echo 'Git branch yanked!'<CR>", { noremap = true, silent = false })
end)

-- Tools
now(function()
  add('akinsho/toggleterm.nvim')
  require('toggleterm').setup({
    open_mapping = '<leader>t',
    insert_mappings = false,
    direction = 'float',
    persist_size = false,
    float_opts = {
      width = 150,
      height = 50,
    }
  })
end)

now(function()
  add({
    source = 'iamcco/markdown-preview.nvim',
    hooks = {
      post_install = function() vim.fn['mkdp#util#install']() end,
    }
  })
end)
now(function()
  add({
    source = 'luckasRanarison/nvim-devdocs',
    depends = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  })

  vim.keymap.set('n', '<leader>k', '<cmd>DevdocsOpenCurrentFloat')

  require('nvim-devdocs').setup({
    ensure_installed = {
      'fish-3.7',
      'go',
      'lua-5.4',
      'nushell',
      'php',
      'phpunit-9',
      'python-3.12',
      'rust',
    }
  })
end)
now(function()
  add({
    source = 'nvim-telescope/telescope.nvim',
    depends = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
    },
  })

  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>f',  builtin.find_files)
  vim.keymap.set('n', '<leader>/',  builtin.live_grep)
  vim.keymap.set('n', '<leader>b',  builtin.buffers)
  vim.keymap.set('n', '<leader>o',  builtin.commands)
  vim.keymap.set('n', '<leader>fw', builtin.grep_string)
  vim.keymap.set('n', '<leader>fs', builtin.treesitter)
  vim.keymap.set('n', '<leader>fl', builtin.current_buffer_fuzzy_find)
end)
now(function()
  add({
    source = 'nvim-telescope/telescope-file-browser.nvim',
    depends = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim'
    },
  })

  local telescope = require('telescope')
  telescope.load_extension('file_browser')

  vim.keymap.set('n', '<leader>n', function() telescope.extensions.file_browser.file_browser({ path = '%:p:h' }) end)
end)

now(function() add('chrisgrieser/nvim-spider') end)

now(function()
  add('folke/flash.nvim')

  vim.keymap.set({ 'n', 'o', 'x' }, 's', require('flash').jump)
  vim.keymap.set({ 'n', 'o', 'x' }, '<C-s>', require('flash').treesitter)
  vim.keymap.set({ 'o' },           'r', require('flash').remote)
  vim.keymap.set({ 'o', 'x' },      'R', require('flash').treesitter_search)
  vim.keymap.set({ 'c' },       '<C-s>', require('flash').toggle)
end)

-- LSP
now(function()
  add('neovim/nvim-lspconfig')

  local opts = { noremap = true }
  vim.keymap.set('n', '<leader>d',  vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,  opts)
  vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,  opts)

  local function on_attach(client, bufnr)
    local opts = { noremap = true, buffer = bufnr }
    -- Mappings.
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gR', vim.lsp.buf.references,  opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)

    vim.keymap.set('n', '<leader>D',  vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>k',  vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Set some keybinds conditional on server capabilities
    if client.server_capabilities.document_formatting then
      vim.keymap.set('n', '<leader>fmt', vim.lsp.buf.format({ async = true }), opts)
    elseif client.server_capabilities.document_range_formatting then
      vim.keymap.set('n', '<leader>fmt', vim.lsp.buf.range_formatting, opts)
    end
  end

  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  for _, server in pairs({ 'clangd', 'rust_analyzer', 'phpactor', 'gopls', 'pyright' }) do
    lspconfig[server].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
end)

now(function()
  add('j-hui/fidget.nvim')

  require('fidget').setup({})
end)

-- Snippets
now(function()
  add('L3MON4D3/LuaSnip')

  vim.keymap.set('i', '<C-s>', require('luasnip.extras.select_choice'))

  -- TODO: migrate
  require('snippets')
end)

-- Code
later(function()
  require('mini.pairs').setup()
end)

later(function()
  require('mini.surround').setup()
end)

now(function()
  add({
    source = 'hrsh7th/nvim-cmp',
    depends = {
      'ray-x/cmp-treesitter',
      'hrsh7th/cmp-nvim-lsp',
      'neovim/nvim-lspconfig',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'onsails/lspkind.nvim',
    },
  })

  vim.o.completeopt = 'menuone,noselect'
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  local lspkind = require('lspkind')

  vim.keymap.set('i', '<C-x><C-o>', cmp.complete)

  cmp.setup({
    completion = {
      autocomplete = false
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_next_item()
        else
          cmp.complete()
        end
      end, {'i','c'}),
      ['<C-p>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        else
          cmp.complete()
        end
      end, {'i','c'}),
      ['<CR>']  = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      { name = 'luasnip' },
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol_text',
        maxwidth = 60,
      })
    }
  })
end)

-- Treesitter
now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function() vim.cmd('TSUpdate') end
    }
  })

  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'bash',
      'fish',
      'gitcommit',
      'go',
      'html', -- For nvim-devdocs
      'json',
      'kdl',
      'lua',
      'markdown',
      'php',
      'phpdoc',
      'python',
      'query',
      'rust',
      'toml',
      'yaml',
    },
    sync_install = false,

    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
    },
  })
end)

now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter-refactor',
    depends = {
      'nvim-treesitter/nvim-treesitter'
    },
  })
  require('nvim-treesitter.configs').setup({
    refactor = {
      highlight_definitions = {
        enable = true,
        -- Set to false if you have an `updatetime` of ~100.
        clear_on_cursor_move = true,
      },
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = '<leader>r',
        },
      },
      -- TODO: add jumps over function usage
      navigation = {
        enable = true,
        keymaps = {
          goto_definition_lsp_fallback = 'gd',
          goto_next_usage = '<C-j>',
          goto_previous_usage = '<C-k>',
        },
      },
    },
  })
end)

now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    depends = {
      'nvim-treesitter/nvim-treesitter'
    },
  })
  require('nvim-treesitter.configs').setup({
    textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
      },
      lsp_interop = {
        enable = true,
        border = 'single',
        peek_definition_code = {
          ["<leader>lsf"] = "@function.outer",
          ["<leader>lsc"] = "@class.outer",
        },
      },
    },
  })
end)

now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter-context',
    depends = {
      'nvim-treesitter/nvim-treesitter'
    }
  })
end)

now(function()
  add({
    source = 'HiPhish/nvim-ts-rainbow2',
    depends = {
      'nvim-treesitter/nvim-treesitter'
    },
  })
  require('nvim-treesitter.configs').setup({
    rainbow = {
      enable = true
    }
  })
end)

now(function()
  add({
    source = 'nvim-treesitter/playground',
    depends = {
      'nvim-treesitter/nvim-treesitter'
    },
  })
  require('nvim-treesitter.configs').setup({
    playground = {
      enable = true
    }
  })
end)

now(function() add('nushell/tree-sitter-nu') end)
