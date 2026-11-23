# devin.nvim

Minimal Neovim (0.12+) config for TypeScript/JavaScript and Python, built to be used over SSH.
Uses only built-in features where possible: `vim.pack` for plugins, the built-in LSP client and built-in completion.

## Install

```sh
git clone git@github.com:devinkoyama/devin.nvim.git ~/.config/nvim

brew install ripgrep tree-sitter-cli lazygit
npm install -g typescript oxlint oxfmt
uv tool install ruff basedpyright
```

Open `nvim` and accept the plugin install prompt.

## Layout

- `init.lua`: settings, plugins and keymaps
- `lsp/*.lua`: one file per language server (`typescript` = `tsc --lsp`, `oxlint`, `oxfmt`, `basedpyright`, `ruff`)
- `nvim-pack-lock.json`: pinned plugin versions (update with `:lua vim.pack.update()`)

## Keys (leader = Space; press Space and wait to see them all)

| Key | Action |
|---|---|
| `<Space>f` / `<Space>/` | Find files / search text |
| `<Space>b` `<Space>r` `<Space>h` | Buffers / recent files / help |
| `<Space>s` `<Space>x` `<Space>k` | Symbols / diagnostics / keymaps |
| `<Space>.` | Reopen last search |
| `-` or `<Space>e` | File explorer (oil) |
| `gd` `grr` `grn` `gra` `K` | Definition, references, rename, code action, hover |
| `[d` `]d` `<Space>d` | Previous/next diagnostic, show diagnostic |
| `<Space>F` | Format (also runs on save, via oxfmt / ruff) |
| `]h` `[h` | Next/previous git hunk |
| `<Space>gs` `gr` `gp` `gb` | Stage / reset / preview hunk, blame line |
| `<Space>gg` | lazygit |
