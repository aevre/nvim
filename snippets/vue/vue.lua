local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local parse = ls.parser.parse_snippet

return {
	s("tem", {
		t('<script setup lang="'),
		i(1, "ts"),
		t('">'),
		t({ "", "", "</script>" }),
		t({ "", "", "<template>" }),
		t({ "", "", "</template>" }),
		t({ "", "", '<style lang="' }),
		i(2, "scss"),
		t('" scoped>'),
		t({ "", "", "</style>" }),
		i(0),
	}, { description = "Vue 3 Single File Component Template" }),
	parse(
		{ trig = "vprops", desc = "Typed props with defaults" },
		[[
const props = withDefaults(defineProps<{
	${1:title}?: ${2:string}
}>(), {
	${1}: ${3:''},
})
$0]]
	),
	parse(
		{ trig = "vmodel", desc = "Required typed model (Vue 3.4+)" },
		[[
const ${1:model} = defineModel<${2:string}>({ required: true })
$0]]
	),
	parse(
		{ trig = "vmodelNamed", desc = "Named required typed model (Vue 3.4+)" },
		[[
const ${1:visible} = defineModel<${2:boolean}>('${1}', { required: true })
$0]]
	),
	parse(
		{ trig = "vslots", desc = "Typed slots (Vue 3.3+)" },
		[[
defineSlots<{
	${1:default}(props: { ${2:item}: ${3:Item} }): any
}>()
$0]]
	),
	parse(
		{ trig = "vexpose", desc = "Expose component methods or state" },
		[[
defineExpose({ ${1:open} })
$0]]
	),
	parse(
		{ trig = "vwatchProp", desc = "Watch a prop through a getter" },
		[[
watch(() => props.${1:value}, (${2:value}, ${3:oldValue}) => {
	$0
})]]
	),
	parse(
		{ trig = "vwatchEffect", desc = "Watch effect with cleanup" },
		[[
watchEffect((onCleanup) => {
	${1:// Start the side effect}
	onCleanup(() => {
		${2:// Dispose the side effect}
	})
	$0
})]]
	),
	parse(
		{ trig = "vslot", desc = "Scoped slot template" },
		[[
<template #${1:default}="{ ${2:item} }">
	$0
</template>]]
	),
}
