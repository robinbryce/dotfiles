-- wart list:
-- 'gd' just highlights for go and svelte files
-- auto insert/completion for things like html tags not working in svelte files
-- go lang ingeneral not fully configured
-- . gofmt on save not setup
-- . goimports not setup


-- made using: https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
-- see also: https://github.com/nanotee/nvim-lua-guide
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

local uv = vim.loop
local function file_exists(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == 'file'
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
-- print('CONFIGDIR: ' .. configdir)

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
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
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
-- https://github.com/nanotee/nvim-lua-guide#defining-mappings
-- vim.keymap.set('n', '<F12>', ':NERDTreeToggle<CR>')
vim.keymap.set('n', '<F3>', ':Ag<CR>')
vim.keymap.set('n', '<C-p>', ':FZF<cr>')
-- vim.keymap.set('n', '<F7>', ':ALEFix<CR>')
-- vim.keymap.set('n', '<F8>', ':TagbarToggle<CR>')
--
vim.keymap.set('n', '<leader>/', ':Ag ')
-- vim.keymap.set('n', '<leader>x', ':Ag expand("<cword>")') doesn't work
vim.keymap.set('n', '<leader>fn', ':echo expand("%:p")<CR>')
vim.keymap.set('n', '<leader>cl', ':set cursorline<cr>')
vim.keymap.set('n', '<leader>ncl', ':set nocursorline<cr>')
vim.keymap.set('n', '<leader>l', ':set scrolloff=999<cr>')
vim.keymap.set('n', '<leader>nl', ':set scrolloff=0<cr>')
vim.keymap.set('n', '<leader>s', ':set spell<cr>')
vim.keymap.set('n', '<leader>ns', ':set nospell<cr>')
-- toggle line numbers with <leader>nn, makes copying cleaner
vim.keymap.set('n', '<leader>nn', ':set nonumber!<CR>:set foldcolumn=0<CR>')

-- Further plugin specific bindins in:
-- Source navigation & formatting
-- . lua/user/lsp.lua (language server protocl)
-- . lua/user.lspsaga.lua (language server protocl)

-- ---------------------------------------------------------------------------
-- snips bindings
-- ---------------------------------------------------------------------------
vim.cmd([[
" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
" -1 for jumping backwards.
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

" For changing choices in choiceNodes (not strictly necessary for a basic setup).
imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
]])


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

-- Development tooling
Plug 'tpope/vim-fugitive'

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
  luasnip_opts.paths = vim.fn.getcwd() .. '/.vscode'
  print('luasnip paths: ' .. luasnip_opts.paths)
end
luasnip = require('luasnip')
luasnip.filetype_extend("all", {"_"})

-- require("luasnip.loaders.from_vscode").lazy_load(luasnip_opts)
if file_exists(vim.fn.getcwd() .. '/.vscode/package.json') then
  require("luasnip.loaders.from_vscode").load(luasnip_opts)
end
-- require("luasnip.loaders.from_vscode").load({paths = '~/.config/nvim/snippets-vscode'})

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



