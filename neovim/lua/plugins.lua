-- Bootstrap
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute('packadd packer.nvim')
end

-- Only required if you have packer in your `opt` pack
vim.cmd([[packadd packer.nvim]])

-- Auto update plugins' list
vim.cmd([[autocmd BufWritePost plugins.lua PackerCompile]])

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
    'mhinz/vim-startify',
    config = function()
      vim.g.startify_change_to_dir = 0
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_bookmarks = { '~/.config/nvim/init.lua', '~/.zshrc' }
      vim.g.startify_commands = {{ G = ':Gstatus' }}
    end
  }
  use {
    'hoob3rt/lualine.nvim',
    requires = {
      'nvim-lua/lsp-status.nvim',
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
    config = function()
      vim.o.cmdheight = 2
      vim.o.showmode = false

      local function lspstatus()
        return require('lsp-status').status()
      end

      require('lualine').setup({
        options = {
          theme = 'oceanicnext'
        },
        sections = {
          lualine_b = { { 'filename', path = 1 } },
          lualine_c = { lspstatus },
        },
        extensions = {
          'fugitive',
        }
      })
    end
  }


  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup({
        -- GitGutter theme and new signs
        signs = {
          add          = {hl = 'GitGutterAdd'   , text = '|', numhl='GitSignsAddNr'},
          change       = {hl = 'GitGutterChange', text = '|', numhl='GitSignsChangeNr'},
          delete       = {hl = 'GitGutterDelete', text = '_', numhl='GitSignsDeleteNr'},
          topdelete    = {hl = 'GitGutterDelete', text = '‾', numhl='GitSignsDeleteNr'},
          changedelete = {hl = 'GitGutterChange', text = '~', numhl='GitSignsChangeNr'},
        },
      })
    end
  }

  use {
    'tpope/vim-fugitive',
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>gp',  '<cmd>Git push<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<leader>gpf', '<cmd>Git push --force-with-lease<CR>', { noremap = true, silent = false })
    end
  }

  -- Finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
    },
    config = function()
      vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>lua require("telescope.builtin").find_files()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>lua require("telescope.builtin").live_grep()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fw', '<cmd>lua require("telescope.builtin").grep_string()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fl', '<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fs', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', { noremap = true, silent = true })
    end
  }

  -- INFO: fallback for telescope
  use {
    'junegunn/fzf.vim',
    disable = true,
    config = function()
      vim.o.runtimepath = vim.o.runtimepath .. ',/usr/local/opt/fzf'
    end
  }

  -- Tools
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons'
    }
  }

  use {
    'ggandor/lightspeed.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', 's', '<Plug>Lightspeed_s', { noremap = false, silent = true })
    end
  }

  use {
    'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap'
    },
    run = {
      'git clone https://github.com/xdebug/vscode-php-debug.git',
      'cd vscode-php-debug && npm install && npm run build'
    },
    ft = 'php',
    config = function()
      local dapui = require('dapui')
      dapui.setup({
        sidebar = {
          elements = {
            "scopes",
            "breakpoints",
            "stacks",
            "watches"
          },
          size = 40,
          position = "left" -- Can be "left" or "right"
        },
      })
      vim.api.nvim_set_keymap('n', '<leader>dd', ':lua require("dapui").toggle()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>de', ':lua require("dapui").eval(vim.fn.input("Eval expression: "))', { noremap = true })
      vim.api.nvim_set_keymap('v', '<leader>de', ':lua require("dapui").eval()<CR>', { noremap = true, silent = true })


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

      vim.api.nvim_set_keymap('n', '<leader>dc', ':lua require("dap").continue()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ds', ':lua require("dap").toggle_breakpoint()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>dn', ':lua require("dap").step_over()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>d[', ':lua require("dap").step_into()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>do', ':lua require("dap").step_out()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>db', ':lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>dl', ':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', { noremap = true, silent = true })
    end
  }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'nvim-lua/lsp-status.nvim'
    },
    config = function()
      local lsp_status = require('lsp-status')
      lsp_status.register_progress()
      lsp_status.config({
        current_function = true,
        indicator_info = 'ℹ',
        status_symbol = '★'
      })

      local function on_attach(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

        -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        lsp_status.on_attach(client, bufnr)

        -- Mappings.
        local opts = { noremap=true, silent=true }
        buf_set_keymap('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', '<leader>ld', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', '<leader>lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>'     , '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<leader>ln', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<leader>le', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d'        , '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d'        , '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
          buf_set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        elseif client.resolved_capabilities.document_range_formatting then
          buf_set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
        end

        -- Set autocommands conditional on server_capabilities
        if client.resolved_capabilities.document_highlight then
          vim.api.nvim_exec([[
            hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
            hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
            augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
          ]], false)
        end
      end

      require('lspconfig').intelephense.setup({
        on_attach = on_attach,
        capabilities = lsp_status.capabilities
      })
    end
  }

  -- Code
  use {
    'raimondi/delimitmate',
    config = function()
      vim.g.delimitMate_expand_space = 1
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
    'hrsh7th/nvim-compe',
    config = function()
      vim.o.completeopt = 'menuone,noselect'
      require('compe').setup({
        source = {
          nvim_lsp = true,
          nvim_lua = true,
        }
      })
    end
  }

  -- INFO: waiting for stabilization
  use {
    'nvim-treesitter/nvim-treesitter',
    disable = true,
    config = function()
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = false,
        }
      })
    end
  }

  -- INFO: waiting for gitui features
  use {
    'akinsho/nvim-toggleterm.lua',
    disable = true,
    config = function()
      require('toggleterm').setup()

      local Terminal = require('toggleterm.terminal').Terminal
      local gitui = Terminal:new({
        cmd = 'gitui',
        direction = 'float',
        hidden = true
      })

      function _gitui_toggle()
        gitui:toggle()
      end

      vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>lua _gitui_toggle()<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>i', '<cmd>ToggleTerm<CR>', {noremap = true, silent = true})
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
end)
