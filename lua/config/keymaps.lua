-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Half-page scroll on pg dn / pg up, keeping the cursor centered
vim.keymap.set({ "n", "v" }, "<PageDown>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-u>zz", { desc = "Half page up" })
