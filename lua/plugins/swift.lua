-- Swift: sourcekit-lsp ships with Xcode (not Mason), and LazyVim has no Swift extra,
-- so it has to be enabled by hand. Project indexing comes from buildServer.json
-- (xcode-build-server) at the project root.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          cmd = { "xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objc", "objcpp" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },
}
