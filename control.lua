require "prototypes.biter-data"

--require "script.resource_nests"
require "script.initilization"
require "script.patch_creation"
require "script.nest_attack"

--deals damage to the spawner when a unit is spawned
script.on_event(defines.events.on_entity_spawned, function(event)
  local entityspawned = event.entity
  --game.print("Entity spawned: " .. entityspawned.name)
  if entityspawned.type == "unit" then
    local spawner = event.spawner
    --game.print("Nest name: " .. spawner.name)

    --deals damage to either active or inactive nests. #todo make dealing damage to inactive nests active.
    if spawner and spawner.valid and string.find(spawner.name, "active%-biter%-spawner") then
      local damage_amount = 100 -- Adjust the damage as needed
      --game.print("Damage dealt to nest")
      spawner.damage(damage_amount, spawner.force)
      for i, nest_info in pairs(storage.active_nests) do
        if nest_info.entity == spawner then
          --game.print("tick is: " .. game.tick)
          nest_info.lastspawn = game.tick
          break
        end
      end
    end
  end
end)

--checks if a player mines a resource patch.
script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  local nest_type = "generic"
  game.print("Entity mined: " .. entity.name)
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

script.on_nth_tick(75, function()
  check_nest_activity()
  deleteallstartingnests()
end)
--check nest activity checks to see if an active nest is still being attacked,
-- and also triggers nest attacks
function check_nest_activity()
  if not storage.active_nests then return end
  for i, nest_info in pairs(storage.active_nests) do
    if nest_info.entity and (game.tick - nest_info.lastspawn > 600) then
      deactivate_nest(nest_info.entity)
      table.remove(storage.active_nests, i)
    elseif nest_info.entity then
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

function activate_nest(nest, resource_mined)
  game.print("Nest activate function called")
  if not nest or not nest.valid then return end
  local active_nest_name = "active-biter-spawner-generic"
  -- Change the spawner to the active version
  for _, resource_table_data in pairs(resource_list) do
    local resource_table = resource_table_data.name
    if resource_table == resource_mined then
      active_nest_name = "active-biter-spawner-" .. resource_mined
      break
    end
  end
  game.print("Nest activated at " .. nest.position.x .. ", " .. nest.position.y)
  local surface = game.surfaces["nauvis"]
  local active_nest = surface.create_entity({
    name = active_nest_name,
    position = nest.position,
    force = "enemy"
  })

  local activate_particles = "ground-explosion"

  surface.create_entity({
    name = activate_particles,
    position = nest.position,
    force = "enemy"
  })

  --set active nest health to inactive_nest
  active_nest.health = nest.health
  --adds the activated nest to the active_nests table. will check every to see if it should go dorment.
  table.insert(storage.active_nests, {
    entity = active_nest,
    lastspawn = game.tick,
    resource = resource_mined,
  })

  -- Destroy the inactive nest
  nest.destroy()

  --return active_nests
end

function deleteallstartingnests()
  if not storage.spawned_nests or not storage.remove_patches then return end

  --game.print("Nest amount: " .. #storage.spawned_nests)

  local closest_nests = {}
  for resource_name, resource_count in pairs(storage.patches_to_remove) do
    if storage.patches_to_remove[resource_name] < 1 then break end
    game.print(resource_name .. ": " .. resource_count)
  end

  -- Find the closest nest for each resource type
  for resource_name, _ in pairs(storage.patches_to_remove) do
    if storage.patches_to_remove[resource_name] > 0 then
      local current_closest = nil

      for _, nest_info in pairs(storage.spawned_nests) do
        if nest_info.resource_name == resource_name then
          if not current_closest or nest_info.distance < current_closest.distance then
            current_closest = nest_info
          end
        end
      end

      if current_closest then
        table.insert(closest_nests, current_closest)
      end
    end
  end

  -- Now destroy the closest nests
  local surface = game.surfaces["nauvis"]

  for _, closest_nest in pairs(closest_nests) do
    if closest_nest.entity and closest_nest.entity.valid then
      --game.print("Deleting nest at " .. closest_nest.entity.position.x .. ", " .. closest_nest.entity.position.y)
      storage.patches_to_remove[closest_nest.resource_name] = storage.patches_to_remove[closest_nest.resource_name] - 1
      -- Add chart tag
      game.forces["player"].add_chart_tag(surface, {
        position = closest_nest.entity.position,
        text = "Center Nest",
        icon = { type = "item", name = "raw-fish" }
      })

      -- Destroy the entity
      local radius = 44
      local nests_to_remove = surface.find_entities_filtered({
        area = {
          { closest_nest.entity.position.x - radius, closest_nest.entity.position.y - radius },
          { closest_nest.entity.position.x + radius, closest_nest.entity.position.y + radius }
        },
        type = { "unit-spawner" }
      })
      game.print("the amount of nests to remove is: " .. #nests_to_remove)
      for _, nest in pairs(nests_to_remove) do
        nest.destroy()
      end
    end
  end
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  give_player_starter_items(player)
  --deleteallstartingnests()
end)


function give_player_starter_items(player)
  -- Ensure the player has car and nuclear fuel in their inventory
  local surface = game.surfaces["nauvis"]
  local car = player.surface.create_entity {
    name = "car",
    position = player.position,
    force = player.force
  }
  car.insert { name = "nuclear-fuel", count = 5 } -- Add fuel to the car
  player.print("You have received a car with nuclear fuel!")
  car.insert { name = "gun-turret", count = 50 }
  car.insert { name = "firearm-magazine", count = 3000 }
  car.insert { name = "uranium-rounds-magazine", count = 1000 }
end
