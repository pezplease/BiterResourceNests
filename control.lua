script.on_init(function()
  storage.spawned_nests = {}
  storage.last_biter_kill = 0
  storage.starting_patches = {
    ["iron-ore"] = 1,
    ["copper-ore"] = 1,
    ["coal"] = 1,
    ["stone"] = 1,
  }
  storage.patches_to_remove = {
    ["iron-ore"] = 1,
    ["copper-ore"] = 1,
    ["coal"] = 1,
    ["stone"] = 1,
  }
  storage.remove_patches = true
end)


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
  local settings_enabled = false --settings.storage["starting-resource-spawners"].value

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

        -- Skip the first starting resource patches
        local resource_name = resource.name
        --checks if this is the first time the resource has been encountered
        --[[
        if storage.starting_patches[resource_name] and storage.starting_patches[resource_name] > 0
        then
          storage.starting_patches[resource_name] = storage.starting_patches[resource_name] - 1
          --debug steel chest, lol
          surface.create_entity({
            name = "steel-chest",
            position = {x = center_x, y = center_y},
          })
        else
          --]]
        -- Scale strength based on patch size
        local patch_size = #patch_resources -- Ensure this variable is set
        local nest_type
        if patch_size > 300 then
          nest_type = "self-damaging-spawner"
        else
          nest_type = "self-damaging-spawner"
        end

        local spawned_nest = surface.create_entity({
          name = nest_type,
          position = { x = center_x, y = center_y },
          force = "enemy", -- Makes it hostile
          active = false
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

end)

script.on_event(defines.events.on_entity_spawned, function(event)
  local spawner = event.spawner
  local entityspawned = event.entity

  if entityspawned.type == "unit" then
    if spawner and spawner.valid and spawner.name == "self-damaging-spawner" then
      local damage_amount = 30 -- Adjust the damage as needed
      spawner.damage(damage_amount, spawner.force)
    end
  end
end)



script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  --if entity and entity.name == "resource-name" then
  local nests = entity.surface.find_entities_filtered {
    name = "self-damaging-spawner",
    position = entity.position,
    radius = 32
  }
  for _, nest in pairs(nests) do
    nest.active = true
  end
end)
script.on_nth_tick(250, function()
  --deletestartingnests()
  deleteallstartingnests()
end)

function deletestartingnests()
  if not storage.spawned_nests or not storage.remove_patches then return end
  local closest_nests = {}
  game.print("nest amount: " .. #storage.spawned_nests)
  for _, nest_info in pairs(storage.spawned_nests) do
    for resource_name, _ in pairs(storage.patches_to_remove) do
      if storage.patches_to_remove[resource_name] < 1 then break end
      local current_closest
      if nest_info.resource_name == resource_name then
        if not current_closest then
          current_closest = nest_info
        else
          if nest_info.distance < current_closest.distance then
            current_closest = nest_info
          end
        end
      end
      game.print("about to delete nest type: " .. resource_name)
      if current_closest then
        game.print("current closest entity exists")
        if current_closest.entity and current_closest.entity.valid then
          --game.print("current closest entity is valid")
          local radius = 33
          local surface = game.surfaces["nauvis"]
          game.print("The closest nest to the center is: " .. current_closest.distance)
          game.forces["player"].add_chart_tag(surface, {
            position = { x = current_closest.nest_x, y = current_closest.nest_y },
            text = "Center Nest",
            icon = { type = "item", name = "raw-fish" } -- Change icon if needed
          })
          local nests_to_remove = surface.find_entities_filtered({
            area = {
              { current_closest.entity.position.x - radius, current_closest.entity.position.y - radius },
              { current_closest.entity.position.x + radius, current_closest.entity.position.y + radius }
            },
            type = { "unit-spawner" }
          })
          game.print("the amount of nests to remove is: " .. #nests_to_remove)
          for _, nest in pairs(nests_to_remove) do
            nest.destroy()

            storage.patches_to_remove[resource_name] = storage.patches_to_remove[resource_name] - 1
            game.print("deleted nest")
          end
        else
          game.print("current closest entity is not valid")
        end
      end
    end
  end
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
  local car = player.surface.create_entity{
    name = "car",
    position = player.position,
    force = player.force
}
car.insert{name = "nuclear-fuel", count = 5} -- Add fuel to the car
player.print("You have received a car with nuclear fuel!")
end
