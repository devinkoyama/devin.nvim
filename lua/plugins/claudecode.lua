-- The LazyVim claudecode extra only loads on its <leader>a keymaps, so the
-- WebSocket server (which `claude` /ide discovers via ~/.claude/ide/*.lock)
-- isn't running until you press one. Load it at startup like the old config did.
return {
  "coder/claudecode.nvim",
  lazy = false,
  opts = {
    terminal = { provider = "native" },
  },
}
