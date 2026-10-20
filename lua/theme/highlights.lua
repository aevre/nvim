local M = {}

---@param palette theme.Palette
---@param transparent boolean
function M.setup(palette, transparent)
	local bg = transparent and "NONE" or palette.bg
	local bg_dim = transparent and "NONE" or palette.bg_dim
	local bg_deep = transparent and "NONE" or palette.bg_deep
	local bg_highlight = transparent and "NONE" or palette.bg_highlight

	local float_bg = transparent and "NONE" or palette.float.bg
	local float_border = palette.float.border

	local groups = {
		-----------------------------------------------------------------------
		-- Editor Core
		-----------------------------------------------------------------------
		Normal = { fg = palette.fg, bg = bg },
		NormalNC = { fg = palette.fg, bg = bg },
		NormalFloat = { fg = palette.float.fg, bg = float_bg },
		FloatBorder = { fg = float_border, bg = float_bg },
		FloatTitle = { fg = palette.primary_bright, bg = float_bg, bold = true },
		FloatFooter = { fg = palette.fg_muted, bg = float_bg },

		EndOfBuffer = { fg = palette.bg, bg = bg },
		SignColumn = { fg = palette.fg_gutter, bg = bg },
		Cursor = { fg = palette.bg, bg = palette.primary_bright },
		TermCursor = { fg = palette.bg, bg = palette.primary_bright },
		CursorLine = { bg = palette.cursor_line },
		CursorColumn = { bg = palette.cursor_line },

		LineNr = { fg = palette.fg_gutter, bg = bg },
		CursorLineNr = { fg = palette.primary_bright, bg = bg, bold = true },
		LineNrAbove = { fg = palette.fg_gutter },
		LineNrBelow = { fg = palette.fg_gutter },

		FoldColumn = { fg = palette.fg_gutter, bg = bg },
		Folded = { fg = palette.fg_muted, bg = bg_dim },

		WinSeparator = { fg = palette.border, bg = bg },
		VertSplit = { fg = palette.border, bg = bg },

		-----------------------------------------------------------------------
		-- UI Controls & Selection
		-----------------------------------------------------------------------
		Visual = { bg = palette.selection },
		VisualNOS = { bg = palette.selection },

		Search = { fg = palette.fg, bg = palette.bg_search },
		IncSearch = { fg = palette.bg, bg = palette.primary, bold = true },
		CurSearch = { link = "IncSearch" },

		MatchParen = { fg = palette.primary_bright, bg = palette.bg_highlight, bold = true },
		Directory = { fg = palette.primary, bold = true },
		Title = { fg = palette.primary_bright, bold = true },
		Question = { fg = palette.primary },
		MoreMsg = { fg = palette.primary },
		ModeMsg = { fg = palette.primary_bright, bold = true },
		WarningMsg = { fg = palette.diag.warn, bold = true },
		ErrorMsg = { fg = palette.diag.error, bold = true },

		SpecialKey = { fg = palette.fg_gutter },
		NonText = { fg = palette.fg_gutter },
		Whitespace = { fg = palette.fg_gutter },
		Conceal = { fg = palette.fg_muted },

		WildMenu = { fg = palette.fg, bg = palette.bg_highlight },

		-----------------------------------------------------------------------
		-- Popup Menu (Pmenu)
		-----------------------------------------------------------------------
		Pmenu = { fg = palette.fg, bg = bg_dim },
		PmenuSel = { fg = palette.primary_bright, bg = palette.selection, bold = true },
		PmenuSbar = { bg = palette.bg_highlight },
		PmenuThumb = { bg = palette.fg_muted },

		-----------------------------------------------------------------------
		-- Tabline / Statusline
		-----------------------------------------------------------------------
		StatusLine = { fg = palette.fg, bg = bg_dim },
		StatusLineNC = { fg = palette.fg_muted, bg = bg_deep },
		TabLine = { fg = palette.fg_muted, bg = bg_dim },
		TabLineFill = { bg = bg_deep },
		TabLineSel = { fg = palette.primary_bright, bg = bg_highlight, bold = true },

		WinBar = { fg = palette.rosewater, bg = bg },
		WinBarNC = { fg = palette.fg_muted, bg = bg },

		-----------------------------------------------------------------------
		-- Syntax Highlighting (Standard Vim Fallback)
		-----------------------------------------------------------------------
		Bold = { fg = palette.fg, bold = true },
		Italic = { fg = palette.fg, italic = true },
		Comment = { fg = palette.comment, italic = true },

		Constant = { fg = palette.peach },
		String = { fg = palette.green },
		Character = { fg = palette.teal },
		Number = { fg = palette.peach },
		Boolean = { fg = palette.peach, bold = true },
		Float = { fg = palette.peach },

		Identifier = { fg = palette.primary },
		Function = { fg = palette.blue, bold = true },
		Statement = { fg = palette.purple },
		Conditional = { fg = palette.purple, italic = true, bold = true },
		Repeat = { fg = palette.purple, italic = true, bold = true },
		Label = { fg = palette.sapphire },
		Operator = { fg = palette.sapphire },
		Keyword = { fg = palette.purple, italic = true },
		Exception = { fg = palette.maroon, bold = true },

		PreProc = { fg = palette.maroon },
		Include = { fg = palette.maroon, italic = true },
		Define = { fg = palette.maroon, bold = true },
		Macro = { fg = palette.purple },
		PreCondit = { fg = palette.maroon },

		Type = { fg = palette.yellow, bold = true },
		StorageClass = { fg = palette.yellow },
		Structure = { fg = palette.yellow },
		Typedef = { fg = palette.yellow, bold = true },

		Special = { fg = palette.primary_bright },
		SpecialComment = { fg = palette.comment },
		Delimiter = { fg = palette.fg_muted },

		Underlined = { underline = true },
		Todo = { fg = palette.bg, bg = palette.yellow, bold = true },

		-----------------------------------------------------------------------
		-- Diagnostics
		-----------------------------------------------------------------------
		DiagnosticError = { fg = palette.diag.error },
		DiagnosticWarn = { fg = palette.diag.warn },
		DiagnosticInfo = { fg = palette.diag.info },
		DiagnosticHint = { fg = palette.diag.hint },
		DiagnosticUnnecessary = { fg = palette.fg_gutter },

		DiagnosticUnderlineError = { undercurl = true, sp = palette.diag.error },
		DiagnosticUnderlineWarn = { undercurl = true, sp = palette.diag.warn },
		DiagnosticUnderlineInfo = { undercurl = true, sp = palette.diag.info },
		DiagnosticUnderlineHint = { undercurl = true, sp = palette.diag.hint },

		DiagnosticVirtualTextError = { fg = palette.diag.error, bg = palette.diag.bg_error },
		DiagnosticVirtualTextWarn = { fg = palette.diag.warn, bg = palette.diag.bg_warn },
		DiagnosticVirtualTextInfo = { fg = palette.diag.info, bg = palette.diag.bg_info },
		DiagnosticVirtualTextHint = { fg = palette.diag.hint, bg = palette.diag.bg_hint },

		-----------------------------------------------------------------------
		-- LSP
		-----------------------------------------------------------------------
		LspReferenceText = { bg = palette.bg_highlight },
		LspReferenceRead = { bg = palette.bg_highlight },
		LspReferenceWrite = { bg = palette.bg_highlight },
		LspSignatureActiveParameter = { fg = palette.primary_bright, bg = palette.bg_highlight, bold = true },
		LspCodeLens = { fg = palette.comment },
		LspInlayHint = { fg = palette.fg_gutter, bg = transparent and "NONE" or palette.bg_deep },

		-----------------------------------------------------------------------
		-- Diff & Git
		-----------------------------------------------------------------------
		DiffAdd = { bg = palette.diff.add },
		DiffChange = { bg = palette.diff.change },
		DiffDelete = { bg = palette.diff.delete },
		DiffText = { bg = palette.diff.text, bold = true },

		diffAdded = { fg = palette.git.add },
		diffRemoved = { fg = palette.git.delete },
		diffChanged = { fg = palette.git.change },

		-----------------------------------------------------------------------
		-- Misc & Health
		-----------------------------------------------------------------------
		helpCommand = { fg = palette.primary_bright, bg = palette.terminal_black },
		helpExample = { fg = palette.comment },
		qfFileName = { fg = palette.primary },
		qfLineNr = { fg = palette.fg_gutter },
		healthError = { fg = palette.diag.error },
		healthSuccess = { fg = palette.green },
		healthWarning = { fg = palette.diag.warn },
		debugPC = { bg = palette.bg_highlight },
		debugBreakpoint = { fg = palette.red, bg = palette.bg_highlight },
	}

	for name, opts in pairs(groups) do
		vim.api.nvim_set_hl(0, name, opts)
	end

	vim.g.terminal_color_1 = palette.git.delete
	vim.g.terminal_color_2 = palette.git.add
	vim.g.terminal_color_3 = palette.git.change
end

return M
