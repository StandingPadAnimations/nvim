Config.later(function()
	vim.pack.add({
		Config.gh("akinsho/git-conflict.nvim"),
	})
	require("git-conflict").setup()
end)
