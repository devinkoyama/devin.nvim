-- oxlint: lint warnings + quick fixes (use `gra` on a warning).
-- Uses the project's node_modules/.bin/oxlint if present, else the global one.
return {
  cmd = function(dispatchers, config)
    local bin = config.root_dir and (config.root_dir .. '/node_modules/.bin/oxlint')
    if not (bin and vim.uv.fs_stat(bin)) then bin = 'oxlint' end
    return vim.lsp.rpc.start({ bin, '--lsp' }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { '.oxlintrc.json', 'package.json', '.git' },
}
