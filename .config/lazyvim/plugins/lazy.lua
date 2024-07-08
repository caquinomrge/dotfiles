-- Define the path to lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Bootstrap lazy.nvim if it's not already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- Prepend the lazy.nvim path to runtime path
vim.opt.rtp:prepend(lazypath)

-- Configure and setup lazy.nvim
require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "plugins" },
		{ "morhetz/gruvbox" }, -- Gruvbox colorscheme
		{ "altercation/vim-colors-solarized" }, -- Solarized colorscheme
		{ "shaunsingh/nord.nvim" }, -- Nord colorscheme
		{ "hashivim/vim-terraform" }, -- Terraform plugin
		{ "elzr/vim-json" }, -- JSON syntax highlighting
		{ "stephpy/vim-yaml" }, -- YAML syntax highlighting
		{ "vim-python/python-syntax" }, -- Python syntax highlighting
		{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }, -- Treesitter
		{ "neovim/nvim-lspconfig" }, -- LSP configurations
		{ "hrsh7th/nvim-cmp" }, -- Completion plugin
		{ "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
		{ "hrsh7th/cmp-buffer" }, -- Buffer completions
		{ "hrsh7th/cmp-path" }, -- Path completions
		{ "hrsh7th/cmp-cmdline" }, -- Cmdline completions
		{ "saadparwaiz1/cmp_luasnip" }, -- Snippet completions
		{ "L3MON4D3/LuaSnip" }, -- Snippet engine
		{ "rafamadriz/friendly-snippets" }, -- A bunch of snippets to use
		{ "lewis6991/gitsigns.nvim" }, -- Git signs plugin
	},
	defaults = {
		lazy = false, -- Load all custom plugins during startup
		version = false, -- Always use the latest git commit
	},
	install = { colorscheme = { "gruvbox", "solarized", "nord" } }, -- Default colorschemes
	checker = { enabled = true }, -- Automatically check for plugin updates
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Apply the colorscheme
vim.cmd("colorscheme gruvbox") -- Change this to 'solarized' or 'nord' if preferred

-- Apply custom highlight settings
vim.cmd([[
  highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=Black gui=NONE guifg=DarkGrey guibg=Black
]])

-- Enable Terraform filetype detection and syntax highlighting
vim.cmd([[
  let g:terraform_align = 1
  let g:terraform_fmt_on_save = 1
  autocmd BufRead,BufNewFile *.tf set filetype=terraform
  autocmd BufRead,BufNewFile *.tfvars set filetype=terraform
]])

-- Add custom key mappings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- Treesitter configuration
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
	highlight = { enable = true },
	indent = { enable = true },
	additional_vim_regex_highlighting = false,
})

-- Setup nvim-cmp.
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspconfig")["terraformls"].setup({
	capabilities = capabilities,
})

-- Configure gitsigns.nvim
require("gitsigns").setup({
	signs = {
		add = { hl = "GitGutterAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
		change = { hl = "GitGutterChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
		delete = { hl = "GitGutterDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		topdelete = {
			hl = "GitGutterDeleteChange",
			text = "‾",
			numhl = "GitSignsDeleteChangeNr",
			linehl = "GitSignsDeleteChangeLn",
		},
		changedelete = { hl = "GitGutterChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
	},
	numhl = false,
	linehl = false,
	word_diff = false,
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000, -- Disable if file is longer than this (in lines)
	preview_config = {
		-- Options passed to nvim_open_win
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	yadm = {
		enable = false,
	},
})
