vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-dap")
local dap = require("dap")
local ctx = require("toolchain.debug.context")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp .. "/node_modules/jest/bin", "p")
vim.fn.writefile({ "{}" }, tmp .. "/package.json")
vim.fn.writefile({ "" }, tmp .. "/node_modules/jest/bin/jest.js")
vim.cmd.edit(tmp .. "/sample.test.js")

local input, arguments, command = ctx.input, ctx.arguments, ctx.command
ctx.command = function(name)
	return name
end
ctx.input = function()
	return "suite.*test"
end
local jest = require("toolchain.debug.jest").configuration(true)()
assert(jest.program == tmp .. "/node_modules/jest/bin/jest.js")
assert(jest.args[4] == tmp .. "/sample.test.js")
assert(jest.args[6] == "suite.*test")
ctx.input = function()
	return dap.ABORT
end
assert(require("toolchain.debug.jest").configuration(true)().program == dap.ABORT)

local system, select = vim.system, vim.ui.select
ctx.input = function()
	return tmp
end
ctx.arguments = function()
	return { "-C", "Debug" }
end
vim.system = function(cmd, _, callback)
	assert(cmd[1] == "ctest" and cmd[6] == "Debug")
	callback({
		code = 0,
		stdout = vim.json.encode({
			tests = {
				{
					name = "case",
					command = { "/bin/test", "a*b", "two words" },
					properties = {
						{ name = "WORKING_DIRECTORY", value = tmp },
					},
				},
			},
		}),
	})
end
vim.ui.select = function(items, _, callback)
	callback(items[1])
end
local ctest
local co = coroutine.create(function()
	ctest = require("toolchain.debug.ctest").configuration()()
end)
assert(coroutine.resume(co))
assert(vim.wait(2000, function()
	return coroutine.status(co) == "dead"
end))
assert(ctest and ctest.program == "/bin/test")
assert(ctest.args[1] == "a*b" and ctest.args[2] == "two words" and ctest.cwd == tmp)
vim.system, vim.ui.select = system, select
ctx.input, ctx.arguments, ctx.command = input, arguments, command

local rpc, env = vim.lsp.rpc.start, vim.env.JDTLS_JVM_ARGS
local starts = {}
vim.lsp.rpc.start = function(cmd)
	starts[#starts + 1] = cmd
	return {}
end
vim.env.JDTLS_JVM_ARGS = "-Xmx2g -Dfoo=bar"
local java = dofile("lsp/jdtls.lua")
java.cmd({}, { root_dir = tmp .. "/one/app" })
java.cmd({}, { root_dir = tmp .. "/two/app" })
assert(starts[1][4] == "--jvm-arg=-Xmx2g")
assert(starts[1][7] ~= starts[2][7])
vim.fn.delete(starts[1][7], "rf")
vim.fn.delete(starts[2][7], "rf")
vim.lsp.rpc.start, vim.env.JDTLS_JVM_ARGS = rpc, env

_G.Utils = { log = { info = function() end, error = error } }
local rust = dofile("lsp/rust_analyzer.lua")
rust.before_init({}, {})
local launched, run = nil, dap.run
dap.run = function(config)
	launched = config
end
vim.system = function(cmd, opts, callback)
	assert(cmd[2] == "test" and vim.list_contains(cmd, "--no-run"))
	assert(vim.list_contains(cmd, "--message-format=json") and vim.list_contains(cmd, "feature"))
	assert(opts.cwd == tmp)
	callback({
		code = 0,
		stdout = vim.json.encode({
			reason = "compiler-artifact",
			executable = "/tmp/test-bin",
			target = { kind = { "test" } },
			profile = { test = true },
		}) .. "\n",
	})
end
local args = {
	cargoArgs = { "test" },
	cargoExtraArgs = { "--features", "feature" },
	executableArgs = { "selected", "--exact" },
	cwd = tmp,
	environment = { FOO = "bar" },
}
vim.lsp.commands["rust-analyzer.debugSingle"]({ arguments = { { args = args } } })
assert(vim.wait(2000, function()
	return launched ~= nil
end))
assert(launched.type == "gdb" and launched.program == "/tmp/test-bin")
assert(launched.args[1] == "selected" and launched.env.FOO == "bar")
assert(#args.cargoArgs == 1)
launched = nil
vim.system = function(cmd, _, callback)
	assert(cmd[2] == "build")
	callback({
		code = 0,
		stdout = vim.json.encode({
			reason = "compiler-artifact",
			executable = "/tmp/example-bin",
			target = { kind = { "example" } },
			profile = { test = false },
		}) .. "\n",
	})
end
vim.lsp.commands["rust-analyzer.debugSingle"]({
	arguments = { { args = {
		cargoArgs = { "run", "--example", "demo" },
		cwd = tmp,
	} } },
})
assert(vim.wait(2000, function()
	return launched ~= nil
end))
assert(launched.program == "/tmp/example-bin")
vim.system, dap.run = system, run

local _, configs = require("toolchain.debug").resolve(require("toolchain.lang").get())
local callable = false
for _, config in ipairs(configs.c) do
	if config.name == "Debug CTest test" then
		callable = type(getmetatable(config).__call) == "function"
	end
end
assert(callable)
vim.fn.delete(tmp, "rf")
print("language debug checks passed")
