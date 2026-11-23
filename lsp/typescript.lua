-- TypeScript / JavaScript: types, completion, go-to-definition, rename.
-- Uses TypeScript 7's built-in native language server (`tsc --lsp`).
-- Install: npm i -g typescript
return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}
