local function wait_for_port(host, port, timeout_ms, callback)
	local timer = vim.uv.new_timer()
	if not timer then
		callback(false)
		return
	end

	local interval = 200
	local max_attempts = math.floor(timeout_ms / interval)
	local attempts = 0

	timer:start(0, interval, function()
		attempts = attempts + 1

		local client = vim.uv.new_tcp()
		if not client then
			if attempts >= max_attempts then
				timer:stop()
				timer:close()
				vim.schedule(function()
					callback(false)
				end)
			end
			return
		end

		client:connect(host, port, function(err)
			client:close()
			if err == nil then
				timer:stop()
				timer:close()
				vim.schedule(function()
					callback(true)
				end)
			elseif attempts >= max_attempts then
				timer:stop()
				timer:close()
				vim.schedule(function()
					callback(false)
				end)
			end
		end)
	end)
end

Config.now_if_args(function()
	wait_for_port("127.0.0.1", 8012, 30000, function(running)
		if not running then
			return
		end

		vim.g.llama_config = {
			endpoint_fim = "http://127.0.0.1:8012/infill",
			endpoint_inst = "http://127.0.0.1:8012/v1/chat/completions",
			auto_fim = true,
			n_prefix = 128,
			n_suffix = 64,
			n_predict = 64,
			ring_n_chunks = 4,
			ring_chunk_size = 16,
			show_info = 0,
			keymap_fim_trigger = "",
			keymap_fim_accept_full = "",
			keymap_fim_accept_line = "",
		}
		vim.pack.add({ Config.gh("ggml-org/llama.vim") })

		local function accept_fim(mode)
			local expr = vim.fn["llama#fim_accept"](mode)
			if type(expr) == "string" and expr ~= "" then
				local keys = vim.api.nvim_replace_termcodes(expr, true, false, true)
				vim.api.nvim_feedkeys(keys, "n", false)
			end
		end

		vim.keymap.set("i", "<C-w>", function()
			accept_fim("full")
		end, { silent = true })
		vim.keymap.set("i", "<C-e>", function()
			accept_fim("line")
		end, { silent = true })
	end)
end)
