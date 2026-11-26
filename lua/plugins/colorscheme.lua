-- tokyonight, recoloured with Ghostty's "Claude Dark" / "Claude Light" palettes,
-- with a transparent background so the terminal's opacity shows through.
-- tokyonight picks its dark or light style from `vim.o.background`
-- (see auto-dark-mode.lua), and on_colors recolours whichever one is active.
local dark = {
  bg = "#262624",
  bg_dark = "#1f1f1d",
  bg_highlight = "#363634",
  fg = "#e5e4e1",
  fg_dark = "#a6a59b",
  fg_gutter = "#4a4946",
  comment = "#888681",
  red = "#d47563",
  orange = "#d97757",
  yellow = "#e8c96b",
  green = "#9aca86",
  teal = "#3cbe8c",
  cyan = "#79d7b3",
  blue = "#6a9bcc",
  purple = "#9b87f5",
  magenta = "#f3aac5",
}

local light = {
  bg = "#faf9f5",
  bg_dark = "#f0eee6",
  bg_highlight = "#e8e6dc",
  fg = "#141413",
  fg_dark = "#51504d",
  fg_gutter = "#b6b5aa",
  comment = "#7a786f",
  red = "#a84b3a",
  orange = "#c15f3c",
  yellow = "#8a6220",
  green = "#2e7c4c",
  teal = "#199f70",
  cyan = "#066049",
  blue = "#184e95",
  purple = "#8b6cb0",
  magenta = "#882b4d",
}

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(c)
        local p = vim.o.background == "light" and light or dark
        for k, v in pairs(p) do
          c[k] = v
        end
        c.bg_float = p.bg_dark
        c.bg_sidebar = p.bg_dark
        c.bg_statusline = p.bg_dark
        c.border = p.fg_gutter
        c.bg_visual = p.bg_highlight
        c.fg_float = p.fg
        c.fg_sidebar = p.fg_dark
        c.git = { add = p.green, change = p.blue, delete = p.red, ignore = p.comment }
        c.error = p.red
        c.warning = p.yellow
        c.info = p.blue
        c.hint = p.teal
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "claude" } },
}
