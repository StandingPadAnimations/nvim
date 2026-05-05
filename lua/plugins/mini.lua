-- Mini is already installed by this point
--
-- We use Mini as much as possible because
-- it's more minimal to use, and it avoids
-- the issue of long start-up times. Yes, Mini
-- isn't as feature-filled as individual
-- plugins, but if I want to use Neovim,
-- not VSCode

Config.later(function()
	require("mini.ai").setup({ n_lines = 500 })
end)

Config.later(function()
	require("mini.surround").setup()
end)

Config.later(function()
	require("mini.pick").setup()
	vim.keymap.set("n", "<Leader>sh", "<Cmd>Pick help<CR>", { nowait = true, desc = "Search Help" })
	vim.keymap.set("n", "<Leader>sf", "<Cmd>Pick files<CR>", { nowait = true, desc = "Search Files" })
	vim.keymap.set("n", "<Leader>sg", "<Cmd>Pick grep_live<CR>", { nowait = true, desc = "Search Grep" })
	vim.keymap.set("n", "<Leader>sd", "<Cmd>Pick diagnostic<CR>", { nowait = true, desc = "Search Diagnostics" })
	vim.keymap.set("n", "<Leader>sb", "<Cmd>Pick buffers<CR>", { nowait = true, desc = "Search Buffers" })
	vim.keymap.set(
		"n",
		"<Leader>ss",
		'<Cmd>Pick lsp scope="document_symbol"<CR>',
		{ nowait = true, desc = "Search Symbols" }
	)
	vim.keymap.set(
		"n",
		"<Leader>sr",
		'<Cmd>Pick lsp scope="references"<CR>',
		{ nowait = true, desc = "Search References" }
	)
end)

Config.now(function()
	require("mini.icons").setup()
	Config.later(MiniIcons.mock_nvim_web_devicons)
	Config.later(MiniIcons.tweak_lsp_kind)
end)

Config.now(function()
	local predicate = function(notif)
		if not (notif.data.source == "lsp_progress" and notif.data.client_name == "lua_ls") then
			return true
		end
		-- Filter out some LSP progress notifications from 'lua_ls'
		return notif.msg:find("Diagnosing") == nil and notif.msg:find("semantic tokens") == nil
	end
	local custom_sort = function(notif_arr)
		return MiniNotify.default_sort(vim.tbl_filter(predicate, notif_arr))
	end

	require("mini.notify").setup({ content = { sort = custom_sort } })
end)

Config.later(function()
	require("mini.statusline").setup()
end)

Config.now_if_args(function()
	-- Don't show 'Text' suggestions
	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
	local process_items = function(items, base)
		return MiniCompletion.default_process_items(items, base, process_items_opts)
	end
	require("mini.completion").setup({
		lsp_completion = { source_func = "omnifunc", auto_setup = false, process_items = process_items },
	})

	-- Set up LSP part of completion
	local on_attach = function(args)
		vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
	end
	Config.new_autocmd("LspAttach", "*", on_attach)
	vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

Config.later(function()
	-- Define language patterns to work better with 'friendly-snippets'
	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
	local lang_patterns = {
		tex = latex_patterns,
		plaintex = latex_patterns,
		-- Recognize special injected language of markdown tree-sitter parser
		markdown_inline = { "markdown.json" },
	}

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")
	snippets.setup({
		snippets = {
			-- Always load 'snippets/global.json' from config directory
			snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
			-- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})
end)

Config.later(function()
	require("mini.extra").setup()
end)

Config.later(function()
	require("mini.git").setup()
end)
Config.later(function()
	require("mini.diff").setup()
end)

Config.later(function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack", "WARN", "Warn", "warn" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

Config.later(function()
	local jump2d = require("mini.jump2d")
	jump2d.setup({
		spotter = jump2d.gen_spotter.pattern("[^%s%p]+"),
		labels = "etovxqpdygfblzhckisuran",
		view = { dim = true, n_steps_ahead = 3 },
	})
	vim.keymap.set({ "n", "x", "o" }, "<Leader>hj", function()
		MiniJump2d.start(MiniJump2d.builtin_opts.word_start)
	end, { desc = "Jump to word" })
	vim.keymap.set({ "n", "x", "o" }, "<Leader>hg", function()
		MiniJump2d.start(MiniJump2d.builtin_opts.line_start)
	end, { desc = "Jump to line" })
end)

Config.later(function()
	local miniclue = require("mini.clue")
	miniclue.setup({
		clues = {
			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.square_brackets(),
			miniclue.gen_clues.windows({ submode_resize = true }),
			miniclue.gen_clues.z(),
		},
		triggers = {
			{ mode = { "n", "x" }, keys = "<Leader>" }, -- Leader triggers
			{ mode = "i", keys = "<C-x>" }, -- Built-in completion
			{ mode = { "n", "x" }, keys = "g" }, -- `g` key
			{ mode = { "n", "x" }, keys = "'" }, -- Marks
			{ mode = { "n", "x" }, keys = "`" },
			{ mode = { "n", "x" }, keys = '"' }, -- Registers
			{ mode = { "i", "c" }, keys = "<C-r>" },
			{ mode = { "n", "x" }, keys = "s" }, -- `s` key
			{ mode = { "n", "x" }, keys = "z" }, -- `z` key
		},
		window = {
			delay = 25,
		},
	})
end)
