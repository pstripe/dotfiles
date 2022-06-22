 -- Bootstrap
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  local execute = vim.api.nvim_command
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute('packadd packer.nvim')
end

-- Only required if you have packer in your `opt` pack
vim.cmd([[packadd packer.nvim]])

-- Auto update plugins' list
vim.api.nvim_create_autocmd('BufWritePost', { pattern = 'plugins.lua', command = 'PackerCompile' })
return require('packer').startup(function()
  -- Packer can manage itself as an optional plugin
  use {'wbthomason/packer.nvim', opt = true}

  -- UI
  use {
    'bluz71/vim-moonfly-colors',
    config = function()
      vim.cmd [[colorscheme moonfly]]
      vim.cmd [[highlight Comment cterm=italic]]
      vim.cmd [[highlight Whitespace guifg=LightGray]]
    end
  }
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
    'mhinz/vim-startify',
    config = function()
      vim.g.startify_change_to_dir = 0
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_bookmarks = { '~/.config/nvim/lua/plugin.lua', '~/.config/nvim/lua/settings.lua', '~/.zshrc' }
      vim.g.startify_commands = {{ G = ':Git' }}
    end
  }
  use {
    'hoob3rt/lualine.nvim',
    requires = {
      { 'stevearc/aerial.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
    config = function()
      vim.o.cmdheight = 2
      vim.o.showmode = false

      local function status()
        return require('nvim-treesitter').statusline()
      end

      require('lualine').setup({
        options = {
          theme = 'oceanicnext',
        },
        sections = {
          lualine_b = { {
            'filename',
            path = 1,
            shorting_target = 60,
            symbols = {
              modified = ' ',
              readonly = ' ',
            }
          } },
          lualine_c = { 'aerial' },
        },
        tabline = {
          lualine_a = { 'branch', 'diff' },
          lualine_z = { 'tabs' },
        },
        extensions = {
          'aerial',
          'fugitive',
          'nvim-tree',
          'quickfix',
        }
      })
    end
  }


  -- Git
  use {
    'tanvirtin/vgit.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      vim.o.updatetime = 300
      vim.wo.signcolumn = 'yes'

      require('vgit').setup({
        keymaps = {
          ['n ]c']         = 'hunk_up',
          ['n [c']         = 'hunk_down',
          ['n <leader>hp'] = 'buffer_hunk_preview',
          ['n <leader>hb'] = 'buffer_blame_preview',
        },
        settings = {
          live_blame = {
            enabled = false
          },
          signs = {
            priority = 0,
            definitions = {
              GitSignsAdd = {
                texthl = 'GitSignsAdd',
                text = '|',
              },
              GitSignsDeleteLn = {
                linehl = 'GitSignsDeleteLn',
                text = '‾',
              },
              GitSignsDelete = {
                texthl = 'GitSignsDelete',
                text = '_',
              },
              GitSignsChange = {
                texthl = 'GitSignsChange',
                text = '|',
              },
            },
          },
        }
      })
    end
  }

  use {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gp',  '<cmd>Git push<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>gpf', '<cmd>Git push --force-with-lease<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>gyb', "<cmd>call setreg('+', FugitiveHead())<CR><cmd>echo 'Git branch yanked!'<CR>", { noremap = true, silent = false })
    end
  }

  -- Tools
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
    },
    config = function()
      local telescope_builtin = require('telescope.builtin')
      vim.keymap.set('n', '<C-p>',      telescope_builtin.find_files,  { noremap = true })
      vim.keymap.set('n', '<leader>ff', telescope_builtin.live_grep,   { noremap = true })
      vim.keymap.set('n', '<leader>fw', telescope_builtin.grep_string, { noremap = true })
      vim.keymap.set('n', '<leader>ft', telescope_builtin.treesitter,  { noremap = true })
      vim.keymap.set('n', '<leader>fl', telescope_builtin.current_buffer_fuzzy_find, { noremap = true })
    end
  }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons'
    },
    config = function()
      require('nvim-tree').setup()
      vim.keymap.set('n', '<leader>n', '<cmd>NvimTreeFindFile<CR>', { noremap = true, silent = true })
    end
  }

  use {
    'ggandor/lightspeed.nvim'
  }

  -- Debugger
  use {
    'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap'
    },
    run = {
      -- FIXME: what if already cloned?
      'git clone https://github.com/xdebug/vscode-php-debug.git',
      'cd vscode-php-debug && npm install && npm run build'
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
      vim.keymap.set('n', '<leader>dd', require("dapui").toggle, { noremap = true })
      vim.keymap.set('v', '<leader>de', require("dapui").eval,   { noremap = true })


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

      vim.keymap.set('n', '<leader>dc', require("dap").continue,          { noremap = true })
      vim.keymap.set('n', '<leader>ds', require("dap").toggle_breakpoint, { noremap = true })
      vim.keymap.set('n', '<leader>dn', require("dap").step_over,         { noremap = true })
      vim.keymap.set('n', '<leader>d[', require("dap").step_into,         { noremap = true })
      vim.keymap.set('n', '<leader>do', require("dap").step_out,          { noremap = true })
      vim.keymap.set('n', '<leader>dl', function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, { noremap = true })
    end
  }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local opts = { noremap = true }
      vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, opts)
      vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,  opts)
      vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,  opts)

      local function on_attach(client, bufnr)
        local opts = { noremap = true, buffer = bufnr }
        -- <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration,     opts)
        vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover,           opts)
        vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation,  opts)
        vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references,      opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
          vim.keymap.set('n', '<leader>lf', vim.lsp.buf.formatting, opts)
        elseif client.resolved_capabilities.document_range_formatting then
          vim.keymap.set('n', '<leader>lf', vim.lsp.buf.range_formatting, opts)
        end
      end

      local lspconfig = require('lspconfig')
      for _, server in pairs({ 'intelephense', 'clangd' }) do
        lspconfig[server].setup({
          on_attach = on_attach,
        })
      end
    end
  }

  -- Code
  use {
    'stevearc/aerial.nvim',
    requires = {
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
    config = function()
      require('aerial').setup({
        disable_max_lines = 15000,
        nerd_font = true,
      })
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

  -- WARN: key bind intersections with lightspeed
  use {
    'blackCauldron7/surround.nvim',
    disable = true,
    config = function()
      require('surround').setup({})
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        },
        indent = {
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
              smart_rename = '<leader>ln',
            },
          },
          -- TODO: add jumps over function usage
          navigation = {
            enable = true,
            keymaps = {
              goto_definition_lsp_fallback = '<leader>ld',
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
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
          },
        },
      })
    end
  }
end)
