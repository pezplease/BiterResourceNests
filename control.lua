script.on_init(function()
  storage.spawned_nests = {}
  storage.last_biter_kill = 0
  storage.active_nests = {}
  --add any resources here that you want to not have a nest spawn the first time it's encountered
  --higher numbers means more than one patch will be avoided
  storage.patches_to_remove = {
    ["iron-ore"] = 1,
    ["copper-ore"] = 1,
    ["coal"] = 1,
    ["stone"] = 1,
    --["uranium-ore"] = 1,
    --["crude-oil"] = 1
  }
  storage.remove_patches = settings.startup["starting-resource-exemption"].value
  removenormalnests()
end)
--todo find all resources automatically.
local resource_types = {
  "iron-ore",
  "copper-ore",
  "coal",
  "stone",
  "uranium-ore",
  "crude-oil"
}

function removenormalnests()
  local surface = game.surfaces["nauvis"]

  if settings.startup["remove-normal-nests"].value then
    local map_settings = surface.map_gen_settings
    map_settings.autoplace_controls["enemy-base"] = { frequency = "none", size = "none", richness = "none" }
    surface.map_gen_settings = map_settings
    for _, entity in pairs(surface.find_entities_filtered { type = { "unit", "unit-spawner", "turret" } }) do
      entity.destroy()
    end
  end
end

local function position_key(position)
  -- Helper to create a unique key for a position
  return string.format("%d,%d", math.floor(position.x), math.floor(position.y))
end

local function get_connected_resources(surface, start_entity)
  -- Breadth-first search to collect all connected resource entities
  local visited = {}
  local to_visit = { start_entity }
  local patch_resources = {}

  while #to_visit > 0 do
    local entity = table.remove(to_visit)
    local pos_key = position_key(entity.position)

    if not visited[pos_key] then
      visited[pos_key] = true
      table.insert(patch_resources, entity)

      -- Find neighboring resource tiles of the same type
      local neighbors = surface.find_entities_filtered({
        area = {
          { entity.position.x - 1.5, entity.position.y - 1.5 },
          { entity.position.x + 1.5, entity.position.y + 1.5 },
        },
        type = "resource",
        name = entity.name -- Ensure same resource type
      })

      for _, neighbor in pairs(neighbors) do
        local neighbor_pos_key = position_key(neighbor.position)
        if not visited[neighbor_pos_key] then
          table.insert(to_visit, neighbor)
        end
      end
    end
  end

  return patch_resources
end
--create nests on resource patches on chunk generation.
script.on_event(defines.events.on_chunk_generated, function(event)
  local surface = event.surface
  local area = event.area

  -- Find all resources in the chunk
  local resource_entities = surface.find_entities_filtered({
    area = area,
    type = "resource"
  })

  local processed = {}

  for _, resource in pairs(resource_entities) do
    local pos_key = position_key(resource.position)
    if not processed[pos_key] then
      -- Get all connected resources for this patch
      local patch_resources = get_connected_resources(surface, resource)

      -- Mark resources as processed
      for _, patch_resource in pairs(patch_resources) do
        processed[position_key(patch_resource.position)] = true
      end

      -- Calculate the geometric center of the patch
      if #patch_resources > 0 then
        local center_x, center_y = 0, 0
        for _, patch_resource in pairs(patch_resources) do
          center_x = center_x + patch_resource.position.x
          center_y = center_y + patch_resource.position.y
        end
        center_x = center_x / #patch_resources
        center_y = center_y / #patch_resources

        -- Scale strength based on patch size
        local patch_size = #patch_resources -- Ensure this variable is set
        local nest_type = "inactive-biter-spawner-generic-nest"
        for _, resource_table in pairs(resource_types) do
          if resource_table == resource.name then
            nest_type = "inactive-biter-spawner-" .. resource.name
            break
          end
        end
        local surface = game.surfaces["nauvis"]
        local nearbyresourcenests = surface.find_entities_filtered {
          name = nest_type,
          position = {x = center_x, y = center_y},
          radius = 8
        }
        if #nearbyresourcenests == 0 then
                  local spawned_nest = surface.create_entity({
          name = nest_type,
          position = { x = center_x, y = center_y },
          force = "enemy", -- Makes it hostile

        })
        --game.print("Nest spawned at " .. center_x .. ", " .. center_y)
        if storage.remove_patches and spawned_nest then
          table.insert(storage.spawned_nests, {
            entity = spawned_nest,
            resource_name = resource.name,
            distance = math.sqrt(center_x ^ 2 + center_y ^ 2),
            nest_y = center_y,
            nest_x = center_x
          })
        end

        end
      end
    end
  end
  --deleteallstartingnests()
end)

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
  local nest_type = "generic-nest"
  game.print("Entity mined: " .. entity.name)
  for _, resource_check in pairs(resource_types) do
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

script.on_nth_tick(250, function()
  check_nest_activity()
  deleteallstartingnests()
end)

function check_nest_activity()
  if not storage.active_nests then return end
  for i, nest_info in pairs(storage.active_nests) do
    if nest_info.entity and (game.tick - nest_info.lastspawn > 600) then
      deactivate_nest(nest_info.entity)
      table.remove(storage.active_nests, i)
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
  local active_nest_name = "active-biter-spawner-generic-nest"
  -- Change the spawner to the active version
  for _, resource_table in pairs(resource_types) do
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
  --if resource_mined == "coal" then
  --  activate_particles = "ground-explosion"
  --elseif
  --    resource_mined == "copper-ore" then
  --  activate_particles = "poison-cloud"
 -- end
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
    lastspawn = game.tick
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
