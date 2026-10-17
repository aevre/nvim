---@type LazyPluginSpec
local im_switch_win = {
	"aevre/ime_toggle",
	event = "InsertEnter",
	opts = {},
}

local function find_im_command()
	local commands = {
		"fcitx5-remote", -- 优先检测 fcitx5
		"fcitx-remote", -- 其次检测 fcitx
		"ibus", -- 最后检测 ibus
	}

	for _, cmd in ipairs(commands) do
		if vim.fn.executable(cmd) == 1 then
			return cmd -- 找到第一个可执行的就返回
		end
	end

	-- 如果都没有找到，可以返回一个默认值或者给出警告
	Utils.log.warn(
		"未找到支持的输入法切换命令 (fcitx5-remote, fcitx-remote, ibus)。请检查输入法配置。"
	)
	return "fcitx5-remote" -- 或者返回一个你认为安全的默认值，比如 "ibus"
end

---@type LazyPluginSpec
local im_switch = {
	"keaising/im-select.nvim",
	event = "InsertEnter",
	config = function()
		local default_im_cmd = find_im_command()
		if not default_im_cmd then
			require("utils").log.error(
				"im-select.nvim 未能自动配置输入法切换命令。请手动检查并设置。"
			)
			return
		end

		-- 如果找到了默认的 IM 命令，配置 IM 切换
		require("im_select").setup({
			default_command = default_im_cmd, -- 使用自动检测到的命令
			default_im_select = "keyboard-us",
			set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
			set_previous_events = { "InsertEnter" },
			keep_quiet_on_no_binary = false,
			async_switch_im = true,
		})
	end,
}

if Utils.is_win() then
	return im_switch_win
else
	return im_switch
end
