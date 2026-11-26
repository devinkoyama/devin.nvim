-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Cursor colour follows the mode (highlights in plugins/colorscheme.lua),
-- with a blinking block in insert mode
vim.opt.guicursor:append({
  "n-sm:block-nCursor",
  "v:block-vCursor",
  "i-ci-ve:block-iCursor-blinkwait700-blinkon400-blinkoff250",
  "r-cr:hor20-rCursor",
  "c:block-cCursor",
})
