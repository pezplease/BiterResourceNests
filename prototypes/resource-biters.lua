require "prototypes.biter-data"

local inactive_nest = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
inactive_nest.name = "inactive-spawner"
inactive_nest.max_count_of_owned_units = 0
data:extend({ inactive_nest })


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

--default biter values

local base_small_biter = table.deepcopy(data.raw["unit"]["small-biter"])
local base_medium_biter = table.deepcopy(data.raw["unit"]["medium-biter"])
local base_big_biter = table.deepcopy(data.raw["unit"]["big-biter"])
local base_behemoth_biter = table.deepcopy(data.raw["unit"]["behemoth-biter"])
local base_small_spitter = table.deepcopy(data.raw["unit"]["small-spitter"])
local base_medium_spitter = table.deepcopy(data.raw["unit"]["medium-spitter"])
local base_big_spitter = table.deepcopy(data.raw["unit"]["big-spitter"])
local base_behemoth_spitter = table.deepcopy(data.raw["unit"]["behemoth-spitter"])

--gets unique biter stats from biter-data.lua
function unique_biter_stats(stat_name, resource_name)
  local overrides = biter_overrides[resource_name]
  local stat
  if not overrides then
    resource_name = "generic"
    overrides = biter_overrides[resource_name]
  end
  if not overrides[stat_name] then
    stat = biter_overrides["generic"][stat_name]
  end
  stat = overrides[stat_name]
  return stat
end

function setup_resource_biters(resource_list)
  local resource_biters = {}
  for _, resource_name in pairs(resource_list) do
    local spawner_list = biter_list
    for res_types, unit_list in pairs(resource_units) do
      if res_types == resource_name then
        spawner_list = unit_list
      end
    end

    local health_multiplier = unique_biter_stats("health_multiplier", resource_name)
    local speed_multiplier = unique_biter_stats("speed_multiplier", resource_name)
    local damage_multiplier = unique_biter_stats("damage_multiplier", resource_name)

    --stat_overrides = unique_biter_stats("generic")
    --stat_overrides = unique_biter_stats(resource_name)
    for _, biter_name in pairs(spawner_list) do
      local biter = table.deepcopy(data.raw["unit"][biter_name])
      biter.name = resource_name .. "-" .. biter_name
      biter.order = "y-" .. resource_name .. "-y" .. biter_name
      biter.max_health = biter.max_health * health_multiplier
      biter.movement_speed = biter.movement_speed * speed_multiplier


      --Tint the biters in factoriopedia simulation to match the resource color
      biter.factoriopedia_simulation = {
        init =
            "    game.simulation.camera_zoom = 1.8\n    game.simulation.camera_position = {0, 0}\n    game.surfaces[1].build_checkerboard{{-40, -40}, {40, 40}}\n    enemy = game.surfaces[1].create_entity{name = \"" ..
            biter.name ..
            "\", position = {0, 0}}\n\n    step_0 = function()\n      game.simulation.camera_position = {enemy.position.x, enemy.position.y - 0.5}\n      script.on_nth_tick(1, function()\n          step_0()\n      end)\n    end\n\n    step_0()\n  "
      }
      --tint the biters to match the resource color
      for res_name, resource_colors in pairs(resource_colors) do
        if resource_name == res_name then
          biter.icons = {
            {
              icon = biter.icon,
              icon_size = biter.icon_size,
              tint = resource_colors
            },
          }
          if biter.run_animation then
            for _, layer in pairs(biter.run_animation.layers or { biter.run_animation }) do
              layer.tint = resource_colors
              if layer.hr_version then
                layer.hr_version.tint = resource_colors
              end
              --layer.hd_version.tint = resource_colors
            end
          end

          if biter.attack_parameters and biter.attack_parameters.animation then
            for _, layer in pairs(biter.attack_parameters.animation.layers or { biter.attack_parameters.animation }) do
              layer.tint = resource_colors
              if layer.hr_version then
                layer.hr_version.tint = resource_colors
              end
            end
          end
        end
      end
      table.insert(resource_biters, biter)
    end
  end

  data:extend(resource_biters)
end

--sets the unique stats for each resource nest by looking
-- into biter-data.lua and reads the resource_overrides table
function unique_resource_stats(resource, nest_type)
  local overrides = resource_overrides[resource]
  if not overrides then
    return
  end
  for key, value in pairs(overrides) do
    nest_type[key] = value
  end
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



function set_unit_spawners(resource_name)
  local result_units = specilized_biter_results(resource_name)
  for resource, _ in pairs(resource_units) do
    if resource == resource_name then
      result_units = specilized_spitter_results(resource_name)
      return result_units
    end
  end
  return result_units
end

local generic_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
generic_spawner.name = "base-resource-spawner"
data.raw["unit-spawner"]["base-resource-spawner"] = generic_spawner
data:extend({ generic_spawner })

function setup_resource_nests(resource_list)
  local resourcespawners = {}
  for _, resource_name in pairs(resource_list) do
    --local units = set_unit_spawners(resource_name)
    local inactive_spawner = table.deepcopy(generic_spawner)
    inactive_spawner.name = "inactive-biter-spawner-" .. resource_name
    inactive_spawner.max_health = default_nest_health
    inactive_spawner.max_count_of_owned_units = default_inactive_max_count_of_owned_units -- Prevent spawning
    inactive_spawner.spawning_cooldown = default_inactive_nest_cooldown
    inactive_spawner.max_count_of_owned_defensive_units = default_inactive_max_count_defensive_units
    inactive_spawner.resistances = default_resistances
    inactive_spawner.result_units = set_unit_spawners(resource_name)
    inactive_spawner.order = "y-" .. resource_name .. "-zc"
    local active_spawner = table.deepcopy(generic_spawner)
    active_spawner.name = "active-biter-spawner-" .. resource_name
    active_spawner.max_health = default_nest_health
    active_spawner.spawning_cooldown = default_active_nest_cooldown
    active_spawner.max_count_of_owned_units = default_active_max_count_of_owned_units
    active_spawner.resistances = default_resistances
    active_spawner.result_units = set_unit_spawners(resource_name)
    active_spawner.order = "y-" .. resource_name .. "-zb"
    --override default resource settings
    unique_resource_stats(resource_name, active_spawner)
    unique_resource_stats(resource_name, inactive_spawner)
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
