require("onedark").load()

require("onedark").setup({
	code_style = {
		comments = "none",
	},
	highlights = {
		-- ["@comment"] = { fg = "$light_grey" },
		-- ["@variable"] = { fg = "$red" },
	},
})

-- load the package again to get the custom config applied
require("onedark").load()


