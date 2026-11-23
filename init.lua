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
    end
  end,
})

vim.pack.add({
  'https://github.com/folke/snacks.nvim',          -- picker, explorer, lazygit, terminal and small extras
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/lewis6991/gitsigns.nvim',    -- git signs in the gutter
  'https://github.com/folke/which-key.nvim',       -- popup that shows available keys
  'https://github.com/folke/tokyonight.nvim',      -- color scheme
  'https://github.com/coder/claudecode.nvim',      -- Claude Code integration
  'https://github.com/nvim-tree/nvim-web-devicons', -- file icons (needs a Nerd Font)
  'https://github.com/akinsho/bufferline.nvim',    -- open buffers as tabs along the top
})

-- Colors -------------------------------------------------------------------
-- Styles: night, storm, moon, day. Try them live with `:colorscheme <Tab>`.
-- Plain `tokyonight` follows 'background', which Neovim sets from your terminal's
-- background color (and updates live when the terminal switches light/dark).
o.termguicolors = true -- full 24-bit color (some SSH setups don't detect it automatically)
require('tokyonight').setup({ style = 'night', light_style = 'day' })
vim.cmd.colorscheme('tokyonight')

-- Snacks -------------------------------------------------------------------
-- A bundle of small modules; each one is off unless enabled here.
-- `:checkhealth snacks` shows what's on.
require('snacks').setup({
  picker = {                -- fuzzy finder (also used for code actions etc. via vim.ui.select)
    enabled = true,
    sources = { explorer = { hidden = true } }, -- show dotfiles in the explorer
  },
  explorer = { enabled = true }, -- file tree; also opens when you `nvim <folder>`
  lazygit = { enabled = true },
  terminal = { enabled = true },
  bufdelete = { enabled = true },
  indent = { enabled = true },    -- indent guides, current scope highlighted
  words = { enabled = true },     -- highlight other uses of the word under the cursor
  notifier = { enabled = true },  -- nicer messages, with history
  bigfile = { enabled = true },   -- turn off heavy features on huge files
  quickfile = { enabled = true }, -- show `nvim file` before plugins finish loading
})
local map = vim.keymap.set

-- Fuzzy finder -----------------------------------------------------------
-- Inside the picker: type to filter, <C-n>/<C-p> move, <CR> open, <C-v>/<C-s> split,
-- <Tab> select several, <Esc> close, ? (in normal mode) for all keys.
local pick = Snacks.picker
map('n', '<leader>f', function() pick.files() end, { desc = 'Find files' })
map('n', '<leader>/', function() pick.grep() end, { desc = 'Search text in project' })
map('n', '<leader>bb', function() pick.buffers() end, { desc = 'Search open buffers' })
map('n', '<leader>h', function() pick.help() end, { desc = 'Search help' })
map('n', '<leader>r', function() pick.recent() end, { desc = 'Recent files' })
map('n', '<leader>s', function() pick.lsp_symbols() end, { desc = 'Symbols in file' })
map('n', '<leader>x', function() pick.diagnostics() end, { desc = 'All diagnostics' })
map('n', '<leader>k', function() pick.keymaps() end, { desc = 'Search keymaps' })
map('n', '<leader>.', function() pick.resume() end, { desc = 'Reopen last search' })
map('n', '<leader>n', function() pick.notifications() end, { desc = 'Notification history' })
map('n', '<leader>p', function() pick() end, { desc = 'All pickers' })

-- Jump between highlighted uses of the word under the cursor (snacks words)
map('n', ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next reference' })
map('n', '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Previous reference' })

-- Terminal: toggle a terminal split. <C-/> works in normal and terminal mode.
map({ 'n', 't' }, '<C-/>', function() Snacks.terminal() end, { desc = 'Toggle terminal' })
map({ 'n', 't' }, '<C-_>', function() Snacks.terminal() end, { desc = 'Toggle terminal' }) -- what some terminals send for <C-/>

-- Tree-sitter: better highlighting + indentation --------------------------
require('nvim-treesitter').install({
  'typescript', 'tsx', 'javascript', 'json', 'lua', 'markdown',
  'markdown_inline', 'bash', 'yaml', 'css', 'html', 'python', 'toml', 'swift',
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
-- Tree sidebar that follows the current file. Inside it: <CR>/l open, h close folder,
-- a add (end with / for a folder), r rename, d delete, c copy, m move, H toggle dotfiles,
-- <BS> go up, ? help.
map('n', '<leader>e', function() Snacks.explorer() end, { desc = 'File explorer' })
map('n', '-', function() Snacks.explorer.reveal() end, { desc = 'Show current file in explorer' })

-- Buffer tabs (LazyVim-style keys) --------------------------------------------
-- Pin the files you care about, then <leader>bP clears out everything else.
require('bufferline').setup({
  options = {
    diagnostics = 'nvim_lsp', -- show LSP error/warning counts on tabs
    always_show_bufferline = false, -- hide the bar when only one buffer is open
  },
})
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
map('n', '[b', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
map('n', ']b', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
map('n', '[B', '<cmd>BufferLineMovePrev<CR>', { desc = 'Move buffer left' })
map('n', ']B', '<cmd>BufferLineMoveNext<CR>', { desc = 'Move buffer right' })
map('n', '<leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = 'Toggle pin' })
map('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<CR>', { desc = 'Close non-pinned buffers' })
map('n', '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', { desc = 'Close other buffers' })
map('n', '<leader>bl', '<cmd>BufferLineCloseLeft<CR>', { desc = 'Close buffers to the left' })
map('n', '<leader>br', '<cmd>BufferLineCloseRight<CR>', { desc = 'Close buffers to the right' })
map('n', '<leader>bj', '<cmd>BufferLinePick<CR>', { desc = 'Pick buffer' })
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Close buffer (keep window)' })

-- Git ----------------------------------------------------------------------
local gs = require('gitsigns')
gs.setup()
map('n', ']h', function() gs.nav_hunk('next') end, { desc = 'Next git hunk' })
map('n', '[h', function() gs.nav_hunk('prev') end, { desc = 'Previous git hunk' })
map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
map('n', '<leader>gb', gs.blame_line, { desc = 'Blame line' })

-- lazygit in a floating window (snacks); colors match the current theme
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'lazygit' })
map('n', '<leader>gl', function() Snacks.lazygit.log_file() end, { desc = 'lazygit: history of this file' })

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
wk.setup({ spec = { { '<leader>g', group = 'git' }, { '<leader>b', group = 'buffers' },{ '<leader>a', group = 'claude' } } })
map('n', '<leader>?', function() wk.show({ global = false }) end, { desc = 'Keymaps for this buffer' })

---------------------------------------------------------------------------
-- LSP: language servers defined in ./lsp/*.lua
---------------------------------------------------------------------------
vim.lsp.enable({ 'typescript', 'oxlint', 'oxfmt', 'basedpyright', 'ruff', 'sourcekit' })

vim.diagnostic.config({ virtual_text = true }) -- show errors inline

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local buf = ev.buf

    -- Autocomplete as you type (built-in). <C-n>/<C-p> to move, <C-y> to accept.
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    -- Format on save with one formatter per language (so servers never fight):
    -- oxfmt for JS/TS/etc., ruff for Python.
    local formatters = { oxfmt = true, ruff = true }
    if formatters[client.name] then
      local fmt = function()
        vim.lsp.buf.format({ bufnr = buf, name = client.name, timeout_ms = 2000 })
      end
      vim.api.nvim_create_autocmd('BufWritePre', { buffer = buf, callback = fmt })
      map('n', '<leader>F', fmt, { buffer = buf, desc = 'Format file' })
    end

    map('n', 'gd', function() Snacks.picker.lsp_definitions() end, { buffer = buf, desc = 'Go to definition' })
    map('n', 'grr', function() Snacks.picker.lsp_references() end, { buffer = buf, desc = 'References' })
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
