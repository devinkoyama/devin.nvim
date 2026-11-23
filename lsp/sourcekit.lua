-- Swift (and C/C++/ObjC in Swift packages): types, completion, go-to-definition, rename.
-- Ships with Xcode / the Swift toolchain, so there's nothing to install.
-- SwiftPM packages work out of the box. For Xcode projects (.xcodeproj), run
-- `xcode-build-server config -scheme <Scheme> -project <Name>.xcodeproj` once
-- (brew install xcode-build-server) to generate buildServer.json, then build in Xcode.
return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift', 'objc', 'objcpp' },
  root_markers = { 'buildServer.json', 'Package.swift', 'compile_commands.json', '.git' },
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }, -- picks up new files
  },
}
