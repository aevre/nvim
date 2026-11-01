---@class utils.lsp
local M = {}

local lsp_files = vim.fn.globpath(vim.fn.stdpath("config") .. "/lsp", "*.lua", false, true)
M.get_lsp_names = function()
	local lsp_names = {}
	for _, file in ipairs(lsp_files) do
		-- 从路径中提取不带后缀的名字
		local name = vim.fn.fnamemodify(file, ":t:r")
		if name ~= "" then
			table.insert(lsp_names, name)
		end
	end
	return lsp_names
end

---@param ignored_lsps? string[]
M.enable_lsps = function(ignored_lsps)
	local disabled = {}

	for _, name in ipairs(ignored_lsps or {}) do
		disabled[name] = true
	end

	for _, name in ipairs(M.get_lsp_names()) do
		if not disabled[name] then
			vim.lsp.enable(name)
		end
	end
end

local hover_ns = vim.api.nvim_create_namespace("hover")

---@param config? table
M.hover = function(config)
	config = config or {}
	config = vim.tbl_deep_extend("force", {
		border = "rounded",
		focus_id = "textDocument/hover",
		max_width = 80,
		max_height = 20,
		-- close_events = { "CursorMoved", "InsertEnter", "BufHidden", "WinScrolled" },
	}, config)

	vim.lsp.buf_request_all(0, "textDocument/hover", function(client)
		return vim.lsp.util.make_position_params(nil, client.offset_encoding)
	end, function(results, context)
		local bufnr = assert(context.bufnr)
		if vim.api.nvim_get_current_buf() ~= bufnr then
			return
		end

		local filtered = {}
		for client_id, resp in pairs(results) do
			local err, result = resp.err, resp.result
			if err then
				Utils.log.error((err.code or "") .. (err.message or ""))
			elseif result then
				filtered[client_id] = result
			end
		end

		if next(filtered) == nil then
			if config.silent ~= true then
				Utils.log.info("No information available", { title = "Lsp Hover" })
			end
			return
		end

		vim.api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)

		local contents = {}
		local nresults = #vim.tbl_keys(filtered)
		local format = "markdown"

		for client_id, result in pairs(filtered) do
			local client = assert(vim.lsp.get_clients({ id = client_id })[1])
			if nresults > 1 then
				contents[#contents + 1] = string.format("# %s", client.name)
			end

			if type(result.contents) == "table" and result.contents.kind == "plaintext" then
				if nresults == 1 then
					format = "plaintext"
					contents = vim.split(result.contents.value or "", "\n", { trimempty = true })
				else
					contents[#contents + 1] = "```"
					vim.list_extend(contents, vim.split(result.contents.value or "", "\n", { trimempty = true }))
					contents[#contents + 1] = "```"
				end
			else
				vim.list_extend(contents, vim.lsp.util.convert_input_to_markdown_lines(result.contents))
			end

			if result.range then
				local range = vim.range.lsp(bufnr, result.range, client.offset_encoding)
				vim.hl.range(
					bufnr,
					hover_ns,
					"LspReferenceTarget",
					{ range.start_row, range.start_col },
					{ range.end_row, range.end_col },
					{ priority = vim.hl.priorities.user }
				)
			end

			contents[#contents + 1] = "---"
		end
		contents[#contents] = nil

		if next(contents) == nil then
			if config.silent ~= true then
				Utils.log.info("No information available", { title = "Lsp Hover" })
			end
			return
		end

		local _, winid = vim.lsp.util.open_floating_preview(contents, format, config)

		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = tostring(winid),
			once = true,
			callback = function()
				vim.api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)
			end,
		})
	end)
end

M.action = setmetatable({}, {
	__index = function(_, action)
		return function()
			vim.lsp.buf.code_action({ apply = true, context = { only = { action }, diagnostics = {} } })
		end
	end,
})

M.insert_package_json = function(root_files, field, fname)
	return M.root_markers_with_field(root_files, { "package.json", "package.json5" }, field, fname)
end

--- @param root_files string[] List of root-marker files to append to.
--- @param new_names string[] Potential root-marker filenames (e.g. `{ 'package.json', 'package.json5' }`) to inspect for the given `field`.
--- @param field string Field to search for in the given `new_names` files.
--- @param fname string Full path of the current buffer name to start searching upwards from.
M.root_markers_with_field = function(root_files, new_names, field, fname)
	local path = vim.fn.fnamemodify(fname, ":h")
	local found = vim.fs.find(new_names, { path = path, upward = true, type = "file" })

	for _, f in ipairs(found or {}) do
		-- Match the given `field`.
		local file = assert(io.open(f, "r"))
		for line in file:lines() do
			if line:find(field, 1, true) then
				root_files[#root_files + 1] = vim.fs.basename(f)
				break
			end
		end
		file:close()
	end

	return root_files
end

return M
