-- Bootstrap
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  local execute = vim.api.nvim_command
  vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd.packadd('packer.nvim')
  requre('packer').sync()
end

-- Only required if you have packer in your `opt` pack
vim.cmd.packadd('packer.nvim')

-- Auto update plugins' list
vim.api.nvim_create_autocmd('BufWritePost', { pattern = 'plugins.lua', command = 'PackerCompile' })
return require('packer').startup(function()
  -- Packer can manage itself as an optional plugin
  use { 'wbthomason/packer.nvim', opt = true }

  -- Theme
  use {
    disable = true,
    'bluz71/vim-moonfly-colors',
    config = function()
      vim.cmd.colorscheme('moonfly')
      vim.cmd.highlight({ 'Comment', 'cterm=italic' })
      vim.cmd.highlight({ 'Whitespace', 'guifg=LightGray' })
    end
  }
  use {
    'sainnhe/sonokai',
    config = function()
      vim.cmd.colorscheme('sonokai')
    end
  }
  use {
    disable = true,
    'catppuccin/nvim',
    as = 'catppuccin',
    config = function()
      vim.cmd.colorscheme('catppuccin-latte')
    end
  }
  -- UI
  use {
    'folke/todo-comments.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('todo-comments').setup()
    end
  }
  use {
    'goolord/alpha-nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      require('alpha').setup(require('alpha.themes.startify').config)
    end
  }
  use {
    'folke/which-key.nvim',
    config = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 300
      require('which-key').setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end
  }
  use {
    'hoob3rt/lualine.nvim',
    requires = {
      { 'kyazdani42/nvim-web-devicons' },
    },
    config = function()
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
    end
  }


  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
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
    end
  }
  use {
    'sindrets/diffview.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  use {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gyb', "<cmd>call setreg('+', FugitiveHead())<CR><cmd>echo 'Git branch yanked!'<CR>", { noremap = true, silent = false })
    end
  }

  -- Tools
  use {
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
    },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>f',  builtin.find_files)
      vim.keymap.set('n', '<leader>/',  builtin.live_grep)
      vim.keymap.set('n', '<leader>b',  builtin.buffers)
      vim.keymap.set('n', '<leader>fw', builtin.grep_string)
      vim.keymap.set('n', '<leader>fs', builtin.treesitter)
      vim.keymap.set('n', '<leader>fl', builtin.current_buffer_fuzzy_find)
    end
  }
  use {
    'nvim-telescope/telescope-file-browser.nvim',
    requires = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local telescope = require('telescope')
      telescope.load_extension('file_browser')

      vim.keymap.set('n', '<leader>n', function() telescope.extensions.file_browser.file_browser({ path = '%:p:h' }) end)
    end
  }

  use { 'chrisgrieser/nvim-spider' }

  --use {
  --  'ggandor/leap.nvim',
  --  disable = true,
  --  config = require('leap').set_default_keymaps
  --}

  -- Debugger
  use {
    'rcarriga/nvim-dap-ui',
    disable = true,
    requires = {
      'mfussenegger/nvim-dap'
    },
    run = {
      -- FIXME: what if already cloned?
      -- 'git clone https://github.com/xdebug/vscode-php-debug.git',
      -- 'cd vscode-php-debug && npm install && npm run build'
    },
    ft = 'php',
    config = function()
      local dapui = require('dapui')
      dapui.setup({
        layout = {
          {
            elements = {
              "scopes",
              "stacks",
            },
            size = 40,
            position = "left" -- Can be "left" or "right"
          },
          {
            elements = {
              "breakpoints",
              "watches"
            },
            size = 10,
            position = "bottom",
          },
        },
      })
      vim.keymap.set('n', '<leader>dd', dapui.toggle)
      vim.keymap.set('v', '<leader>de', dapui.eval)


      local dap = require('dap')
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

      dap.adapters.php = {
        type = 'executable',
        command = 'node',
        args = { '/Users/pn.smirnov/vscode-php-debug/out/phpDebug.js' }
      }

      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug',
          hostname = '0.0.0.0',
          port = 9000,
          stopOnEntry = false,
          log = true,
          serverSourceRoot = '/var/kphp/pnsmirnov/data',
          localSourceRoot = '/Users/pn.smirnov/data',
          xdebugSettings = {
            max_children = 512,
            max_depth = 5
          }
        }
      }

      vim.keymap.set('n', '<leader>dc', dap.continue)
      vim.keymap.set('n', '<leader>ds', dap.toggle_breakpoint)
      vim.keymap.set('n', '<leader>dn', dap.step_over)
      vim.keymap.set('n', '<leader>d[', dap.step_into)
      vim.keymap.set('n', '<leader>do', dap.step_out)
      vim.keymap.set('n', '<leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end)
    end
  }

  use {
    "folke/flash.nvim",
    config = function()
      vim.keymap.set({ 'n', 'o', 'x' }, 's', require('flash').jump)
      vim.keymap.set({ 'n', 'o', 'x' }, '<C-s>', require('flash').treesitter)
      vim.keymap.set({ 'o' },           'r', require('flash').remote)
      vim.keymap.set({ 'o', 'x' },      'R', require('flash').treesitter_search)
      vim.keymap.set({ 'c' },       '<C-s>', require('flash').toggle)
    end
  }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    config = function()
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
        vim.keymap.set('n', 'gr', vim.lsp.buf.references,  opts)
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

      for _, server in pairs({ 'clangd', 'rust_analyzer', 'phpactor', 'gopls' }) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end
  }

  use {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end
  }

  -- Snippets
  use {
    'L3MON4D3/LuaSnip',
    config = function()
      vim.keymap.set('i', '<C-s>', require('luasnip.extras.select_choice'))

      -- TODO: migrate
      require('snippets')
    end
  }

  -- Code
  use {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
      require('distant'):setup()
    end
  }

  use {
    'windwp/nvim-autopairs',
    config = function()
      local npairs = require('nvim-autopairs')
      local Rule   = require('nvim-autopairs.rule')

      npairs.setup({
        check_ts = true
      })
      npairs.add_rules({
        Rule(' ', ' ')
          :with_pair(function (opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ '()', '[]', '{}' }, pair)
          end),
        Rule('( ', ' )')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
          end)
          :use_key(')'),
        Rule('{ ', ' }')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
          end)
          :use_key('}'),
        Rule('[ ', ' ]')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
          end)
          :use_key(']')
      })
    end
  }

  use {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
        require("nvim-surround").setup()
    end
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'ray-x/cmp-treesitter',
      'hrsh7th/cmp-nvim-lsp',
      'neovim/nvim-lspconfig',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'onsails/lspkind.nvim',
    },
    config = function()
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
    end
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'gitcommit',
          'go',
          'json',
          'kdl',
          'lua',
          'markdown',
          'php',
          'phpdoc',
          'query',
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
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter-refactor',
    requires = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
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
              -- TODO: change next bindings
              goto_next_usage = '<C-j>',
              goto_previous_usage = '<C-k>',
            },
          },
        },
      })
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
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
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter-context',
    requires = {
      'nvim-treesitter/nvim-treesitter'
    }
  }

  use {
    'HiPhish/nvim-ts-rainbow2',
    requires = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        rainbow = {
          enable = true
        }
      })
    end
  }

  use {
    'nvim-treesitter/playground',
    requires = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        playground = {
          enable = true
        }
      })
    end
  }
end)
