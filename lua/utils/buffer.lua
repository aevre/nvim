---@class utils.buffer
local M = {}

---@class utils.buffer.Opts
---@field buf? integer Buffer to delete. Defaults to the current buffer
---@field file? string Delete buffer by file name. If provided, `buf` is ignored
---@field force? boolean Delete the buffer even if it is modified
---@field filter? fun(buf: integer): boolean Filter buffers to delete
---@field wipe? boolean Wipe the buffer instead of deleting it (see `:h :bwipeout`)

---@param opts? integer|utils.buffer.Opts
function M.delete(opts)
	opts = opts or {}
	opts = type(opts) == "number" and { buf = opts } or opts
	---@diagnostic disable-next-line: assign-type-mismatch
	opts = type(opts) == "function" and { filter = opts } or opts
	---@cast opts utils.buffer.Opts

	if type(opts.filter) == "function" then
		for _, b in ipairs(vim.tbl_filter(opts.filter, vim.api.nvim_list_bufs())) do
			if vim.bo[b].buflisted then
				M.delete(vim.tbl_extend("force", {}, opts, { buf = b, filter = false }))
			end
		end
		return
	end

	local buf = opts.buf or 0
	if opts.file then
		buf = vim.fn.bufnr(opts.file)
		if buf == -1 then
			return
		end
	end
	buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	-- Check if the buffer is modified
	if vim.bo[buf].modified and not opts.force then
		local ok, choice =
			pcall(vim.fn.confirm, ("Save changes to %q?"):format(vim.fn.bufname(buf)), "&Yes\n&No\n&Cancel")
		if not ok or choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
			return
		elseif choice == 1 then -- Yes
			vim.api.nvim_buf_call(buf, vim.cmd.write)
		end
	end

	-- Get the most recently used listed buffer that is not the one being deleted,
	local info = vim.fn.getbufinfo({ buflisted = 1 })
	---@param b vim.fn.getbufinfo.ret.item
	info = vim.tbl_filter(function(b)
		return b.bufnr ~= buf
	end, info)
	table.sort(info, function(a, b)
		return a.lastused > b.lastused
	end)

	local new_buf = info[1] and info[1].bufnr or vim.api.nvim_create_buf(true, false)

	-- replace the buffer in all windows showing it,
	-- trying to use the alternate buffer if possible
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		local win_buf = new_buf
		vim.api.nvim_win_call(win, function() -- Try using alternate buffer
			local alt = vim.fn.bufnr("#")
			win_buf = alt >= 0 and alt ~= buf and vim.bo[alt].buflisted and alt or win_buf
		end)
		vim.api.nvim_win_set_buf(win, win_buf)
	end

	if vim.api.nvim_buf_is_valid(buf) then
		local ei = vim.o.eventignore
		vim.o.eventignore = "DiagnosticChanged"
		---@diagnostic disable-next-line: param-type-mismatch
		pcall(vim.cmd, (opts.wipe and "bwipeout! " or "bdelete! ") .. buf)
		vim.o.eventignore = ei
	end
end

--- Delete all buffers
---@param opts? utils.buffer.Opts
function M.all(opts)
	return M.delete(vim.tbl_extend("force", {}, opts or {}, {
		filter = function()
			return true
		end,
	}))
end

--- Delete all buffers except the current one
---@param opts? utils.buffer.Opts
function M.other(opts)
	return M.delete(vim.tbl_extend("force", {}, opts or {}, {
		filter = function(b)
			return b ~= vim.api.nvim_get_current_buf()
		end,
	}))
end

--- Delete all invisible buffers
---@param opts? utils.buffer.Opts
function M.invisible(opts)
	return M.delete(vim.tbl_extend("force", {}, opts or {}, {
		filter = function(b)
			return vim.fn.bufwinnr(b) == -1
		end,
	}))
end

--- 获取所有已列出的缓冲区
---@return number[] 缓冲区编号列表
M.get_bufs = function()
	return vim.tbl_filter(function(bufnr)
		return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
	end, vim.api.nvim_list_bufs())
end

--- 获取当前缓冲区
---@deprecated Use vim.api.nvim_get_current_buf directly.
---@return number 当前缓冲区编号
M.get_current_buf = function()
	return vim.api.nvim_get_current_buf()
end

--- 检查缓冲区是否存在
---@deprecated Use vim.api.nvim_buf_is_valid directly.
---@param bufnr integer 缓冲区编号
---@return boolean 是否存在
M.buf_exists = function(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr)
end

--- 获取缓冲区名称
---@deprecated Use vim.api.nvim_buf_get_name directly.
---@param bufnr? integer 缓冲区编号，默认为当前缓冲区
---@return string 缓冲区名称
M.get_buf_name = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return vim.api.nvim_buf_get_name(bufnr)
end

return M
