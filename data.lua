local inactive_nest = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
inactive_nest.name = "inactive-spawner"
inactive_nest.max_count_of_owned_units = 0
data:extend({ inactive_nest })

--resource nest colors
local resource_colors = {
  ["iron-ore"] = { r = 0.15, g = 0.15, b = 0.7, a = 0.8 },
  ["copper-ore"] = { r = 0.803, g = 0.388, b = 0.215, a = 0.8 },
  ["coal"] = { r = 0.2, g = 0.2, b = 0.2, a = 0.8 },
  ["stone"] = { r = 0.5, g = 0.5, b = 0.5, a = 0.8 },
  ["uranium-ore"] = { r = 0.23, g = 0.91, b = 0.2, a = 0.8 },
  ["crude-oil"] = { r = 0.89, g = 0.349, b = 0.588, a = 0.8 }
}
local resource_types = {
  "iron-ore",
  "copper-ore",
  "coal",
  "stone",
  "uranium-ore",
  "crude-oil"
}
local default_nest = {
  "generic-nest"
}
--remote.add_interface("resource_list", {
--  get_resource_list = function()
--    return resource_types
--  end
--})


function create_resistance_table(physdec, physperc, expdec, expperc, aciddec, acidperc, firedec, fireperc, laserdec,
                                 laserperc, elecdec, elecperc, poisdec, poisperc, impdec, impperc)
  local resistance_list = {
    {
      type = "physical",
      decrease = physdec,
      percent = physperc
    },
    {
      type = "explosion",
      decrease = expdec,
      percent = expperc
    },
    {
      type = "acid",
      decrease = aciddec,
      percent = acidperc
    },
    {
      type = "fire",
      decrease = firedec,
      percent = fireperc
    },
    {
      type = "laser",
      decrease = laserdec,
      percent = laserperc
    },
    {
      type = "electric",
      decrease = elecdec,
      percent = elecperc
    },
    {
      type = "poison",
      decrease = poisdec,
      percent = poisperc
    },
    {
      type = "impact",
      decrease = impdec,
      percent = impperc
    }
  }
  return resistance_list
end

function specilized_biter_results(resource_type)
  biter_units = {
    {
      resource_type .. "-" .. "small-biter",
      {
        {
          0,
          0.3
        },
        {
          0.6,
          0
        }
      }
    },
    {
      resource_type .. "-" .. "medium-biter",
      {
        {
          0,
          0
        },
        {
          0.6,
          0.3
        },
        {
          0.7,
          0.1
        }
      }
    },
    {
      resource_type .. "-" .. "big-biter",
      {
        {
          0.2,
          0
        },
        {
          1,
          0.4
        }
      }
    },
    {
      resource_type .. "-" .. "behemoth-biter",
      {
        {
          0.85,
          0
        },
        {
          1,
          0.3
        }
      }
    }
  }
  return biter_units
end

spitter_units = {
  {
    "small-biter",
    {
      {
        0,
        0.3
      },
      {
        0.35,
        0
      }
    }
  },
  {
    "small-spitter",
    {
      {
        0,
        0.3
      },
      {
        0.5,
        0.3
      },
      {
        0.6,
        0
      }
    }
  },
  {
    "medium-spitter",
    {
      {
        0.2,
        0
      },
      {
        0.7,
        0.3
      },
      {
        0.9,
        0.1
      }
    }
  },
  {
    "big-spitter",
    {
      {
        0.2,
        0
      },
      {
        1,
        0.4
      }
    }
  },
  {
    "big-biter",
    {
      {
        0.3,
        0
      },
      {
        1,
        0.4
      }
    }
  },
  {
    "behemoth-spitter",
    {
      {
        0.75,
        0
      },
      {
        1,
        0.1
      }
    }
  }
}

--default biter values
local default_biter_multiplier = 3
local default_biter_speed = 0.5

local base_small_biter = table.deepcopy(data.raw["unit"]["small-biter"])
local base_medium_biter = table.deepcopy(data.raw["unit"]["medium-biter"])
local base_big_biter = table.deepcopy(data.raw["unit"]["big-biter"])
local base_behemoth_biter = table.deepcopy(data.raw["unit"]["behemoth-biter"])
local base_small_spitter = table.deepcopy(data.raw["unit"]["small-spitter"])
local base_medium_spitter = table.deepcopy(data.raw["unit"]["medium-spitter"])
local base_big_spitter = table.deepcopy(data.raw["unit"]["big-spitter"])
local base_behemoth_spitter = table.deepcopy(data.raw["unit"]["behemoth-spitter"])
local biter_list = {
  "small-biter",
  "medium-biter",
  "big-biter",
  "behemoth-biter",
}
local spitter_list = {
  "small-spitter",
  "medium-spitter",
  "big-spitter",
  "behemoth-spitter",
}

function setup_resource_biters(resource_list)
  local resource_biters = {}
  for _, resource_name in pairs(resource_list) do
    for _, biter_name in pairs(biter_list) do
      local biter = table.deepcopy(data.raw["unit"][biter_name])
      biter.name = resource_name .. "-" .. biter_name
      biter.max_health = biter.max_health * default_biter_multiplier
      biter.movement_speed = biter.movement_speed * default_biter_speed
      for res_name, resource_colors in pairs(resource_colors) do
        if resource_name == res_name then
          biter.icons = {
            {
              icon = biter.icon,
              icon_size = biter.icon_size,
              tint = resource_colors
            },
          }
          if biter.graphics_set and biter.graphics_set.animations then
            for _, animation in pairs(biter.graphics_set.animations) do
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
      table.insert(resource_biters, biter)
    end
  end

  data:extend(resource_biters)
end

--default active values
local default_nest_health = 7500
local default_active_nest_cooldown = { 5, 10 }
local default_active_max_count_of_owned_units = 100
local default_resistances = create_resistance_table(10, 80, 0, 80, 0, 80, 0, 80, 0, 80, 0, 80, 0, 80, 0, 80)

--default inactive values
local default_inactive_nest_cooldown = { 999999, 999999 }
local default_inactive_max_count_of_owned_units = 0
local default_inactive_max_count_defensive_units = 0


local generic_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
generic_spawner.name = "base-resource-spawner"
data.raw["unit-spawner"]["base-resource-spawner"] = generic_spawner
data:extend({ generic_spawner })

function setup_resource_nests(resource_list)
  local resourcespawners = {}
  for _, resource_name in pairs(resource_list) do
    local inactive_spawner = table.deepcopy(generic_spawner)
    inactive_spawner.name = "inactive-biter-spawner-" .. resource_name
    inactive_spawner.max_health = default_nest_health
    inactive_spawner.max_count_of_owned_units = default_inactive_max_count_of_owned_units -- Prevent spawning
    inactive_spawner.spawning_cooldown = default_inactive_nest_cooldown
    inactive_spawner.max_count_of_owned_defensive_units = default_inactive_max_count_defensive_units
    inactive_spawner.resistances = default_resistances
    inactive_spawner.result_units = specilized_biter_results(resource_name)

    local active_spawner = table.deepcopy(generic_spawner)
    active_spawner.name = "active-biter-spawner-" .. resource_name
    active_spawner.max_health = default_nest_health
    active_spawner.spawning_cooldown = default_active_nest_cooldown
    active_spawner.max_count_of_owned_units = default_active_max_count_of_owned_units
    active_spawner.resistances = default_resistances
    active_spawner.result_units = specilized_biter_results(resource_name)

    --override default resource settings
    if resource_name == "crude-oil" then
      inactive_spawner.max_health = 1000
      active_spawner.max_health = 1000
      active_spawner.default_active_nest_cooldown = { 50, 60 }
      active_spawner.max_count_of_owned_units = 20
    elseif resource_name == "copper-ore" then
      inactive_spawner.result_units = spitter_units
      active_spawner.result_units = spitter_units
    end
    -- Set the tint for the spawner
    for res_name, resource_colors in pairs(resource_colors) do
      if resource_name == res_name then
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
        if active_spawner.graphics_set and active_spawner.graphics_set.animations then
          for _, animation in pairs(active_spawner.graphics_set.animations) do
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
end

setup_resource_biters(resource_types)
setup_resource_biters(default_nest)
setup_resource_nests(resource_types)
setup_resource_nests(default_nest)
