-- Python: types, completion, go-to-definition, rename (basedpyright = pyright + extras).
-- Uses the project's .venv (e.g. made by `uv sync`) so your installed packages resolve.
-- Install: uv tool install basedpyright
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      analysis = { typeCheckingMode = 'standard' }, -- 'basic' = quieter, 'strict'/'all' = louder
    },
  },
  before_init = function(_, config)
    local py = config.root_dir and (config.root_dir .. '/.venv/bin/python')
    if py and vim.uv.fs_stat(py) then
      config.settings.python = { pythonPath = py }
    end
  end,
}
