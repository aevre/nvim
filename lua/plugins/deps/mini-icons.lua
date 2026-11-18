-- Mini Icons
---@type LazyPluginSpec
return {
	"nvim-mini/mini.icons",
	lazy = true,
	opts = {
		style = "glyph",

		-- 文件图标配置
		file = {
			-- 文档文件
			README = { glyph = "󰈙", hl = "MiniIconsYellow" },
			["README.md"] = { glyph = "󰈙", hl = "MiniIconsYellow" },
			["README.txt"] = { glyph = "󰈙", hl = "MiniIconsYellow" },
			["CHANGELOG.md"] = { glyph = "󰊪", hl = "MiniIconsPurple" },
			["LICENSE"] = { glyph = "󰈚", hl = "MiniIconsYellow" },
			["LICENSE.md"] = { glyph = "󰈚", hl = "MiniIconsYellow" },
			["COPYING"] = { glyph = "󰈚", hl = "MiniIconsYellow" },

			-- 配置文件
			[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
			[".env"] = { glyph = "", hl = "MiniIconsYellow" },
			[".env.example"] = { glyph = "", hl = "MiniIconsYellow" },
			[".env.local"] = { glyph = "", hl = "MiniIconsYellow" },
			[".gitignore"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
			[".gitattributes"] = { glyph = "󰊢", hl = "MiniIconsGrey" },

			-- Node.js/JavaScript 生态
			[".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			[".eslintrc.json"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			[".eslintrc.yml"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			["eslint.config.mjs"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			[".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
			[".prettierrc.json"] = { glyph = "", hl = "MiniIconsPurple" },
			[".prettierrc.yml"] = { glyph = "", hl = "MiniIconsPurple" },
			[".prettierrc.js"] = { glyph = "", hl = "MiniIconsPurple" },
			[".prettierrc.config.js"] = { glyph = "", hl = "MiniIconsPurple" },
			["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
			["package-lock.json"] = { glyph = "", hl = "MiniIconsGreen" },
			["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
			[".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
			[".yarnrc"] = { glyph = "", hl = "MiniIconsBlue" },
			["pnpm-lock.yaml"] = { glyph = "", hl = "MiniIconsYellow" },
			[".npmrc"] = { glyph = "", hl = "MiniIconsRed" },
			[".nvmrc"] = { glyph = "", hl = "MiniIconsGreen" },
			[".node-version"] = { glyph = "", hl = "MiniIconsGreen" },

			-- TypeScript
			["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["tsconfig.base.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["tsconfig.spec.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["jsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },

			-- Go 生态
			[".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
			["go.mod"] = { glyph = "", hl = "MiniIconsBlue" },
			["go.sum"] = { glyph = "", hl = "MiniIconsBlue" },
			["go.work"] = { glyph = "", hl = "MiniIconsBlue" },
			["go.work.sum"] = { glyph = "", hl = "MiniIconsBlue" },

			-- Rust 生态
			["Cargo.toml"] = { glyph = "", hl = "MiniIconsOrange" },
			["Cargo.lock"] = { glyph = "", hl = "MiniIconsOrange" },
			["rust-toolchain.toml"] = { glyph = "", hl = "MiniIconsOrange" },

			-- Python 生态
			["requirements.txt"] = { glyph = "", hl = "MiniIconsBlue" },
			["requirements-dev.txt"] = { glyph = "", hl = "MiniIconsBlue" },
			["pyproject.toml"] = { glyph = "", hl = "MiniIconsBlue" },
			["Pipfile"] = { glyph = "", hl = "MiniIconsBlue" },
			["Pipfile.lock"] = { glyph = "", hl = "MiniIconsBlue" },
			["poetry.lock"] = { glyph = "", hl = "MiniIconsBlue" },
			["setup.py"] = { glyph = "", hl = "MiniIconsBlue" },
			["setup.cfg"] = { glyph = "", hl = "MiniIconsBlue" },
			["tox.ini"] = { glyph = "", hl = "MiniIconsBlue" },

			-- 容器和部署
			["Dockerfile"] = { glyph = "󰡨", hl = "MiniIconsBlue" },
			["docker-compose.yml"] = { glyph = "󰡨", hl = "MiniIconsBlue" },
			["docker-compose.yaml"] = { glyph = "󰡨", hl = "MiniIconsBlue" },
			[".dockerignore"] = { glyph = "󰡨", hl = "MiniIconsBlue" },
			["k8s.yml"] = { glyph = "󰠚", hl = "MiniIconsBlue" },
			["k8s.yaml"] = { glyph = "󰠚", hl = "MiniIconsBlue" },
			["deployment.yml"] = { glyph = "󰠚", hl = "MiniIconsBlue" },
			["deployment.yaml"] = { glyph = "󰠚", hl = "MiniIconsBlue" },

			-- CI/CD
			[".github"] = { glyph = "󰊤", hl = "MiniIconsGrey" },
			[".gitlab-ci.yml"] = { glyph = "󰮠", hl = "MiniIconsOrange" },
			[".travis.yml"] = { glyph = "󰂺", hl = "MiniIconsRed" },
			["Jenkinsfile"] = { glyph = "", hl = "MiniIconsBlue" },
			["azure-pipelines.yml"] = { glyph = "󰿅", hl = "MiniIconsBlue" },

			-- 数据库
			["schema.sql"] = { glyph = "", hl = "MiniIconsBlue" },
			["migrations"] = { glyph = "", hl = "MiniIconsBlue" },
			["seed.sql"] = { glyph = "", hl = "MiniIconsBlue" },

			-- 配置文件
			["config.yml"] = { glyph = "", hl = "MiniIconsPurple" },
			["config.yaml"] = { glyph = "", hl = "MiniIconsPurple" },
			["config.json"] = { glyph = "", hl = "MiniIconsPurple" },
			["settings.json"] = { glyph = "", hl = "MiniIconsPurple" },
			["settings.yml"] = { glyph = "", hl = "MiniIconsPurple" },
			["settings.yaml"] = { glyph = "", hl = "MiniIconsPurple" },

			-- 开发工具
			["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["Makefile"] = { glyph = "", hl = "MiniIconsYellow" },
			["CMakeLists.txt"] = { glyph = "", hl = "MiniIconsYellow" },
			["meson.build"] = { glyph = "", hl = "MiniIconsYellow" },
			["build.gradle"] = { glyph = "", hl = "MiniIconsBlue" },
			["build.gradle.kts"] = { glyph = "", hl = "MiniIconsBlue" },
			["pom.xml"] = { glyph = "", hl = "MiniIconsBlue" },

			-- 测试文件
			["test"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			["tests"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			["__tests__"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			["spec"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			[".spec"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			["_test"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
			[".test"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
		},

		-- 文件类型图标配置
		filetype = {
			-- 配置文件类型
			dotenv = { glyph = "", hl = "MiniIconsYellow" },
			toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
			yaml = { glyph = "", hl = "MiniIconsAzure" },
			yml = { glyph = "", hl = "MiniIconsAzure" },
			json = { glyph = "󰘦", hl = "MiniIconsYellow" },
			jsonc = { glyph = "󰘦", hl = "MiniIconsYellow" },
			ini = { glyph = "󰘦", hl = "MiniIconsYellow" },
			conf = { glyph = "󰘦", hl = "MiniIconsYellow" },
			cfg = { glyph = "󰘦", hl = "MiniIconsYellow" },

			-- 脚本语言
			bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
			sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
			zsh = { glyph = "󱆃", hl = "MiniIconsGrey" },
			fish = { glyph = "󱆃", hl = "MiniIconsGrey" },
			powershell = { glyph = "󰨊", hl = "MiniIconsBlue" },
			ps1 = { glyph = "󰨊", hl = "MiniIconsBlue" },

			-- 编程语言
			lua = { glyph = "󰢱", hl = "MiniIconsBlue" },
			python = { glyph = "", hl = "MiniIconsBlue" },
			javascript = { glyph = "󰌞", hl = "MiniIconsYellow" },
			javascriptreact = { glyph = "󰜈", hl = "MiniIconsBlue" },
			typescript = { glyph = "󰛦", hl = "MiniIconsAzure" },
			typescriptreact = { glyph = "󰜈", hl = "MiniIconsBlue" },
			go = { glyph = "", hl = "MiniIconsBlue" },
			rust = { glyph = "", hl = "MiniIconsOrange" },
			java = { glyph = "", hl = "MiniIconsRed" },
			kotlin = { glyph = "", hl = "MiniIconsPurple" },
			scala = { glyph = "", hl = "MiniIconsRed" },
			c = { glyph = "", hl = "MiniIconsBlue" },
			cpp = { glyph = "", hl = "MiniIconsBlue" },
			cs = { glyph = "󰌛", hl = "MiniIconsBlue" },
			php = { glyph = "", hl = "MiniIconsPurple" },
			ruby = { glyph = "", hl = "MiniIconsRed" },
			dart = { glyph = "", hl = "MiniIconsBlue" },
			swift = { glyph = "󰛥", hl = "MiniIconsOrange" },
			haskell = { glyph = "󰲒", hl = "MiniIconsPurple" },

			-- Web 技术
			html = { glyph = "󰌝", hl = "MiniIconsOrange" },
			htmldjango = { glyph = "󰌝", hl = "MiniIconsOrange" },
			css = { glyph = "󰌪", hl = "MiniIconsBlue" },
			scss = { glyph = "󰌪", hl = "MiniIconsPurple" },
			sass = { glyph = "󰌪", hl = "MiniIconsPurple" },
			less = { glyph = "󰌪", hl = "MiniIconsBlue" },
			stylus = { glyph = "󰌪", hl = "MiniIconsGreen" },
			vue = { glyph = "󰡄", hl = "MiniIconsGreen" },
			svelte = { glyph = "󰛺", hl = "MiniIconsOrange" },

			-- 数据格式
			xml = { glyph = "󰗀", hl = "MiniIconsOrange" },
			sql = { glyph = "", hl = "MiniIconsBlue" },
			csv = { glyph = "󰈮", hl = "MiniIconsBlue" },

			-- 文档
			markdown = { glyph = "󰍔", hl = "MiniIconsYellow" },
			tex = { glyph = "󰙩", hl = "MiniIconsBlue" },
			rst = { glyph = "󰍔", hl = "MiniIconsYellow" },

			-- 版本控制
			gitcommit = { glyph = "󰊢", hl = "MiniIconsGrey" },
			gitconfig = { glyph = "󰊢", hl = "MiniIconsGrey" },
			gitrebase = { glyph = "󰊢", hl = "MiniIconsGrey" },

			-- 其他
			dockerfile = { glyph = "󰡨", hl = "MiniIconsBlue" },
			make = { glyph = "", hl = "MiniIconsYellow" },
			cmake = { glyph = "", hl = "MiniIconsYellow" },
			vim = { glyph = "", hl = "MiniIconsGreen" },
			help = { glyph = "", hl = "MiniIconsGreen" },

			-- 模板
			gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
			mustache = { glyph = "󰟓", hl = "MiniIconsGrey" },
			handlebars = { glyph = "󰟓", hl = "MiniIconsGrey" },
			erb = { glyph = "󰟓", hl = "MiniIconsGrey" },
			ejs = { glyph = "󰟓", hl = "MiniIconsGrey" },
			hbs = { glyph = "󰟓", hl = "MiniIconsGrey" },

			-- 配置和工具
			terraform = { glyph = "󰁁", hl = "MiniIconsPurple" },
			tf = { glyph = "󰁁", hl = "MiniIconsPurple" },
			tfvars = { glyph = "󰁁", hl = "MiniIconsPurple" },
			hcl = { glyph = "󰁁", hl = "MiniIconsPurple" },
			nix = { glyph = "󱄅", hl = "MiniIconsBlue" },
		},

		lsp = {
			["function"] = { glyph = "󰊕" },
			codeium = { glyph = "󰚩", hl = "MiniIconsPurple" },
			copilot = { glyph = "󰚩", hl = "MiniIconsPurple" },
			minuet = { glyph = "󰚩", hl = "MiniIconsPurple" },
			variable = { glyph = "󰫧" },
			method = { glyph = "󰡱" },
			snippet = { glyph = "󰲋" },
			field = { glyph = "󱈢" },
			module = { glyph = "󰏗" },
			constructor = { glyph = "" },
			class = { glyph = "󰠱" },
			interface = { glyph = "" },
			text = { glyph = "󰉿" },
			property = { glyph = "󰜢" },
			unit = { glyph = "󰑭" },
			value = { glyph = "󰎠" },
			enum = { glyph = "" },
			keyword = { glyph = "󰌋" },
			file = { glyph = "󰈙" },
			reference = { glyph = "󰈇" },
			folder = { glyph = "󰉋" },
			EnumMember = { glyph = "" },
			constant = { glyph = "󰏿" },
			struct = { glyph = "󰙅" },
			event = { glyph = "" },
			operator = { glyph = "󰆕" },
			TypeParameter = { glyph = "" },
		},
	},
	config = function(_, opts)
		require("mini.icons").mock_nvim_web_devicons()
		require("mini.icons").setup(opts)
	end,
}
