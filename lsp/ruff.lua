-- ruff: Python lint warnings + quick fixes (`gra`) and formatting (Black-compatible).
-- Format-on-save is set up in init.lua. Uses the project's .venv/bin/ruff if present.
-- Install: uv tool install ruff
return {
  cmd = function(dispatchers, config)
    local bin = config.root_dir and (config.root_dir .. '/.venv/bin/ruff')
    if not (bin and vim.uv.fs_stat(bin)) then bin = 'ruff' end
    return vim.lsp.rpc.start({ bin, 'server' }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false -- let basedpyright handle `K`
  end,
}
