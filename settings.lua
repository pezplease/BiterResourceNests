local mod_name = "resource-nests-"


data:extend({
	{
		type = "bool-setting",
		name = mod_name .. "starting-resource-exemption",
		order = "a",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "bool-setting",
		name = mod_name .. "destroy-all-starting-nests",
		order = "a1",
		setting_type = "startup",
		default_value = false,
	},
	{
		type = "bool-setting",
		name = mod_name .. "remove-normal-nests",
		order = "a2",
		setting_type = "startup",
		default_value = false,
	},
	{
		type = "bool-setting",
		name = mod_name .. "add-resource-to-drop-table",
		order = "a3",
		setting_type = "startup",
		default_value = false,
	},
	{
		type = "double-setting",
		name = mod_name .. "resource-drop-rate",
		order = "a4",
		setting_type = "startup",
		default_value = 0.5,
		minimum_value = 0.001,
		maximum_value = 1,

	},
	{
		type = "double-setting",
		name = mod_name .. "nest-damage-taken-multiplier",
		order = "a5",
		setting_type = "runtime-global",
		default_value = 1,
		minimum_value = 0,
		maximum_value = 10,
	},
	{
		type = "double-setting",
		name = mod_name .. "biter-health-multiplier",
		order = "a6",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.1,
		maximum_value = 10,
	},
})
