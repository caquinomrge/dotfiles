-- treesitter.lua
require("lazy").setup({
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"elixir",
					"heex",
					"javascript",
					"html",
					"terraform",
					"python",
					"json",
					"yaml",
					"hcl",
				},
				sync_install = false,
				auto_install = true, -- Automatically install missing parsers when entering buffer
				ignore_install = {}, -- Specify parsers to ignore installing
				modules = {}, -- Additional modules configuration
				highlight = { enable = true },
				indent = { enable = true },
				additional_vim_regex_highlighting = false,
			})
		end,
	},
})

return {}
