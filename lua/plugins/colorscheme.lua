-- Rosé Pine, with a transparent background so the terminal's opacity shows through.
-- The "auto" variant follows `vim.o.background` (see auto-dark-mode.lua):
-- dark uses `dark_variant`, light uses dawn.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto",
      dark_variant = "main",
      styles = {
        transparency = true,
      },
      highlight_groups = {
        -- Cursor colour per mode, matching the status line's mode badge
        -- (see guicursor in config/options.lua)
        nCursor = { fg = "base", bg = "rose" },
        iCursor = { fg = "base", bg = "foam" },
        vCursor = { fg = "base", bg = "iris" },
        rCursor = { fg = "base", bg = "pine" },
        cCursor = { fg = "base", bg = "love" },
        NoiceCursor = { fg = "base", bg = "love" },
      },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "rose-pine" } },
}
