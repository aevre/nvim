return { ---@type table<string, luma.ToolSpec|fun(ctx: luma.ToolContext)>
	ask = require("plugins.qol.luma.tools.ask"),
	attach = require("plugins.qol.luma.tools.attach"),
	explain = require("plugins.qol.luma.tools.explain"),
	document_buffer = require("plugins.qol.luma.tools.document").buffer,
	document_selection = require("plugins.qol.luma.tools.document").selection,
	translate = require("plugins.qol.luma.tools.translate"),
	word_translate = require("plugins.qol.luma.tools.word_translate"),
	tests = require("plugins.qol.luma.tools.tests"),
	rewrite = require("plugins.qol.luma.tools.rewrite"),
	commit = require("plugins.qol.luma.tools.commit"),
	bash = require("plugins.qol.luma.tools.bash"),
}
