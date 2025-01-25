{ config, pkgs, ... }:

let
  # Shared Neovim configuration
  neovimConfig = pkgs.writeTextDir ".config/nvim/init.lua" ''
    -- Neovim Lua configuration

    -- Set up Packer as the plugin manager
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

    if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      })
      vim.cmd([[packadd packer.nvim]])
    end

    require("packer").startup(function(use)
      -- Packer can manage itself
      use("wbthomason/packer.nvim")

      -- Install OneDark theme
      use({
        "navarasu/onedark.nvim",
        config = function()
          require("onedark").setup {
            style = "darker", -- Available styles: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
          }
          require("onedark").load()
        end,
      })

      -- Additional plugins can be added here
    end)

    -- Basic Neovim settings
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.autoindent = true
    vim.opt.smartindent = true

    -- Remap 'jk' to escape insert and command modes
    vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("c", "jk", "<Esc>", { noremap = true, silent = true })
  '';
in
{
  # Install Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Neovim configuration for the 'moonblade' user
  # users.users.moonblade = {
  #   home = "/home/moonblade";
  #   shell = pkgs.zsh; # Optional: Set Zsh as the shell
  #   packages = [ pkgs.neovim ]; # Ensure Neovim is available for this user
  #   dotfiles = neovimConfig;
  # };

  # Neovim configuration for the 'root' user
  # users.users.root = {
  #   packages = [ pkgs.neovim ]; # Ensure Neovim is available for the root user
  #   dotfiles = neovimConfig;
  # };
}

