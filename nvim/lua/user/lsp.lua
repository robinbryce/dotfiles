-- language server protocol
-- based on: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/

function on_attach(client, bufnr)
  local bufmap = function(mode, lhs, rhs, opts)
    local merged_opts = {buffer = true}
    if opts then
      merged_opts = vim.tbl_extend("force", merged_opts, opts)
    end
    vim.keymap.set(mode, lhs, rhs, merged_opts)
  end
  print("on_attach CALLED")

  -- from https://medium.com/swlh/neovim-lsp-dap-and-fuzzy-finder-60337ef08060
  -- Mappings
  --
  local nrs_opts = { noremap=true, silent=true }
  bufmap('n', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', nrs_opts)
  bufmap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', nrs_opts)
  bufmap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', nrs_opts)
  bufmap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', nrs_opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  bufmap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', nrs_opts)
  -- bufmap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- luasaga
  -- bufmap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', nrs_opts)
  -- nil ref err

  -- -- Set some keybinds conditional on server capabilities
  if client.server_capabilities.document_formatting then
      bufmap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.server_capabilities.document_range_formatting then
      bufmap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
      require('lspconfig').util.nvim_multiline_command [[
      :hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      :hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      :hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
      ]]
  end

  -- Displays hover information about the symbol under the cursor
  -- bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  -- lspsaga

  -- Jump to the definition
  bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

  -- Jump to declaration
  bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

  -- Lists all the implementations for the symbol under the cursor
  bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

  -- Jumps to the definition of the type symbol
  bufmap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

  -- Lists all the references 
  bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

  -- Displays a function's signature information
  bufmap('n', '<leader>s', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

  -- Renames all references to the symbol under the cursor
  bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

  -- Selects a code action available at the current cursor position
  bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

  -- Show diagnostics in a floating window
  bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

  -- Move to the previous diagnostic
  bufmap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

  -- Move to the next diagnostic
  bufmap('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<cr>')
end

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
  on_attach = on_attach
}

local lspconfig = require('lspconfig')

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
)

require('lspconfig')['tsserver'].setup({})
require('lspconfig')['gopls'].setup({})
require('lspconfig')['pyright'].setup({})

