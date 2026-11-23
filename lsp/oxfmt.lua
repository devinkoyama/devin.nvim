-- oxfmt: formatter (Prettier-compatible). Format-on-save is set up in init.lua.
-- Uses the project's node_modules/.bin/oxfmt if present, else the global one.
return {
  cmd = function(dispatchers, config)
    local bin = config.root_dir and (config.root_dir .. '/node_modules/.bin/oxfmt')
    if not (bin and vim.uv.fs_stat(bin)) then bin = 'oxfmt' end
    return vim.lsp.rpc.start({ bin, '--lsp' }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = {
    'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
    'json', 'jsonc', 'css', 'markdown', 'yaml',
  },
  root_markers = { '.oxfmtrc.json', '.oxfmtrc.jsonc', 'package.json', '.git' },
}
