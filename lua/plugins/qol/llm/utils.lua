local utils = {}

function utils.local_llm_streaming_handler(chunk, ctx, F)
	if not chunk then
		return ctx.assistant_output
	end
	local tail = chunk:sub(-1, -1)
	if tail:sub(1, 1) ~= "}" then
		ctx.line = ctx.line .. chunk
	else
		ctx.line = ctx.line .. chunk
		local status, data = pcall(vim.fn.json_decode, ctx.line)
		if not status or not (data.message or {}).content then
			return ctx.assistant_output
		end
		ctx.assistant_output = ctx.assistant_output .. ((data.message or {}).content or "")
		F.WriteContent(ctx.bufnr, ctx.winid, (data.message or {}).content)
		ctx.line = ""
	end
	return ctx.assistant_output
end

function utils.local_llm_parse_handler(chunk)
	local assistant_output = chunk.message.content
	return assistant_output
end

return utils
