""" @sumanthratna's neovim configuration
""" Heavily inspired by Optixal's Neovim Init.vim
""" https://github.com/Optixal/neovim-init.vim/blob/09121154d7bd0355d68389b8eb22e6b2e59fb63a/init.vim

""" Vim-Plug
call plug#begin()

" Core (treesitter, nvim-lspconfig, nvim-cmp, nvim-telescope, nvim-lualine)
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

" Functionalities
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'mhinz/vim-signify'
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-abolish'
Plug 'junegunn/vim-easy-align'
Plug 'preservim/nerdcommenter'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'chrisbra/Colorizer'
Plug 'KabbAmine/vCoolor.vim'
Plug 'dkarter/bullets.vim'
Plug 'wellle/context.vim'

" Functionalities - Python
Plug 'psf/black', { 'branch': 'stable' }
Plug 'heavenshell/vim-pydocstring'

" Aesthetics - Colorschemes
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Aesthetics - Others
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-journal'

call plug#end()

""" Main Configurations
filetype plugin indent on
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
set incsearch ignorecase smartcase hlsearch
set wildmode=longest,list,full wildmenu
set ruler laststatus=2 showcmd showmode
set list listchars=trail:»,tab:»-
set fillchars+=vert:\ 
set wrap breakindent
set mouse=a
set colorcolumn=80
set textwidth=0
set hidden
set number
set title

""" Filetype-Specific Configurations

" HTML, XML, Jinja
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType css setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType xml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango inoremap {{ {{  }}<left><left><left>
autocmd FileType htmldjango inoremap {% {%  %}<left><left><left>
autocmd FileType htmldjango inoremap {# {#  #}<left><left><left>

" Markdown and Journal
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType journal setlocal shiftwidth=2 tabstop=2 softtabstop=2

""" Coloring

" Functions and autocmds to run whenever changing colorschemes
function! TransparentBackground()
    highlight Normal guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    set fillchars+=vert:\│
    highlight WinSeparator gui=NONE guibg=NONE guifg=#444444 cterm=NONE ctermbg=NONE ctermfg=gray
    highlight VertSplit gui=NONE guibg=NONE guifg=#444444 cterm=NONE ctermbg=NONE ctermfg=gray
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme * call TransparentBackground()
augroup END

colorscheme catppuccin-frappe

""" Core plugin configuration (vim)

" nvim-cmp
set completeopt=menu,menuone,noselect

" signify
let g:signify_sign_add = '│'
let g:signify_sign_delete = '│'
let g:signify_sign_change = '│'
hi DiffDelete guifg=#ff5555 guibg=none

" Disable concealing json and markdown syntax (e.g. ```)
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

" context.vim
let g:context_nvim_no_redraw = 1

" Python
let g:nvim_python_venv = expand('~/.config/nvim/env')
let g:python3_host_prog = nvim_python_venv . '/bin/python3'
let g:pydocstring_doq_path = nvim_python_venv . '/bin/doq'

""" Core plugin configuration (lua)
lua << EOF
-- === nvim-treesitter
require('nvim-treesitter.config').setup {
    ensure_installed = {
        'python',
        'comment',
        'lua',
        --'typescript',
        --'javascript',
    },
    sync_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
-- === nvim-cmp
local kind_icons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = ""
}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
        -- Source for below custom borders: https://github.com/hrsh7th/nvim-cmp/pull/472#issuecomment-1098381334
        completion = {
            border = {'╭', '─', '╮', '│', '╯', '─', '╰', '│'},
            winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
        },
        documentation = {
            border = {'╭', '─', '╮', '│', '╯', '─', '╰', '│'},
            winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
        },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback) -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings for other snippet plugins
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path', option = { trailing_slash = true }},
        { name = 'nvim_lsp_signature_help' },
    }, {
        { name = 'buffer' },
    }),
    formatting = {
        format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                latex_symbols = "[LaTeX]",
            })[entry.source.name]
            return vim_item
        end
    },
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- DISABLED: cmdline completion breaks after first search (hrsh7th/nvim-cmp#1511)
-- cmp.setup.cmdline(':', {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources({
--         { name = 'path', option = { trailing_slash = true }}
--     }, {
--         { name = 'cmdline' }
--     })
-- })
-- === LSP (vim.lsp.config, Neovim 0.11+)
-- Diagnostic keymaps
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- LSP keymaps (set on attach via LspAttach autocmd)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local o = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, o)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, o)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, o)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, o)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, o)
        vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, o)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, o)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, o)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, o)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, o)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format() end, o)
    end,
})

-- LSP server config
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('pyright', {
    capabilities = capabilities,
    cmd = { vim.g.nvim_python_venv .. "/bin/pyright-langserver", "--stdio" },
})
vim.lsp.enable('pyright')

-- === telescope.nvim
require('telescope').load_extension('fzf')
-- === lualine.nvim
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        --component_separators = { left = '', right = ''},
        component_separators = { left = '╲', right = '╱' },
        --section_separators = { left = '', right = ''},
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'NvimTree' },
        always_divide_middle = true,
        globalstatus = false,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat'},
        lualine_y = {'filetype'},
        lualine_z = {{'os.date("%-I:%M %p")', color = {gui='NONE'}}}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'filetype'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {}
}
-- === nvim-tree
require'nvim-tree'.setup {
    git = {
        enable = true,
        ignore = false,
        timeout = 400,
    },
}
-- === indent-blankline
require('ibl').setup {
    indent = { char = '▏' },
    scope = { enabled = false },
}
-- === diagnostics
local signs = { Error = "✘", Warn = "", Hint = "•", Info = "" }

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = '●', -- Could be '●', '▎', 'x'
    }
})
EOF

""" Custom Functions

" Trim Whitespaces
function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\\\@<!\s\+$//e
    call winrestview(l:save)
endfunction

""" Custom Mappings (vim) (lua custom mappings are within individual lua config files)

" Core
let mapleader=","
nmap <leader>q :NvimTreeFindFileToggle<CR>
nmap \ <leader>q
nmap <leader>r :so ~/.config/nvim/init.vim<CR>
nmap <leader>t :call TrimWhitespace()<CR>
xmap <leader>a gaip*
nmap <leader>a gaip*
nmap <leader>h :RainbowParentheses!!<CR>
nmap <leader>j :set filetype=journal<CR>
nmap <leader>k :ColorToggle<CR>
nmap <leader>l :Limelight!!<CR>
xmap <leader>l :Limelight!!<CR>
nmap <silent> <leader><leader> :noh<CR>
nmap <Tab> :bnext<CR>
nmap <S-Tab> :bprevious<CR>

" Python
autocmd Filetype python nmap <leader>d <Plug>(pydocstring)
autocmd FileType python nmap <leader>p :Black<CR>

" Telescope mappings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fc <cmd>Telescope colorscheme<cr>
nnoremap <leader>f/ <cmd>Telescope current_buffer_fuzzy_find<cr>
