script.on_init(function()
  storage.spawned_nests = {}
  storage.last_biter_kill = 0

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

function removenormalnests()
  local surface = game.surfaces["nauvis"]

  if settings.startup["remove-normal-nests"].value then
    game.print("Removing normal nests")
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
        local nest_type
        nest_type = "inactive-biter-spawner-" .. resource.name

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
  deleteallstartingnests()
end)

script.on_event(defines.events.on_entity_spawned, function(event)
  local spawner = event.spawner
  local entityspawned = event.entity

  if entityspawned.type == "unit" then
    if spawner and spawner.valid and spawner.name == "self-damaging-spawner" then
      local damage_amount = 132 -- Adjust the damage as needed
      spawner.damage(damage_amount, spawner.force)
    end
  end
end)


script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  --if entity and entity.name == "resource-name" then
  local nests = entity.surface.find_entities_filtered {
    name = "inactive-biter-spawner-" .. entity.name,
    position = entity.position,
    radius = 62
  }
  for _, nest in pairs(nests) do
    if not nest.valid then return end
    --nest.force = game.forces.enemy
    --local spawned_nest = surface.create_entity({
    --  name = "self-damaging-spawner",
    --  position = { x = nest.entity.position.x, y = nest.entity.position.y },
    --  force = "enemy", -- Makes it hostile
      
    --})
  end
end)
script.on_nth_tick(450, function()
  deleteallstartingnests()
end)

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
      game.print("Deleting nest at " .. closest_nest.entity.position.x .. ", " .. closest_nest.entity.position.y)
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

function table.contains(tbl, element)
  for _, value in pairs(tbl) do
    if value == element then
      return true
    end
  end
  return false
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  give_player_starter_items(player)
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
  car.insert { name = "firearm-magazine", count = 2000 }
end
