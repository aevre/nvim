local parse = require("luasnip").parser.parse_snippet

return {
	parse(
		{ trig = "jrecord", desc = "Public record (Java 16+)" },
		[[
public record ${1:User}(${2:String name}) {
	$0
}]]
	),
	parse(
		{ trig = "jswitch", desc = "Switch expression (Java 14+)" },
		[[
${1:String} ${2:result} = switch (${3:value}) {
	case ${4:0} -> ${5:"zero"};
	default -> ${6:"other"};
};
$0]]
	),
	parse(
		{ trig = "joptional", desc = "Unwrap Optional or throw" },
		[[
${1:User} ${2:user} = ${3:optional}.orElseThrow(() -> new ${4:IllegalArgumentException}("${5:Not found}"));
$0]]
	),
	parse(
		{ trig = "jtest", desc = "JUnit 5 test method (Test import required)" },
		[[
@Test
void ${1:shouldWork}() {
	$0
}]]
	),
	parse(
		{ trig = "jparamtest", desc = "JUnit 5 CSV parameterized test (ParameterizedTest, CsvSource imports required)" },
		[[
@ParameterizedTest
@CsvSource({
	"${1:1, 2, 3}"
})
void ${2:shouldAdd}(${3:int left, int right, int expected}) {
	$0
}]]
	),
}
