-- Follow the macOS light/dark appearance setting.
-- tokyonight picks its "night" or "day" style based on `vim.o.background`.
return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      set_dark_mode = function()
        vim.o.background = "dark"
      end,
      set_light_mode = function()
        vim.o.background = "light"
      end,
      update_interval = 3000,
      fallback = "dark",
    },
  },
}
