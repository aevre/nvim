return { ---@type table<string, luma.ToolSpec|fun(ctx: luma.ToolContext)>
	ask = require("plugins.qol.luma.tools.ask"),
	attach = require("plugins.qol.luma.tools.attach"),
	explain = require("plugins.qol.luma.tools.explain"),
	translate = require("plugins.qol.luma.tools.translate"),
	word_translate = require("plugins.qol.luma.tools.word_translate"),
	tests = require("plugins.qol.luma.tools.tests"),
	rewrite = require("plugins.qol.luma.tools.rewrite"),
	commit = require("plugins.qol.luma.tools.commit"),
	bash = require("plugins.qol.luma.tools.bash"),
}
