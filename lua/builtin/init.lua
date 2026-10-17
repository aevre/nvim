---@class builtin
---@field buf builtin.buf
local M = {}

setmetatable(M, {
	__index = function(t, k)
		t[k] = require("builtin." .. k)
		return rawget(t, k)
	end,
})

---@type builtin
_G.Builtin = M

function M.setup() end

return M
