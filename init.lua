-- Neovim config. One file on purpose: read it top to bottom.
-- Language servers live in ./lsp/<name>.lua (Neovim loads those automatically).

---------------------------------------------------------------------------
-- Leader key (must be set before any keymaps that use <leader>)
---------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

---------------------------------------------------------------------------
-- Options  (`:help 'optionname'` explains any of these)
---------------------------------------------------------------------------
local o = vim.opt
o.number = true          -- line numbers
o.relativenumber = true  -- relative numbers make `5j`, `3k` jumps easy
o.mouse = 'a'            -- mouse works in all modes
o.expandtab = true       -- spaces, not tabs
o.shiftwidth = 2
o.tabstop = 2
o.ignorecase = true      -- case-insensitive search...
o.smartcase = true       -- ...unless you type a capital letter
o.signcolumn = 'yes'     -- always show the gutter (git/diagnostic signs) so text doesn't jump
o.undofile = true        -- undo history survives closing the file
o.splitright = true
o.splitbelow = true
o.scrolloff = 8          -- keep 8 lines visible above/below the cursor
o.updatetime = 250       -- faster gutter/diagnostic updates
o.completeopt = { 'menuone', 'noselect', 'popup' }

---------------------------------------------------------------------------
-- Clipboard: over SSH, send yanks to your LOCAL machine's clipboard (OSC 52)
---------------------------------------------------------------------------
if vim.env.SSH_TTY then
  vim.g.clipboard = 'osc52'
end
o.clipboard = 'unnamedplus' -- `y` / `p` use the system clipboard

---------------------------------------------------------------------------
-- Plugins (built-in plugin manager: `:help vim.pack`)
-- Update all:  :lua vim.pack.update()
---------------------------------------------------------------------------
-- Build steps after a plugin is installed/updated. (Must be defined before vim.pack.add.)
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      vim.schedule(function() vim.cmd('TSUpdate') end)
    elseif name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
      vim.system({ 'make' }, { cwd = ev.data.path }) -- compiles the fast fuzzy sorter
    end
  end,
})

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',      -- helper library telescope needs
  'https://github.com/nvim-telescope/telescope.nvim', -- fuzzy finder
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim', -- faster sorting for telescope
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',  -- code actions etc. in telescope
  'https://github.com/stevearc/oil.nvim',          -- file explorer: edit folders like text
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/lewis6991/gitsigns.nvim',    -- git signs in the gutter
  'https://github.com/folke/which-key.nvim',       -- popup that shows available keys
  'https://github.com/folke/tokyonight.nvim',      -- color scheme
  'https://github.com/coder/claudecode.nvim',      -- Claude Code integration
})

-- Colors -------------------------------------------------------------------
-- Styles: tokyonight-night, -storm, -moon, -day. Try them live with `:colorscheme <Tab>`.
o.termguicolors = true -- full 24-bit color (some SSH setups don't detect it automatically)
vim.cmd.colorscheme('tokyonight-night')

-- Fuzzy finder -----------------------------------------------------------
-- Inside telescope: type to filter, <C-n>/<C-p> move, <CR> open, <C-v>/<C-x> split, <Esc> close.
require('telescope').setup({
  extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
})
pcall(require('telescope').load_extension, 'fzf') -- pcall: don't error if not built yet
require('telescope').load_extension('ui-select')
local tb = require('telescope.builtin')
local map = vim.keymap.set
map('n', '<leader>f', tb.find_files, { desc = 'Find files' })
map('n', '<leader>/', tb.live_grep, { desc = 'Search text in project' })
map('n', '<leader>b', tb.buffers, { desc = 'Open buffers' })
map('n', '<leader>h', tb.help_tags, { desc = 'Search help' })
map('n', '<leader>r', tb.oldfiles, { desc = 'Recent files' })
map('n', '<leader>s', tb.lsp_document_symbols, { desc = 'Symbols in file' })
map('n', '<leader>x', tb.diagnostics, { desc = 'All diagnostics' })
map('n', '<leader>k', tb.keymaps, { desc = 'Search keymaps' })
map('n', '<leader>.', tb.resume, { desc = 'Reopen last search' })

-- Tree-sitter: better highlighting + indentation --------------------------
require('nvim-treesitter').install({
  'typescript', 'tsx', 'javascript', 'json', 'lua', 'markdown',
  'markdown_inline', 'bash', 'yaml', 'css', 'html',
})
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    -- pcall: silently skip filetypes that have no parser installed
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- File explorer --------------------------------------------------------------
-- Edit the listing like text: rename a line to rename the file, `dd` to delete,
-- add a line to create (end with / for a folder). `:w` applies the changes.
-- <CR> open, `-` go up, `g?` help.
require('oil').setup({ view_options = { show_hidden = true } })
map('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent folder' })
map('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'File explorer' })

-- Git ----------------------------------------------------------------------
local gs = require('gitsigns')
gs.setup()
map('n', ']h', function() gs.nav_hunk('next') end, { desc = 'Next git hunk' })
map('n', '[h', function() gs.nav_hunk('prev') end, { desc = 'Previous git hunk' })
map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
map('n', '<leader>gb', gs.blame_line, { desc = 'Blame line' })

-- lazygit in a floating terminal (no plugin needed)
map('n', '<leader>gg', function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width, height = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor', border = 'rounded', width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2), col = math.floor((vim.o.columns - width) / 2),
  })
  vim.fn.jobstart('lazygit', {
    term = true,
    on_exit = function() vim.api.nvim_buf_delete(buf, { force = true }) end,
  })
  vim.cmd.startinsert()
end, { desc = 'lazygit' })

-- Claude Code --------------------------------------------------------------
-- Runs the `claude` CLI in a split and lets it see your selection, open files,
-- and propose edits as diffs. In the diff: <leader>aa accept, <leader>ad reject.
require('claudecode').setup({ terminal = { provider = 'native' } })
map('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude' })
map('n', '<leader>af', '<cmd>ClaudeCodeFocus<CR>', { desc = 'Focus Claude' })
map('n', '<leader>ar', '<cmd>ClaudeCode --resume<CR>', { desc = 'Resume Claude session' })
map('n', '<leader>aC', '<cmd>ClaudeCode --continue<CR>', { desc = 'Continue last Claude session' })
map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', { desc = 'Select Claude model' })
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<CR>', { desc = 'Add file to Claude' })
map('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = 'Send selection to Claude' })
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = 'Accept Claude diff' })
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = 'Reject Claude diff' })

-- Key hints ----------------------------------------------------------------
local wk = require('which-key')
wk.setup({ spec = { { '<leader>g', group = 'git' }, { '<leader>a', group = 'claude' } } })
map('n', '<leader>?', function() wk.show({ global = false }) end, { desc = 'Keymaps for this buffer' })

---------------------------------------------------------------------------
-- LSP: language servers defined in ./lsp/*.lua
---------------------------------------------------------------------------
vim.lsp.enable({ 'typescript', 'oxlint', 'oxfmt' })

vim.diagnostic.config({ virtual_text = true }) -- show errors inline

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local buf = ev.buf

    -- Autocomplete as you type (built-in). <C-n>/<C-p> to move, <C-y> to accept.
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    -- Format on save with oxfmt only (so the TypeScript server never fights it).
    if client.name == 'oxfmt' then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = buf, name = 'oxfmt', timeout_ms = 2000 })
        end,
      })
    end

    map('n', 'gd', tb.lsp_definitions, { buffer = buf, desc = 'Go to definition' })
    map('n', 'grr', tb.lsp_references, { buffer = buf, desc = 'References' })
    map('n', '<leader>F', function() vim.lsp.buf.format({ name = 'oxfmt' }) end,
      { buffer = buf, desc = 'Format file' })
  end,
})
-- Built-in LSP keys you also get: K hover, grr references, grn rename,
-- gra code action, gri implementation, gO symbols, [d / ]d diagnostics,
-- <C-s> signature help (insert mode).

---------------------------------------------------------------------------
-- Small quality-of-life keymaps
---------------------------------------------------------------------------
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- Briefly highlight what you yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
})
