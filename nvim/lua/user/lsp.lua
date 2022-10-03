-- language server protocol
-- based on: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
local lsp_defaults = {
  -- milis to wait for next document update notification
  flags = {
    debounce_text_changes = 150,
  },
  -- announce to the servier what the editor caps are
  capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
  --callback triggered when any LSP attaches to a buffer. configured to trigger
  --an autocmd so we can manage the on_attach actions else where
  on_attach = function(client, bufnr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})
  end
}

local lspconfig = require('lspconfig')

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
)
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
require('lspconfig')['tsserver'].setup({})
require('lspconfig')['gopls'].setup({})
require('lspconfig')['pyright'].setup({})

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
require'lspconfig'.eslint.setup{}

