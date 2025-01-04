local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  print("Installing packer close and reopen Neovim...")
end

require("packer").startup({
  function()
    -- self manage packaging package
    use({
      "wbthomason/packer.nvim",
    })

    -- nvim tree
    -- use {
    --   'nvim-tree/nvim-tree.lua',
    --   requires = {
    --     'nvim-tree/nvim-web-devicons', -- optional
    --   },
    --   config = function()
    --     require("nvim-tree").setup()
    --   end
    -- }

    use 'kazhala/close-buffers.nvim'

    use {
      "numToStr/Comment.nvim",
      config = function()
          require("package-config.comment")
      end
    }

    use({
     "navarasu/onedark.nvim",
     config = function()
       require("package-config._onedark")
     end,
    })

    -- Status line at bottom for each buffer, lualine
    use({
      "nvim-lualine/lualine.nvim",
      requires = { "kyazdani42/nvim-web-devicons" },
      config = function()
        require("package-config.lualine")
      end,
    })

    -- Better tokenizing with treesitter
    -- use({
    --   "nvim-treesitter/nvim-treesitter",
    --   run = ":TSUpdate",
    --   config = function()
    --     require("package-config._treesitter")
    --   end,
    -- })

    -- Telescope
    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.4',
      -- 'nvim-telescope/telescope.nvim',
      requires = {
        {'nvim-lua/plenary.nvim'},
        { "nvim-telescope/telescope-fzy-native.nvim" },
      },
      config = function ()
        require("package-config.telescope")
      end
    }


  end,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
  },
})
