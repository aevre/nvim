--- @type LazyPluginSpec[]
return {
	{
		"xheisenbugx/org.nvim",
		main = "org",
		lazy = false,
		opts = {
			org_directory = "~/Documents/org",
			agenda_files = { "~/Documents/org/**/*.org" },
			default_notes_file = "~/Documents/org/refile.org",
			log_done = "time",
			startup_folded = "overview",
			mappings = { prefix = "<leader>O" },
			capture = {
				templates = {
					t = { description = "Task", template = "* TODO %?\n  %U", target = "~/Documents/org/refile.org" },
				},
			},
		},
	},
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				per_filetype = { org = { inherit_defaults = true, "org" } },
				providers = { org = { name = "Org", module = "org.completion.blink" } },
			},
		},
	},
}
