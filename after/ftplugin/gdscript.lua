-- Create a breakpoint
vim.api.nvim_create_user_command("GodotBreakpoint", function()
	vim.cmd("normal! obreakpoint")
	vim.cmd("write")
end, {})
vim.keymap.set("n", "<leader>b", ":GodotBreakpoint<CR>", { desc = "Create breakpoint" })

-- delete all breakpoints in current file
vim.api.nvim_create_user_command("GodotDeleteBreakpoints", function()
	vim.cmd("g/breakpoint/d")
end, {})
vim.keymap.set("n", "<leader>BD", ":GodotDeleteBreakpoints<CR>", { desc = "Delete all breakpoints" })
