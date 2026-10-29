local parse = require("luasnip").parser.parse_snippet

return {
	parse(
		{ trig = "err", desc = "Return an error" },
		[[
if err != nil {
	return ${1:err}
}
$0]]
	),
	parse(
		{ trig = "errw", desc = "Return an error with context (fmt)" },
		[[
if err != nil {
	return fmt.Errorf("${1:operation}: %w", err)
}
$0]]
	),
	parse(
		{ trig = "timeout", desc = "Context timeout with deferred cancellation (context, time)" },
		[[
${1:ctx}, ${2:cancel} := context.WithTimeout(${3:ctx}, ${4:5 * time.Second})
defer ${2}()
$0]]
	),
	parse(
		{ trig = "lock", desc = "Lock until the surrounding function returns" },
		[[
${1:mu}.Lock()
defer ${1}.Unlock()
$0]]
	),
	parse(
		{ trig = "iface", desc = "Compile-time pointer interface assertion" },
		[[
var _ ${1:Interface} = (*${2:Type})(nil)
$0]]
	),
	parse(
		{ trig = "subtest", desc = "Named subtest (testing)" },
		[[
t.Run("${1:case}", func(t *testing.T) {
	$0
})]]
	),
}
