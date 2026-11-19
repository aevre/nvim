---@type LazyPluginSpec
return {
	"heilgar/nvim-http-client",
	event = "VeryLazy",
	ft = { "http", "rest" },
	dependencies = { "nvim-lua/plenary.nvim" },
	init = function()
		vim.filetype.add({ extension = { http = "http", rest = "http" } })
	end,
	config = function()
		local http_client = require("http_client")
		http_client.setup({
			create_keybindings = false,
			default_env_file = "http-client.env.json",
		})

		-- The plugin only clears its active request on successful curl callbacks.
		local core = http_client.http_client
		local send_request = core.send_request
		rawset(core, "send_request", function(request)
			local curl = require("plenary.curl")
			local curl_request = curl.request
			curl.request = function(options)
				local on_error = options.on_error
				options.on_error = function(err)
					core.clear_current_request()
					if on_error then
						return on_error(err)
					end
					vim.schedule(function()
						vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
					end)
				end
				return curl_request(options)
			end

			local ok, result = pcall(send_request, request)
			curl.request = curl_request
			if not ok then
				error(result)
			end
			return result
		end)

		local parser = http_client.parser
		local parse_request = parser.parse_request
		rawset(parser, "parse_request", function(lines)
			local request_lines = vim.tbl_filter(function(line)
				return not line:match("^%s*@[%w_.-]+%s*=")
			end, lines)
			return parse_request(request_lines)
		end)

		local environment = http_client.environment
		local get_current_env = environment.get_current_env
		rawset(environment, "get_current_env", function()
			local variables = get_current_env()
			if vim.bo.filetype ~= "http" then
				return variables
			end
			for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
				local name, value = line:match("^%s*@([%w_.-]+)%s*=%s*(.-)%s*$")
				if name then
					variables[name] = value
				end
			end
			return vim.tbl_extend("force", variables, environment.get_global_variables())
		end)

		local completion = http_client.completion
		rawset(completion, "env_var_completion", function(findstart, base)
			local before_cursor = vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2])
			local start = before_cursor:find("{{[%w_.-]*$")
			if findstart == 1 then
				return start and start + 1 or -1
			end
			if not start then
				return {}
			end
			local items = {}
			for name, value in pairs(environment.get_current_env()) do
				if type(name) == "string" and name:sub(1, #base) == base then
					table.insert(items, {
						word = name,
						kind = "v",
						menu = "[HTTP variable]",
						info = tostring(value),
					})
				end
			end
			return items
		end)

		local function setup_completion()
			vim.bo.omnifunc = 'v:lua.require("http_client.completion").env_var_completion'
			vim.bo.completefunc = 'v:lua.require("http_client.completion").http_completion'
		end
		vim.api.nvim_create_autocmd("FileType", { pattern = "http", callback = setup_completion })
		if vim.bo.filetype == "http" then
			setup_completion()
		end

		-- Preserve repeated Set-Cookie headers before the plugin flattens them.
		local response_handler = require("http_client.core.response_handler")
		local execute_response_handler = response_handler.execute
		rawset(response_handler, "execute", function(script, response)
			local headers, cookies = {}, {}
			for key, value in pairs(response.headers or {}) do
				local name, cookie
				if type(key) == "number" and type(value) == "string" then
					name, cookie = value:match("^([^:]+):%s*(.*)")
				end
				if name and name:lower() == "set-cookie" then
					cookies[#cookies + 1] = cookie
				else
					headers[key] = value
				end
			end
			if #cookies > 0 then
				headers["set-cookie"] = table.concat(cookies, "\n")
			end
			local adapted = vim.tbl_extend("force", {}, response, { headers = headers })
			return execute_response_handler(script, adapted)
		end)

		local function load_buffer_env(buf)
			local path = vim.api.nvim_buf_get_name(buf)
			if path == "" then
				return
			end

			local env_file = vim.fs.find("http-client.env.json", {
				path = vim.fs.dirname(path),
				upward = true,
			})[1]
			if env_file then
				http_client.file_utils.set_project_root(vim.fs.dirname(env_file))
				http_client.environment.set_env_file(env_file)
			end
		end

		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("http_client_project_env", { clear = true }),
			pattern = { "*.http", "*.rest" },
			callback = function(args)
				load_buffer_env(args.buf)
			end,
		})
		load_buffer_env(vim.api.nvim_get_current_buf())
	end,
	keys = {
		{ "<leader>R", "", desc = "+Rest" },
		{ "<leader>Rc", "<cmd>HttpCopyCurl<cr>", desc = "Copy as cURL" },
		{ "<leader>Re", "<cmd>HttpEnv<cr>", desc = "Set environment" },
		{ "<leader>Rf", "<cmd>HttpEnvFile<cr>", desc = "Select environment file" },
		{ "<leader>Rp", "<cmd>HttpProfiling<cr>", desc = "Toggle profiling" },
		{ "<leader>Rs", "<cmd>HttpRun<cr>", desc = "Send the request" },
		{ "<leader>RS", "<cmd>HttpDryRun<cr>", desc = "Dry run request" },
		{ "<leader>Rq", "<cmd>HttpStop<cr>", desc = "Stop request" },
	},
}
