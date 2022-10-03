-- made using: https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
-- OLD
-- set runtimepath^=~/.vim runtimepath+=~/.vim/after
-- let &packpath=&runtimepath
-- source ~/.vimrc
-- NEW >>>
-- 
-- 
-- 

-- bootstrap 1 things.
-- how neovim processes startup options, env and files
-- -- https://neovim.io/doc/user/starting.html#config
function dirname(path)
  sep = sep or '/'
  return path:match("(.*"..sep..")")
end

-- runtimepath (and consequently lua require path)
-- https://neovim.io/doc/user/lua.html#lua-require

vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
vim.opt.packpath = 'runtimepath^=~/.vim runtimepath+=~/.vim/after'

configdir = vim.fn.getcwd() .. '/nvim'

if vim.env.MYVIMRC then
  configdir = dirname(vim.env.MYVIMRC)
else
  print('MYVIMRC, not set did you launch with -u ?')
end
print('CONFIGDIR: ' .. configdir)

-- ---------------------------------------------------------------------------
-- explicit sources and pre-flight (bootstrap 2)
-- ---------------------------------------------------------------------------
-- vim-plug setup
vim.cmd('source ' .. configdir .. '/vim/ensureplug.vim')

-- file change notification
vim.cmd('source ' .. configdir .. '/vim/bufreload.vim')


-- ---------------------------------------------------------------------------
-- Global prefererences
-- ---------------------------------------------------------------------------

-- EDIT
vim.opt.tabstop = 2
vim.opt.shiftwidth = 3
vim.opt.expandtab = false
vim.opt.textwidth = 79
vim.cmd('set clipboard+=unnamedplus')
-- https://community.chocolatey.org/packages/win32yank
-- installed in windows with chocolated, then symlinked into ~/bin

-- DISPLAY

-- vim.opt.colorscheme = 'marklar'
vim.opt.termguicolors = true
vim.cmd('syntax on')

vim.opt.wrap = false
vim.opt.breakindent = true -- only significant if wrap = true
vim.opt.list = true
vim.opt.listchars = { tab = '\\ ', trail = '.' }
vim.opt.number = true

-- Global SEARCH
vim.opt.ignorecase = true -- ignore case for search
vim.opt.smartcase = true -- unless the search string has upper case
vim.opt.hlsearch = true -- highlight the search results

-- vim.opt.mouse = 'a'
vim.opt.autowrite = true -- write file whenever you get taken elsewhere

vim.g.mapleader = ','
vim.g.pyx=3
vim.g.updatetime=400

-- set noequalalways               " don't make all windows same size after split


-- ---------------------------------------------------------------------------
-- Global bindings
-- ---------------------------------------------------------------------------
-- vim.keymap.set('n', '<F12>', ':NERDTreeToggle<CR>')
vim.keymap.set('n', '<F3>', ':Ack<CR>')
-- vim.keymap.set('n', '<F7>', ':ALEFix<CR>')
-- vim.keymap.set('n', '<F8>', ':TagbarToggle<CR>')
--
vim.keymap.set('n', '<leader>fn', ':echo expand("%:p")<CR>')
vim.keymap.set('n', '<leader>cl', ':set cursorline<cr>')
vim.keymap.set('n', '<leader>ncl', ':set nocursorline<cr>')
vim.keymap.set('n', '<leader>l', ':set scrolloff=999<cr>')
vim.keymap.set('n', '<leader>nl', ':set scrolloff=0<cr>')
vim.keymap.set('n', '<leader>s', ':set spell<cr>')
vim.keymap.set('n', '<leader>ns', ':set nospell<cr>')
-- toggle line numbers with <leader>nn, makes copying cleaner
vim.keymap.set('n', '<leader>nn', ':set nonumber!<CR>:set foldcolumn=0<CR>')

-- LANGUAGE SERVER PROTOCOL Keybindings
-- (see further down for the connection between LSP attach and this autocmd)
vim.api.nvim_create_autocmd('User', {
  pattern = 'LspAttached',
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    -- bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    -- lspsaga

    -- Jump to the definition
    -- bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    -- lspsaga

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})

-- ---------------------------------------------------------------------------
-- vim-plugs
-- ---------------------------------------------------------------------------
local Plug = vim.fn['plug#']
-- vim.call('plug#begin', '~/.config/nvim/plugged')
vim.call('plug#begin', configdir .. '/plugged')

-- TERMINAL NAVIGATION tmux - neovim - tmux
-- when the tmux window is zoomed on vim, I don't want it to automatically
-- unzoom when I use window navigation in vim
vim.g.tmux_navigator_disable_when_zoomed = 1
Plug 'christoomey/vim-tmux-navigator'

-- FINDING ANYTHING
Plug('junegunn/fzf', {
  ['do'] = function ()
    vim.call('fzf#install')
  end
})
-- brew install the_silver_searcher to get 'ag'

Plug 'junegunn/fzf.vim'
-- https://github.com/junegunn/fzf.vim

-- FILE FINDING
Plug 'mileszs/ack.vim'

-- FILE NAVIGATION
Plug 'scrooloose/nerdtree'

-- UI/ANNOTATIONS/GUTTERS
-- Plug 'folke/lsp-colors.nvim'
-- Plug 'joshdick/onedark.vim' -- to pale and washed out
Plug('kyoz/purify', { rtp = 'vim' })
-- to try: badwolf, 

Plug 'hoob3rt/lualine.nvim'
Plug('glepnir/lspsaga.nvim', { branch = 'main' })
-- SYNTAX & SYNTAX-COLORING
Plug 'sheerun/vim-polyglot'

-- LANGUAGE SERVER PROTOCOL
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
-- 

Plug('L3MON4D3/LuaSnip', {tag = 'v<CurrentMajor>.*'})
Plug 'rafamadriz/friendly-snippets'
Plug 'golang/vscode-go'


vim.call('plug#end')

-- ---------------------------------------------------------------------------
-- UI/look & feel
-- ---------------------------------------------------------------------------
-- vim.cmd('colorscheme onedark')
vim.cmd('colorscheme purify')
require('user.lualine')
require('user.lspsaga')

-- ---------------------------------------------------------------------------
-- SNIPPETS
-- ---------------------------------------------------------------------------
-- luasnip

local luasnip_opts = {}
if vim.fn.isdirectory(vim.fn.getcwd() .. '/.vscode') then
  luasnip_opts.paths = {}
  luasnip_opts.paths[0] = vim.fn.getcwd() .. '/.vscode'
  for i, v in pairs(luasnip_opts.paths) do
    print('luasnip paths: ' .. v)
  end
end
require("luasnip.loaders.from_vscode").lazy_load(luasnip_opts)

-- supports vscode format but we need to configure it to look in the
-- right places

-- vsnip
-- vsnip supports vscode format but we need to configure it to look in the
-- right places


-- ---------------------------------------------------------------------------
-- LANGUAGES
-- ---------------------------------------------------------------------------
require('user.lsp')

-- lua files and module locations for require() are derived from the
-- runtimepath. see https://neovim.io/doc/user/lua.html#lua-require

-- note that this sources the old vim style config in its entirity
-- vim.cmd('source ~/.vimrc')

-- print('getcwd: ' .. vim.fn.getcwd()) -- nvim launch directory
-- print('runtimepath: ' .. vim.fn.string(vim.opt.runtimepath)



