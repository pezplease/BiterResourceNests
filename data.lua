local resource_types = {
  "iron-ore",
  "copper-ore",
  "coal",
  "stone",
  "uranium-ore",
  "crude-oil"
}


--[[
local fireArmor = table.deepcopy(data.raw["armor"]["heavy-armor"]) -- copy the table that defines the heavy armor item into the fireArmor variable

fireArmor.name = "fire-armor"
fireArmor.icons = {
  {
    icon = fireArmor.icon,
    icon_size = fireArmor.icon_size,
    tint = {r=1,g=0,b=0,a=0.3}
  },
}
--]]

--biter nest variations
local custom_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
custom_spawner.name = "self-damaging-spawner"
custom_spawner.icon = "__base__/graphics/icons/biter-spawner.png"
custom_spawner.max_health = 3000
custom_spawner.healing_per_tick = .5
custom_spawner.max_count_of_owned_units = 0
custom_spawner.max_count_of_owned_defensive_units = 0
custom_spawner.max_friends_around_to_spawn = 0
custom_spawner.max_defensive_friends_around_to_spawn = 0
custom_spawner.spawning_cooldown = { 25, 35 }
custom_spawner.resistances = {
  {
    type = "physical",
    decrease = 10,
    percent = 99
  },
  {
    type = "explosion",
    decrease = 10,
    percent = 99
  },
  {
    type = "acid",
    decrease = 5,
    percent = 99
  },
  {
    type = "fire",
    decrease = 0,
    percent = 99
  }
}
data:extend({ custom_spawner })
local inactive_nest = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
inactive_nest.name = "inactive-spawner"
inactive_nest.max_count_of_owned_units = 0
data:extend({ inactive_nest })

--resource nest colors
local resource_colors = {
  ["iron-ore"] = { r = 0.15, g = 0.15, b = 0.9, a = 0.6 },
  ["copper-ore"] = { r = 0.803, g = 0.388, b = 0.215, a = 0.6 },
  ["coal"] = { r = 0.2, g = 0.2, b = 0.2, a = 0.6 },
  ["stone"] = { r = 0.5, g = 0.5, b = 0.5, a = 0.6 },
  ["uranium-ore"] = { r = 0.5, g = 0.5, b = 0.5, a = 0.6 },
  ["crude-oil"] = { r = 0.89, g = 0.349, b = 0.588, a = 0.6 }
}



--default active values
local default_nest_health = 3000
local default_active_nest_cooldown = { 25, 35 }
local default_active_max_count_of_owned_units = 100
--default inactive values
local default_inactive_nest_cooldown = { 999999, 999999 }
local default_inactive_max_count_of_owned_units = 0
local default_inactive_max_count_defensive_units = 0

local resourcespawners = {}
for _, resource_name in pairs(resource_types) do
  local inactive_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
  inactive_spawner.name = "inactive-biter-spawner-" .. resource_name
  inactive_spawner.max_health = default_nest_health
  inactive_spawner.max_count_of_owned_units = default_inactive_max_count_of_owned_units -- Prevent spawning
  inactive_spawner.spawning_cooldown = default_inactive_nest_cooldown
  inactive_spawner.max_count_of_owned_defensive_units = default_inactive_max_count_defensive_units

  local active_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
  active_spawner.name = "active-biter-spawner-" .. resource_name
  active_spawner.max_health = default_nest_health
  active_spawner.spawning_cooldown = default_active_nest_cooldown
  active_spawner.max_count_of_owned_units = default_active_max_count_of_owned_units
  --override default resource settings
  if resource_name == "crude-oil" then
    inactive_spawner.max_health = 1000
    active_spawner.max_health = 1000
    active_spawner.default_active_nest_cooldown = { 50, 60 }
    active_spawner.max_count_of_owned_units = 20
  end

  -- Set the tint for the spawner
  for res_name, resource_colors in pairs(resource_colors) do
    if resource_name == res_name then
      inactive_spawner.max_health = 6000
      active_spawner.icons = {
        {
          icon = active_spawner.icon,
          icon_size = active_spawner.icon_size,
          tint = resource_colors
        },
      }
      inactive_spawner.icons = {
        {
          icon = inactive_spawner.icon,
          icon_size = inactive_spawner.icon_size,
          tint = resource_colors
        },
      }


      if inactive_spawner.graphics_set and inactive_spawner.graphics_set.animations then
        for _, animation in pairs(inactive_spawner.graphics_set.animations) do
            if animation.layers then
                for _, layer in pairs(animation.layers) do
                    if layer then
                        layer.tint = resource_colors
                        if layer.hr_version then
                            layer.hr_version.tint = resource_colors
                        end
                    end
                end
            else
                animation.tint = resource_colors
                if animation.hr_version then
                    animation.hr_version.tint = resource_colors
                end
            end
        end
    else
        log("Warning: inactive_spawner.graphics_set.animations is nil. Unable to apply tint.") -- Debug message
    end
    end
  end


  table.insert(resourcespawners, inactive_spawner)
  table.insert(resourcespawners, active_spawner)
end
data:extend(resourcespawners)

--[[

      --active_spawner.animations[1].tint_as_overlay = true
      active_spawner.tint = resource_colors
      active_spawner.apply_runtime_tint = true
      active_spawner.tint_as_overlay = true

            inactive_spawner.tint = resource_colors
      inactive_spawner.apply_runtime_tint = true
      inactive_spawner.tint_as_overlay = true
      --inactive_spawner.animations[1].tint_as_overlay = true

]]
