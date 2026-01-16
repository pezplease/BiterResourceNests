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
		default_value = 1,
		minimum_value = 0.001,
		maximum_value = 1,

	},
	{
		type = "double-setting",
		name = mod_name .. "resource-drop-amount",
		order = "a4-2",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.01,
		maximum_value = 100,

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
		name = mod_name .. "projectile-chance",
		order = "a5-2",
		setting_type = "runtime-global",
		default_value = 0.15,
		minimum_value = 0.01,
		maximum_value = 0.99,
	},
	{
		type = "bool-setting",
		name = mod_name .. "disable-nest-projectile",
		order = "a5-3",
		setting_type = "runtime-global",
		default_value = false,
	},
	{
		type = "double-setting",
		name = mod_name .. "biter-health-multiplier",
		order = "a6",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.01,
		maximum_value = 15,
	},
		{
		type = "double-setting",
		name = mod_name .. "dormant-biter-spawn",
		order = "a7",
		setting_type = "startup",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 100,
	},
})
