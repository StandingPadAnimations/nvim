Config.later(function()
	vim.pack.add({
		Config.gh("NMAC427/guess-indent.nvim"),
	})

	require("guess-indent").setup()
end)

Config.now_if_args(function()
	vim.pack.add({
		Config.gh("stevearc/oil.nvim"),
	})
	require("oil").setup()
	vim.keymap.set("n", "<Leader>o", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
end)

Config.on_event("BufWritePre", function()
	vim.pack.add({
		Config.gh("stevearc/conform.nvim"),
	})

	vim.keymap.set("", "<Leader>f", function()
		require("conform").format({ async = true, lsp_format = "fallback" })
	end, { desc = "Format buffer" })

	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			typst = { "prettypst" },
		},
	})
end)
