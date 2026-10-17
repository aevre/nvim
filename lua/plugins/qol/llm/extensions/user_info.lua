local tools = require("llm.tools")
-- check siliconflow's balance
return {
	handler = function()
		local key = os.getenv("SILICONFLOW_TOKEN")
		local res = tools.curl_request_handler(
			"https://api.siliconflow.cn/v1/user/info",
			{ "GET", "-H", string.format("'Authorization: Bearer %s'", key) }
		)
		if res ~= nil then
			print("balance: " .. res.data.balance)
		end
	end,
}
