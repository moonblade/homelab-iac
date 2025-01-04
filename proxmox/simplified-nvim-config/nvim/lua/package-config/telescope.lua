local resolve = require("telescope.config.resolve")
local builtin = require('telescope.builtin')

local fast_grep = function()
  builtin.live_grep({
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    search = "",
    only_sort_text = true,
    disable_coordinates = false
  })
end

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-o>"] = "select_default",
      },
      n = {
        ["<esc>"] = "close",
        ["o"] = "select_default",
      }
    },
    layout_config = {
      preview_width = resolve.resolve_width(0.5),
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--fixed-strings",
      "--no-ignore-vcs",
    }
  },
  pickers = {
    git_files = {
      show_untracked = true
    },
    find_files = {
      no_ignore = true
    },
    buffers = {
      sort_lastused = true,
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
  },
})
require("telescope").load_extension("fzy_native")

local project_files = function()
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require"telescope.builtin".git_files({})
  else
    require"telescope.builtin".find_files({})
  end
end

vim.keymap.set('n', '<C-p>', project_files, {})
vim.keymap.set('n', '<C-]>', builtin.find_files, {})
vim.keymap.set('n', '<C-f>', fast_grep, {})
vim.keymap.set('n', '<leader>l', builtin.buffers, {})

vim.keymap.set('n', 'gst', builtin.git_status, {})
vim.keymap.set('n', '<leader>b', builtin.git_branches, {})
