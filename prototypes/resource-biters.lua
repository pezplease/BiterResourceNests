require "prototypes.biter-data"


--[[ local inactive_nest = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
inactive_nest.name = "inactive-spawner"
inactive_nest.max_count_of_owned_units = 0
data:extend({ inactive_nest }) ]]

--function create_resistance_table(resistance_list)


function create_resistance_table(physdec, physperc, expdec, expperc, aciddec, acidperc, firedec, fireperc, laserdec,
                                 laserperc, elecdec, elecperc, poisdec, poisperc, impdec, impperc)
  local resistance_table = {
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
  return resistance_table
end

--recolors all resource biter corpses
function setup_biter_corpses(resource_list)
  local resource_corpses = {}
  for _, resource_name in pairs(resource_list) do
    local spawner_list = resource_name.unit_types
    for _, biter_name in pairs(spawner_list) do
      local biter_corpse = table.deepcopy(data.raw["corpse"][biter_name .. "-corpse"])
      if biter_corpse.animation and biter_corpse.animation.layers then
        for _, layer in pairs(biter_corpse.animation.layers) do
          layer.tint = resource_name.color_data
        end
      end
      if biter_corpse.decay_animation and biter_corpse.decay_animation.layers then
        for _, layer in pairs(biter_corpse.decay_animation.layers) do
          layer.tint = resource_name.color_data
        end
      end
      biter_corpse.name = resource_name.name .. "-" .. biter_name .. "-corpse"

      table.insert(resource_corpses, biter_corpse)
    end
  end
  data:extend(resource_corpses)
end

--create and recolor the corpses for the biter nests.
function setup_resource_nest_corpse(resource_list)
  local nest_corpses = {}
  for _, resource_name in pairs(resource_list) do
    local corpse = table.deepcopy(data.raw["corpse"]["biter-spawner-corpse"])

    if corpse.animation and corpse.animation.layers then

          for _, layer in pairs(corpse.animation.layers) do
            if layer then
              if layer.tint then
              layer.tint = resource_name.color_data
              end
          
        end
      end
    end
    if corpse.decay_animation and corpse.decay_animation.layers then
      for _, layer in pairs(corpse.decay_animation.layers) do
        if layer then
          layer.tint = resource_name.color_data
        end
      end
    end
    corpse.icons = {
      tint = resource_name.color_data
    }
    --[[     if corpse.graphics_set and corpse.graphics_set.animations then
      for _, animation in pairs(corpse.graphics_set.animations) do
        if animation.layers then
        for _, layer in pairs (animation.layers) do
          if layer then
            layer.tint = resource_name.color_data
        end
      end
      end
    end
  end ]]



    corpse.name = resource_name.name .. "-biter-spawner-corpse"

    table.insert(nest_corpses, corpse)
  end
  data:extend(nest_corpses)
end

function setup_resource_biters(resource_list)
  local resource_biters = {}
  for _, resource_name in pairs(resource_list) do
    local spawner_list = biter_list

    local r = resource_name.resistance_data
    spawner_list = resource_name.unit_types

    local health_multiplier = resource_name.biter_data.health_multiplier
    local speed_multiplier = resource_name.biter_data.speed_multiplier
    local damage_multiplier = resource_name.biter_data.damage_multiplier


    local biter_res_name = resource_name.name
    for _, biter_name in pairs(spawner_list) do
      local resource_colors = resource_name.color_data
      --create biter corpse)
      local biter = table.deepcopy(data.raw["unit"][biter_name])

      biter.corpse = resource_name.name .. "-" .. biter_name .. "-corpse"
      biter.max_health = biter.max_health * health_multiplier * settings.startup["resource-nests-biter-health-multiplier"].value

      biter.name = biter_res_name .. "-" .. biter_name
      biter.order = "y-" .. biter_res_name .. "-y" .. biter_name
      if settings.startup["resource-nests-add-resource-to-drop-table"].value == true then
        if resource_name.loot_name then
          
        local loot_count = (biter.max_health / 22) * settings.startup["resource-nests-resource-drop-amount"].value
        if loot_count > (settings.startup["resource-nests-resource-drop-amount"].value * 25) then
          loot_count = settings.startup["resource-nests-resource-drop-amount"].value * 25
        end
              biter.loot = {{
                
        count_max = loot_count,
        count_min = loot_count,
        
        item = resource_name.loot_name,
        probability = settings.startup["resource-nests-resource-drop-rate"].value
      }}
        end
     end


      biter.movement_speed = biter.movement_speed * speed_multiplier
      biter.resistances = create_resistance_table(r.physdec, r.physperc, r.expdec, r.expperc, r.aciddec, r.acidperc,
        r.firedec, r.fireperc, r.laserdec,
        r.laserperc, r.elecdec, r.elecperc, r.poisdec, r.poisperc, r.impdec, r.impperc)

      --set damage
      if string.find(biter_name, "biter") then
        if biter.attack_parameters and biter.attack_parameters.ammo_type then
          --set the new damage value
          local new_damage = biter.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount *
              damage_multiplier
          biter.attack_parameters.ammo_type.action.action_delivery.target_effects = {
            {
              type = "damage",
              damage = { amount = new_damage, type = "physical" } -- Change damage type if needed
            }
          }
        end
      elseif string.find(biter_name, "spitter") then
        local new_damage = 55 --biter.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount * damage_multiplier
        if biter.attack_parameters and biter.attack_parameters.ammo_type then
          -- Modify spitter projectile damage
          biter.attack_parameters.ammo_type.action.action_delivery.projectile = "acid-projectile-purple"
          biter.attack_parameters.range = 35
          biter.attack_parameters.ammo_type.action.action_delivery.target_effects = {
            {
              type = "damage",
              damage = { amount = new_damage, type = "acid" }
            }
          }
        end
      end

      --Tint the biters in factoriopedia simulation to match the resource color
      biter.factoriopedia_simulation = {
        init =
            "    game.simulation.camera_zoom = 1.8\n    game.simulation.camera_position = {0, 0}\n    game.surfaces[1].build_checkerboard{{-40, -40}, {40, 40}}\n    enemy = game.surfaces[1].create_entity{name = \"" ..
            biter.name ..
            "\", position = {0, 0}}\n\n    step_0 = function()\n      game.simulation.camera_position = {enemy.position.x, enemy.position.y - 0.5}\n      script.on_nth_tick(1, function()\n          step_0()\n      end)\n    end\n\n    step_0()\n  "
      }
      --tint the biters to match the resource color

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

          --layer.hd_version.tint = resource_colors
        end
      end

      if biter.attack_parameters and biter.attack_parameters.animation then
        for _, layer in pairs(biter.attack_parameters.animation.layers or { biter.attack_parameters.animation }) do
          layer.tint = resource_colors
        end
      end

      table.insert(resource_biters, biter)
    end
  end

  data:extend(resource_biters)
end



--default inactive values
local default_inactive_nest_cooldown = {999999,999999} 
--{ 999999, 999999 }
local default_inactive_max_count_of_owned_units = 0
local default_inactive_max_count_defensive_units = 0


if settings.startup["resource-nests-dormant-biter-spawn"].value > 0 then
--default inactive values
default_inactive_nest_cooldown = {200,900} 
--{ 999999, 999999 }
default_inactive_max_count_of_owned_units = settings.startup["resource-nests-dormant-biter-spawn"].value
default_inactive_max_count_defensive_units = 0
 end


function set_unit_spawners(resource_name)
  local result_units = specilized_biter_results(resource_name)
  if resource_name.unit_types == spitter_list then
    result_units = specilized_spitter_results(resource_name)
    return result_units
  end
  return result_units
end

local generic_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
generic_spawner.name = "base-resource-spawner"
generic_spawner.autoplace = nil
data.raw["unit-spawner"]["base-resource-spawner"] = generic_spawner
generic_spawner.hidden_in_factoriopedia = true
data:extend({ generic_spawner })

function setup_resource_nests(resource_list)


  local resourcespawners = {}
  for _, resource_name in pairs(resource_list) do
    local r = resource_name.resistance_data
    --local units = set_unit_spawners(resource_name)
    local inactive_spawner = table.deepcopy(generic_spawner)
    inactive_spawner.name = "inactive-biter-spawner-" .. resource_name.name
    --inactive_spawner.is_military_target = false
    inactive_spawner.hidden_in_factoriopedia = false
    inactive_spawner.max_health = resource_name.spawner_data.max_health
    inactive_spawner.healing_per_tick = 100
    inactive_spawner.max_count_of_owned_units = default_inactive_max_count_of_owned_units
    inactive_spawner.spawning_cooldown = default_inactive_nest_cooldown
    inactive_spawner.max_count_of_owned_defensive_units = default_inactive_max_count_defensive_units
    inactive_spawner.resistances = create_resistance_table(r.physdec, r.physperc, r.expdec, r.expperc, r.aciddec,
      r.acidperc, r.firedec, r.fireperc, r.laserdec,
      r.laserperc, r.elecdec, r.elecperc, r.poisdec, r.poisperc, r.impdec, r.impperc)
    inactive_spawner.result_units = set_unit_spawners(resource_name.name)
    inactive_spawner.order = "y-" .. resource_name.name .. "-zc"
    inactive_spawner.autoplace = nil
    --inactive_spawner.corpse = resource_name.name .. "-biter-spawner-corpse"
    inactive_spawner.corpse = resource_name.spawner_data.corpse
    local active_spawner = table.deepcopy(generic_spawner)
    active_spawner.name = "active-biter-spawner-" .. resource_name.name
    active_spawner.hidden_in_factoriopedia = false
    active_spawner.max_health = resource_name.spawner_data.max_health
    active_spawner.spawning_cooldown = resource_name.spawner_data.spawning_cooldown
    active_spawner.max_count_of_owned_units = resource_name.spawner_data.max_units
    active_spawner.resistances = create_resistance_table(r.physdec, r.physperc, r.expdec, r.expperc, r.aciddec,
      r.acidperc, r.firedec, r.fireperc, r.laserdec,
      r.laserperc, r.elecdec, r.elecperc, r.poisdec, r.poisperc, r.impdec, r.impperc)
    active_spawner.result_units = set_unit_spawners(resource_name.name)
    active_spawner.order = "y-" .. resource_name.name .. "-zb"
    --active_spawner.corpse = resource_name.name .. "-biter-spawner-corpse"
    active_spawner.corpse = resource_name.spawner_data.corpse
    active_spawner.autoplace = nil
    
    --override default resource settings
    -- Set the tint for the spawner
    local resource_colors = resource_name.color_data
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
                end
              end
            else
              animation.tint = resource_colors
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

            end
          end
        else
          animation.tint = resource_colors

        end
      end
    else
      log("Warning: inactive_spawner.graphics_set.animations is nil. Unable to apply tint.") -- Debug message
    end




    table.insert(resourcespawners, inactive_spawner)
    table.insert(resourcespawners, active_spawner)
  end
  data:extend(resourcespawners)
end
