script.on_init(function()
  storage.active_nests = {}
  storage.last_biter_kill = 0
  storage.starting_patches = {
    ["iron-ore"] = 1,
    ["copper-ore"] = 1,
    ["coal"] = 1,
    ["stone"] = 1
  }
end)


local function position_key(position)
  -- Helper to create a unique key for a position
  return string.format("%d,%d", math.floor(position.x), math.floor(position.y))
end

local function get_connected_resources(surface, start_entity)
  -- Breadth-first search to collect all connected resource entities
  local visited = {}
  local to_visit = {start_entity}
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
          {entity.position.x - 1.5, entity.position.y - 1.5},
          {entity.position.x + 1.5, entity.position.y + 1.5},
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

local function is_starting_patch(resource_name, starting_patches)
  -- Check if the resource is one of the first iron, copper, coal, or stone patches
  return starting_patches[resource_name] and starting_patches[resource_name] > 0
end

script.on_event(defines.events.on_chunk_generated, function(event)
  local surface = event.surface
  local area = event.area
  local settings_enabled = false --settings.storage["starting-resource-spawners"].value



  -- Track first patches of each resource type
  if storage.starting_patches == nil then
    storage.starting_patches = {
      ["iron-ore"] = 1,
      ["copper-ore"] = 1,
      ["coal"] = 1,
      ["stone"] = 1
    }
  end

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
        if storage.starting_patches[resource_name] and storage.starting_patches[resource_name] > 0
        then
          storage.starting_patches[resource_name] = storage.starting_patches[resource_name] - 1
          --debug steel chest, lol
          surface.create_entity({
            name = "steel-chest",
            position = {x = center_x, y = center_y},
          })
        else
        -- Scale strength based on patch size
        local patch_size = #patch_resources -- Ensure this variable is set
        local nest_type
          if patch_size > 300 then
           nest_type = "self-damaging-spawner" 
          else
           nest_type = "self-damaging-spawner"
          end

        surface.create_entity({
          name = nest_type,
          position = {x = center_x, y = center_y},
          force = "enemy", -- Makes it hostile
          active = "false"
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
      local nests = entity.surface.find_entities_filtered{
          name = "self-damaging-spawner",
          position = entity.position,
          radius = 32
      }
      for _, nest in pairs(nests) do

          nest.active = true
      end
end)


--[[
script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  if entity and entity.name == "small-biter" then
      storage.last_biter_kill = game.tick
  end
end)


script.on_nth_tick(60, function()
  if storage.last_biter_kill and (game.tick - storage.last_biter_kill > 300) then
      for _, nest in pairs(storage.active_nests or {}) do
          nest.active = false
      end
  end
end)
--]]

function table.contains(tbl, element)
  for _, value in pairs(tbl) do
      if value == element then
          return true
      end
  end
  return false
end
