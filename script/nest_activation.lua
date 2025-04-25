--require "control"
require "script.initilization"



function check_nest_activity()
  if not storage.active_nests then return end
  for i, nest_info in pairs(storage.active_nests) do
    if nest_info.entity and (game.tick - nest_info.lastspawn > 1000) then
      deactivate_nest(nest_info.entity)
      table.remove(storage.active_nests, i)
    elseif nest_info.entity.valid then --nest_info.entity then
      shoot_nest_projectile(nest_info.entity, nest_info.resource)
    end
  end
end

function deactivate_nest(nest)
  if not nest or not nest.valid then return end
  local inactive_nest_name = "in" .. nest.name
  local surface = game.surfaces["nauvis"]
  local inactive_nest = surface.create_entity({
    name = inactive_nest_name,
    position = nest.position,
    force = "enemy"
  })
  inactive_nest.health = nest.health

  nest.destroy()
end

function activate_nest(first_nest, resource_mined)
  if not first_nest or not first_nest.valid then return end
  --local active_nest_name = "active-biter-spawner-generic"
  -- Change the spawner to the active version
  --[[   for _, resource_table_data in pairs(resource_list) do
      local resource_table = resource_table_data.name
      if resource_table == resource_mined then
        active_nest_name = "active-biter-spawner-" .. resource_mined
        break
      end
    end ]]


  --remove the "in" from the inactive nest name to get the active nest name.
  local active_nest_name = first_nest.name:sub(3)
  local surface = game.surfaces["nauvis"]

  local group_nests = surface.find_entities_filtered({
    name = first_nest.name,
    position = first_nest.position,
    radius = 62
  })

  for _, dorm_nest in pairs(group_nests) do

    local active_nest = surface.create_entity({
      name = active_nest_name,
      position = dorm_nest.position,
      force = "enemy"
    })

    local activate_particles = "ground-explosion"

    surface.create_entity({
      name = activate_particles,
      position = dorm_nest.position,
      force = "enemy"
    })
    if not resource_mined then
      resource_mined = active_nest_name:sub(22)
    end
    --set active nest health to inactive_nest
    active_nest.health = dorm_nest.health
    --adds the activated nest to the active_nests table. will check every to see if it should go Dormant.
    table.insert(storage.active_nests, {
      entity = active_nest,
      lastspawn = game.tick,
      resource = resource_mined,
    })

    -- Destroy the inactive nest
    dorm_nest.destroy()
  end
  --return active_nests
end

--checks if a player mines a resource patch.
script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  local nest_type = "generic"

  for _, resource_check_data in pairs(resource_list) do
    local resource_check = resource_check_data.name
    if resource_check == entity.name then
      nest_type = entity.name
      break
    end
  end
  local nests = entity.surface.find_entities_filtered {
    name = "inactive-biter-spawner-" .. nest_type,
    position = entity.position,
    radius = 62
  }
  for _, nest in pairs(nests) do
    if not nest.valid then return end
    activate_nest(nest, event.entity.name)
  end
end)

--checks if a player places a mining drill, pumpjack or turret.
script.on_event({ defines.events.on_built_entity, defines.events.on_robot_built_entity }, function(event)
  local entity = event.created_entity or event.entity

  if not (entity and entity.valid) then return end

  local entity_type = entity.type
  local entity_name = entity.name

  -- Check by entity type
  if entity_type == "ammo-turret" or entity_type == "pumpjack" then
    local nests = entity.surface.find_entities_filtered {
      type = "unit-spawner",
      position = entity.position,
      radius = 18
    }
    if #nests > 0 then
      for _, nest in pairs(nests) do
        if not nest.valid then return end
        if string.find(nest.name, "inactive") then
          activate_nest(nest)
        end
      end
    end
  elseif entity_type == "mining-drill" then
    local nests = entity.surface.find_entities_filtered {
      type = "unit-spawner",
      position = entity.position,
      radius = 30
    }
    if #nests > 0 then
      for _, nest in pairs(nests) do
        if not nest.valid then return end
        if string.find(nest.name, "inactive") then
          activate_nest(nest)
        end
      end
    end
  end
  
end)
