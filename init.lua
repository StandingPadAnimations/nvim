-- Define helper functions

_G.Config = {}

Config.gh = function(x)
	return "https://github.com/" .. x
end

-- Install Mini so we can use it throughout
vim.pack.add({
	Config.gh("nvim-mini/mini.nvim"),
})

-- Helpers for lazy loading
local misc = require("mini.misc")

Config.now = function(f)
	misc.safely("now", f)
end
Config.later = function(f)
	misc.safely("later", f)
end
Config.on_event = function(ev, f)
	misc.safely("event:" .. ev, f)
end
Config.on_filetype = function(ft, f)
	misc.safely("filetype:" .. ft, f)
end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later

-- Autocommand helper with custom autocommand group
local gr = vim.api.nvim_create_augroup("maryams-nvim-config", {})
Config.new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

-- Helper hook for plugin updates
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback()
	end
	Config.new_autocmd("PackChanged", "*", f, desc)
end

-- Load settings
Config.now(function() require("config.settings") end)

-- Load plugins
Config.now(function() require("plugins.mini") end)
Config.now(function() require("plugins.language_analysis") end)
Config.now(function() require("plugins.file") end)
Config.now(function() require("plugins.tabout") end)
Config.now(function() require("plugins.llama") end)
