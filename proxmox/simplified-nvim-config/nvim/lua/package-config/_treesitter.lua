require("nvim-treesitter.install").compilers = { "clang" }

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"javascript",
		"typescript",
		"json",
		"toml",
		"yaml",
		"python",
		"java",
		"c_sharp",
		"c",
		"cpp",
		"rust",
		"go",
		"sql",
		"lua",
		"vim",
		"gitignore",
		"gitcommit",
		"git_rebase",
		"gitattributes",
    "terraform",
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})

vim.opt.foldenable = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
