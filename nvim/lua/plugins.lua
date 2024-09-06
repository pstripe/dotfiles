local function bootstrap_package_manager()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

bootstrap_package_manager()


require('lazy').setup({
  -- Theme
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('sonokai')
    end,
  },

  -- UI/UX
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '┆',
        smart_indent_cap = true,
      },
      scope = {
        exclude = {
          language = { 'php' }
        },
        show_start = false,
      }
    }
  },

  {
    'm4xshen/hardtime.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim'
    },
    opts = {
      disable_mouse = false,
    },
  },

  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    init = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 500
    end,
    config = true,
  },

  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true,
  },

  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      return require('alpha.themes.startify').config
    end,
  },

  {
    'hoob3rt/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    init = function()
      vim.opt.cmdheight = 2
      vim.opt.showmode = false
    end,

    opts = {
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
        'man',
        'quickfix',
        'lazy'
      }
    },
  },

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { desc = 'Git: last change'})
        vim.keymap.set('n', '<leader>gb', function() gs.blame_line({full = true}) end, { buffer = bufnr, desc = 'Git: blame for line' })

        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Git: next changed hunk' })

        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Git: previous changed hunk' })
      end
    },
  },

  {
    'FabijanZulj/blame.nvim',
    cmd = { 'BlameToggle' },
  },

  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Tools
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
  },

  { 'echasnovski/mini.align', version = false, config = true, },

  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'FzfLua' },
    keys = {
      { '<leader>f',  mode = 'n', function() require('fzf-lua').files() end, desc = 'Fuzzy Finder' },
      { '<leader>/',  mode = 'n', function() require('fzf-lua').live_grep() end, desc = 'Live Grep' },
      { '<leader>fw', mode = 'n', function() require('fzf-lua').grep_cword() end, desc = 'Grep for cword' },
      { '<leader>\'', mode = 'n', function() require('fzf-lua').resume() end, desc = 'Open pervious FzfLua search' },
    }
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    cmd = { 'Telescope' },
    keys = {
      { '<leader>b',  mode = 'n', function() require('telescope.builtin').buffers() end, desc = 'Opened buffers' },
      { '<leader>o',  mode = 'n', function() require('telescope.builtin').commands() end, desc = 'Nvim commands' },
      { '<leader>fs', mode = 'n', function() require('telescope.builtin').treesitter() end, desc = 'Current buffer symbols' },
      { '<leader>fl', mode = 'n', function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = 'Current buffer lines' },
    },
  },

  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim'
    },

    keys = {
      { '<leader>n', mode = 'n', function() require('telescope').extensions.file_browser.file_browser({ path = '%:p:h' }) end, desc = 'File Browser' }
    },
    config = function()
      require('telescope').load_extension('file_browser')
    end
  },

  {
    'chrisgrieser/nvim-spider',
    lazy = true,
    keys = {
      { 'e', "<cmd>lua require('spider').motion('e')<cr>", mode = { 'n', 'o', 'x' } },
      { 'w', "<cmd>lua require('spider').motion('w')<cr>", mode = { 'n', 'o', 'x' } },
      { 'b', "<cmd>lua require('spider').motion('b')<cr>", mode = { 'n', 'o', 'x' } },
    },
    opts = {
      skipInsignificantPunctuation = false,
      consistentOperatorPending = true,
    },
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      mode = 'fuzzy',
      modes = {
        search = {
          enabled = true,
        },
      },
    },
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, "<cmd>lua require('flash').jump()<cr>",              desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, "<cmd>lua require('flash').treesitter()<cr>",        desc = 'Flash Treesitter' },
      { 'r', mode = 'o',               "<cmd>lua require('flash').remote()<cr>",            desc = 'Remote Flash', noremap = true },
      { 'R', mode = { 'o', 'x' },      "<cmd>lua require('flash').treesitter_search()<cr>", desc = 'Treesitter Search', noremap = true },
      { '<c-s>', mode = { 'c' },       "<cmd>lua require('flash').toggle()<cr>",            desc = 'Toggle Flash Search' },
    }
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },

    keys = {
      { '<leader>d',  mode = 'n', vim.diagnostic.setloclist, desc = 'Diagnostics to loclist' },
      { '<leader>df', mode = 'n', vim.diagnostic.open_float, desc = 'Diagnostics to float' },
      { '[d',         mode = 'n', vim.diagnostic.goto_prev,  desc = 'Prev diagnostics' },
      { ']d',         mode = 'n', vim.diagnostic.goto_next,  desc = 'Next diagnostics' },
    },

    config = function()
      local function on_attach(client, bufnr)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, buffer = bufnr, desc = 'Go to declaration' })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, buffer = bufnr, desc = 'Go to definition' })
        vim.keymap.set('n', 'gR', vim.lsp.buf.references,  { noremap = true, buffer = bufnr, desc = 'Find references' })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, buffer = bufnr, desc = 'Find implementations' })
        -- vim.keymap.set('n', 'K',  vim.lsp.buf.hover, { noremap = true, buffer = bufnr, desc = 'Show info' })

        vim.keymap.set('n', '<leader>D',  vim.lsp.buf.type_definition, { noremap = true, buffer = bufnr, desc = 'Go to type definition' })
        -- vim.keymap.set('n', '<leader>k',  vim.lsp.buf.signature_help, { noremap = true, buffer = bufnr, desc = 'Show signature help' })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, buffer = bufnr, desc = 'Code action' })

        -- Set some keybinds conditional on server capabilities
        if client.server_capabilities.document_formatting then
          vim.keymap.set('n', '<leader>fmt', vim.lsp.buf.format({ async = true }), { noremap = true, buffer = bufnr, desc = 'Run formatter' })
        elseif client.server_capabilities.document_range_formatting then
          vim.keymap.set('n', '<leader>fmt', vim.lsp.buf.range_formatting, { noremap = true, buffer = bufnr, desc = 'Run formatter for range' })
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
    end
  },

  -- Code
  {
    'windwp/nvim-autopairs',
    opts = {
      check_ts = true
    },
  },

  {
    'garymjr/nvim-snippets',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'hrsh7th/nvim-cmp',
    },

    lazy = false,
    opts = {
      friendly_snippets = true,
    },

    keys = {
      {
        '<c-l>',
        mode = 'i',
        function()
          if vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          end
        end,
        silent = true, desc = 'Expand snippet'
      },

      {
        '<c-l>',
        mode = 's',
        function()
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
        end,
        silent = true, desc = 'Go to next placeholder'
      },

      {
        '<c-h>',
        mode = { 'i', 's' },
        function()
          if vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          end
        end,
        silent = true, desc = 'Go to prev placeholder'
      },
    }
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'ray-x/cmp-treesitter',
      'hrsh7th/cmp-nvim-lsp',
      'neovim/nvim-lspconfig',
      'onsails/lspkind.nvim',
    },

    init = function()
      vim.opt.completeopt = 'menuone,noselect'
    end,

    config = function(_, opts)
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      vim.keymap.set('i', '<C-x><C-o>', cmp.complete, { desc = 'Open completion' })

      cmp.setup({
      completion = {
        autocomplete = false
      },
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
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
        { name = 'snippets' },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 60,
        })
      }
    })
    end
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = function() vim.cmd('TSUpdate') end,
    dependencies = {
      'nushell/tree-sitter-nu'
    },

    opts = {
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
        'nu',
        'php',
        'phpdoc',
        'python',
        'query',
        'regex',
        'rust',
        'toml',
        'vimdoc',
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
    },

    main = 'nvim-treesitter.configs',
  },

  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    opts = {
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
    },
    main = 'nvim-treesitter.configs',
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    opts = {
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'single',
          peek_definition_code = {
            ['<leader>lsf'] = '@function.outer',
            ['<leader>lsc'] = '@class.outer',
          },
        },
      },
    },

    main = 'nvim-treesitter.configs',
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    }
  },
})
