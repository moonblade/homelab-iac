local modules = { 'config', 'keybindings', 'packages' }

for _, module in pairs(modules) do
  package.loaded[module] = nil
  require(module)
end
