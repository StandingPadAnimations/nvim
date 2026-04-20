Config.now_if_args(function()
	-- Run update on package changes
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	vim.pack.add({
		Config.gh("nvim-treesitter/nvim-treesitter"),
	})

	local ensure_languages = {
		"bash",
		"diff",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
		"python",
		"gitcommit",
		"jjdescription",
		"typst",
		"c",
		"cpp",
		"gdscript",
		"godot_resource",
		"gdshader",
	}

	-- Get installed parsers
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Ensure enabled parsers
	-- are installed
	local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetypes,
		callback = ts_start,
	})
end)

Config.later(function()
	vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

Config.now_if_args(function()
	vim.pack.add({
		Config.gh("mason-org/mason.nvim"),
	})
	require("mason").setup()
end)

Config.now_if_args(function()
	vim.pack.add({
		Config.gh("neovim/nvim-lspconfig"),
	})

	vim.lsp.enable({
		"clangd", -- C and C++
		"basedpyright", -- Python
		"astro-language-server", -- Astro
		"gopls", -- Go
		"html-lsp", -- HTML
		"tinymist", -- Typst
		"rust-analyzer", -- Rust
		"gdscript", -- GDScript
	})
end)
