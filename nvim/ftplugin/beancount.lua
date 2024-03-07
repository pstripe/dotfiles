local lspconfig = require('lspconfig')
lspconfig.beancount.setup({
  root_dir = function(filename, bufnr)
    return '~/ledger/'
  end,
  init_options = {
    journal_file = '~/ledger/ledger.beancount'
  }
})
