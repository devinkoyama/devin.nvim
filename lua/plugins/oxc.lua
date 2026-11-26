-- Builds on LazyVim's `lang.typescript.oxc` extra (enabled in lazyvim.json),
-- which runs oxlint as a language server and oxfmt as the formatter for JS/TS/JSON.

-- The other filetypes oxfmt can format
local filetypes = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "json5",
  "less",
  "markdown",
  "scss",
  "toml",
  "yaml",
}

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(filetypes) do
        opts.formatters_by_ft[ft] = { "oxfmt" }
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        oxlint = {
          -- The extra only starts oxlint in projects with an oxlint config file.
          -- Fall back to the project root, or the file's folder, so it always lints.
          root_dir = function(bufnr, on_dir)
            local markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
            local git = vim.fs.root(bufnr, ".git")
            on_dir(
              (git and vim.fs.root(git, markers))
                or vim.fs.root(bufnr, markers)
                or vim.fs.root(bufnr, { "package.json", ".git" })
                or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
            )
          end,
        },
      },
    },
  },
}
