-- Fill gaps in Neovim's built-in filename detection, including chezmoi names.
local names = {
	zsh = { ".zshrc", "zsrc", ".zshenv", ".zprofile", ".zlogin" },
	sh = { ".bashrc", ".bash_profile", ".profile", ".curlrc", "Procfile" },
	gitconfig = { ".gitconfig" },
	gitignore = { ".gitignore" },
	gitattributes = { ".gitattributes" },
	gitmodules = { ".gitmodules" },
	gitcommit = { ".gitmessage" },
	dosini = { ".editorconfig", ".npmrc", ".yarnrc" },
	yaml = { "Taskfile" },
}

local filename = {}
local function add(name, filetype)
	filename[name] = filetype
	filename[name .. ".tmpl"] = filetype
	local stem = name:gsub("^%.", "")
	for _, prefix in ipairs({
		"dot_",
		"private_dot_",
		"executable_",
		"executable_dot_",
		"private_",
		"private_executable_",
		"private_executable_dot_",
	}) do
		filename[prefix .. stem] = filetype
		filename[prefix .. stem .. ".tmpl"] = filetype
	end
end

for filetype, files in pairs(names) do
	for _, name in ipairs(files) do
		add(name, filetype)
	end
end

add("Brewfile", "ruby")

vim.filetype.add({
	filename = filename,
	pattern = {
		[".*%.example"] = function(path)
			return vim.filetype.match({ filename = path:sub(1, -9) })
		end,
	},
})
