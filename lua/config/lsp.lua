require("toolchain").setup()

local keys = {
	{
		"<leader>cl",
		function()
			require("sources.lsp").picker()
		end,
		desc = "Lsp Info",
	},
}

local function fzf(method)
	return function()
		require("fzf-lua")[method]()
	end
end

-- stylua: ignore
local attached_keys = {
	{ "gd", fzf("lsp_definitions"), desc = "Goto Definition" },
	{ "gr", fzf("lsp_references"), desc = "References" },
	{ "gI", fzf("lsp_implementations"), desc = "Goto Implementation" },
	{ "gy", fzf("lsp_typedefs"), desc = "Goto T[y]pe Definition" },
	{ "gD", fzf("lsp_declarations"), desc = "Goto Declaration" },
	{ "K", function() Utils.lsp.hover() end, desc = "Hover" },
	{ "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "x" }, desc = "Code Action" },
	{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
	{ "<leader>cR", function()
    local old = vim.api.nvim_buf_get_name(0)
    local new = vim.fn.input("Rename: ", old)

    if new ~= "" then
      vim.cmd("saveas " .. new)
      vim.fn.delete(old)
    end
  end, desc = "Rename File" },
	{ "<leader>ld", fzf("lsp_document_diagnostics"), desc = "LSP Open Diagnostic" },
	{ "<leader>co", Utils.lsp.action["source.organizeImports"], desc = "Organize Imports" },
	{ "gai", fzf("lsp_incoming_calls"), desc = "Calls Incoming" },
	{ "gao", fzf("lsp_outgoing_calls"), desc = "Calls Outgoing" },
	{ "<leader>ss", fzf("lsp_document_symbols"), desc = "LSP Symbols" },
	{ "<leader>sS", fzf("lsp_workspace_symbols"), desc = "LSP Workspace Symbols" },
}

Utils.keymap.add(keys)

local grp = vim.api.nvim_create_augroup("SetupLSP", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = grp,
	callback = function(event)
		local bufnr = event.buf
		local client = vim.lsp.get_clients({ id = event.data.client_id })[1]
		if not client then
			return
		end

		Utils.keymap.add(attached_keys)

		-- [signature help]
		if client:supports_method("textDocument/signatureHelp") then
      -- stylua: ignore
	Utils.keymap({"gK", function() return vim.lsp.buf.signature_help() end, buf = bufnr, desc = "Signature Help",})
		end

		-- [inlay hint]
		if client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			Utils.keymap({
				"<leader>uh",
				function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
				end,
				buffer = bufnr,
				desc = "LSP: Toggle Inlay Hints",
			})
		end

		-- [codelens]
		if client:supports_method("textDocument/codeLens") then
			vim.lsp.codelens.enable(true, { bufnr = bufnr })
			Utils.keymap({
				"<leader>cc",
				function()
					vim.lsp.codelens.run({ bufnr = bufnr })
				end,
				buffer = bufnr,
				desc = "Run Codelens",
			})
		end

		Utils.keymap({
			"<leader>cA",
			Utils.lsp.action.source,
			desc = "Source Action",
		})

		-- [folding]
		-- if client:supports_method("textDocument/foldingRange") then
		-- 	vim.opt_local.foldmethod = "expr"
		-- 	vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
		-- 	-- 可选：让 foldexpr 生效时更自然
		-- 	vim.opt_local.foldlevel = 99
		-- 	vim.opt_local.foldenable = true
		-- end

		if client:supports_method("textDocument/documentHighlight") then
			local hlg = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. bufnr, { clear = true })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = hlg,
				buffer = bufnr,
				callback = function()
					pcall(vim.lsp.buf.document_highlight)
				end,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
				group = hlg,
				buffer = bufnr,
				callback = function()
					pcall(vim.lsp.buf.clear_references)
				end,
			})
		end
	end,
})

vim.diagnostic.config({
	update_in_insert = false,
	underline = true,
	virtual_text = {
		spacing = 4,
		source = true,
		prefix = "●",
	},
	float = {
		severity_sort = true,
		source = true,
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticError",
			[vim.diagnostic.severity.WARN] = "DiagnosticWarning",
			[vim.diagnostic.severity.INFO] = "DiagnosticInfo",
			[vim.diagnostic.severity.HINT] = "DiagnosticHint",
		},
	},
})
