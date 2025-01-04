local map = require("package-config.utils").map

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- Auto open nvimtree when startig
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd ":NvimTreeOpen"
    vim.cmd "wincmd p"
  end
})

-- Quit if nothing else is present
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      require('close_buffers').delete({ type = 'all', force = true })
      vim.cmd "quit"
    end
  end
})

map("n", "]", ":NvimTreeFindFile<CR>")
