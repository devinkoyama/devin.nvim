-- Claude Dark / Claude Light, chosen by `vim.o.background`.
-- Palette and transparency live in lua/plugins/colorscheme.lua.
require("tokyonight").load({ style = vim.o.background == "light" and "day" or "night" })
vim.g.colors_name = "claude"
