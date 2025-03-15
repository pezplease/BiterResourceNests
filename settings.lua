data:extend({
	{
		type = "bool-setting",
		name = "starting-resource-exemption",
		order = "a",
		setting_type = "startup",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "remove-normal-nests",
		order = "a1",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "add-resource-to-drop-table",
		order = "a2",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "double-setting",
		name = "resource-drop-rate",
		order = "a3",
		setting_type = "startup",
		default_value = 0.8,
		minimum_value = 0.001,
		maximum_value = 1,

	},
})