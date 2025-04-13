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
  --Find all resources in the chunk
  --if surface == "nauvis" then
  chunk_resource_checker(event, surface)
  --end
end)

function check_cutoff_patches_again()
  --broken. not in use currently
  if storage.chunk_resource_spillover_check then
    for _, resource in pairs(storage.chunk_resource_spillover_check) do
      if not resource.rechecked then
        -- Check if the chunk is generated
        local area = {
          { resource.x - 80, resource.y - 80 },
          { resource.x + 80, resource.y + 80 }
        }
        local surface = resource.surface
        resource.rechecked = true

        chunk_resource_checker(resource, surface)
      end
    end
  end
  storage.chunk_resource_spillover_check = nil
end

local function patch_touches_ungenerated_chunks(surface, patch_resources)
  for _, res in pairs(patch_resources) do
    local x, y = res.position.x, res.position.y
    local lx, ly = x % 32, y % 32

    local check_positions = {}
    if lx == 0 then table.insert(check_positions, { x = x - 1, y = y }) end
    if lx == 31 then table.insert(check_positions, { x = x + 1, y = y }) end
    if ly == 0 then table.insert(check_positions, { x = x, y = y - 1 }) end
    if ly == 31 then table.insert(check_positions, { x = x, y = y + 1 }) end

    for _, pos in pairs(check_positions) do
      local cx = math.floor(pos.x / 32)
      local cy = math.floor(pos.y / 32)
      if not surface.is_chunk_generated({ x = cx, y = cy }) then
        surface.request_to_generate_chunks({ x = cx, y = cy }, 0)
        return true -- Touches an ungenerated chunk
      end
    end
  end

  return false
end
local function check_all_adjacent_chunks(surface, x, y)
  --checks if all adjacent chunks are generated
  local was_chunk_missing = false
  if not surface.is_chunk_generated({ x = x - 32, y = y }) then
    surface.request_to_generate_chunks({ x = x - 32, y = y }, 0)
    was_chunk_missing = true
  end
  if not surface.is_chunk_generated({ x = x + 32, y = y }) then
    surface.request_to_generate_chunks({ x = x + 32, y = y }, 0)
    was_chunk_missing = true
  end
  if not surface.is_chunk_generated({ x = x, y = y - 32 }) then
    surface.request_to_generate_chunks({ x = x, y = y - 32 }, 0)
    was_chunk_missing = true
  end
  if not surface.is_chunk_generated({ x = x, y = y + 32 }) then
    surface.request_to_generate_chunks({ x = x, y = y + 32 }, 0)
    was_chunk_missing = true
  end




  return was_chunk_missing
end


function chunk_resource_checker(chunk, surface)
  local processed = {}
  local check_area = {
    --adds 32 to each side of the chunk to check for resources in the adjacent chunks
    { chunk.area.left_top.x - 32, chunk.area.left_top.y - 32 },
    { chunk.area.right_bottom.x + 32, chunk.area.right_bottom.y + 32 },
  }
  --local check_y = chunk.position.y - 32
  local resource_entities = surface.find_entities_filtered({
    area = check_area,
    type = "resource"
  })
  for _, resource in pairs(resource_entities) do
    local pos_key = position_key(resource.position)
    if not processed[pos_key] then
      -- Get all connected resources for this patch
      local patch_resources = get_connected_resources(surface, resource)

      --[[       local chunk_touching_ungenerated = false
      for _, resource_entity in pairs(patch_resources) do
        local chunk_x = math.floor(resource_entity.position.x / 32)
        local chunk_y = math.floor(resource_entity.position.y / 32)
        local chunk_pos = { x = chunk_x, y = chunk_y }

        if not surface.is_chunk_generated(chunk_pos) then
          chunk_touching_ungenerated = true
          break
        end
      end

      if chunk_touching_ungenerated then
        return  -- abort spawner placement for this patch. will be checked again when the chunk is generated.
      end]]
--[[       if already_checked then
      else
        if patch_resources and patch_resources[1] and check_all_adjacent_chunks(surface, patch_resources[1].position.x, patch_resources[1].position.y) then
          game.print("Chunk touches ungenerated chunks. Requesting chunk generation.") 
          local recheck_data = {
            x = patch_resources[1].position.x,
            y = patch_resources[1].position.y,
            surface = patch_resources[1].surface,
            rechecked = false
          }
          if recheck_data == nil then 
          else
          table.insert(storage.chunk_resource_spillover_check, recheck_data)
          -- abort spawner placement for this patch because it touches ungenerated chunks.
          -- the function `request_to_generate_chunks` is called to ensure the necessary chunks are generated.
          -- will be rechecked later when the chunk generation is complete.
          return
          end
        end
      end ]]
      -- Mark resources as processed
      for _, patch_resource in pairs(patch_resources) do
        processed[position_key(patch_resource.position)] = true
      end
      -- Check if the patch touches ungenerated chunks

      --[[        if patch_touches_ungenerated_chunks(surface, patch_resources) then
        game.print("Chunk touches ungenerated chunks. Requesting chunk generation.")
        local x, y = patch_resources[1].position.x, patch_resources[1].position.y
        table.insert(storage.chunk_resource_spillover_check, {x = x, y = y, surface = surface})
        return  -- abort spawner placement for this patch. will call request_to_generate_chunks and try again.
      end ]]



      -- Calculate the geometric center of the patch
      if #patch_resources > 0 then
        local center_x, center_y = 0, 0
        for _, patch_resource in pairs(patch_resources) do
          center_x = center_x + patch_resource.position.x
          center_y = center_y + patch_resource.position.y
        end
        center_x = center_x / #patch_resources
        center_y = center_y / #patch_resources



        -- Scales amount of nests based on patch size and distance from spawn.
        local distance_from_spawn = math.sqrt(center_x ^ 2 + center_y ^ 2)
        local patch_size = #patch_resources
        local patch_size_maximum = 750
        local nest_minimum = 1
        if resource.name == "crude-oil" then
          patch_size_maximum = 8
          nest_minimum = 3
        end
        local normalized_patch_size = math.min(patch_size / patch_size_maximum, 0.2)
        local normalized_distance = math.min(distance_from_spawn / 5500, 1.8)
        local nest_count = math.floor(nest_minimum + 16 * ((normalized_patch_size + normalized_distance) / 2))

        game.print("Nest count: " ..
          nest_count ..
          " for patch size: " .. patch_size .. " and distance: " .. distance_from_spawn .. ". Resource:" .. resource
          .name)

        local attempts = 0
        local spawned = 0
        local max_attempts = 30
        local building_check = surface.find_entities_filtered {
          area = {
            { center_x - 55, center_y - 55 },
            { center_x + 55, center_y + 55 },
          },
          force = "player",
        }
        --checks to make sure the nests have sufficient spacing,
        --and in the case of adding the mod to existing saves, makes sure there are not any player buildings on the nest already
        if #building_check == 0 then
          local nest_type = "inactive-biter-spawner-generic"
          for _, resource_table_data in pairs(resource_list) do
            local resource_table = resource_table_data.name
            if resource_table == resource.name then
              nest_type = "inactive-biter-spawner-" .. resource.name
              break
            end
          end

          local surface = game.surfaces["nauvis"]

          local nearbyresourcenests = surface.find_entities_filtered {
            name = nest_type,
            position = { x = center_x, y = center_y },
            radius = 30,
          }
          --if the patch is empty, spawn the nests
          if #nearbyresourcenests == 0 then
            while spawned < nest_count and attempts < max_attempts do
              attempts = attempts + 1

              local angle = math.random() * 2 * math.pi
              local radius = math.random() * (3 * nest_count) + 8
              local x = center_x + math.cos(angle) * radius
              local y = center_y + math.sin(angle) * radius

              local spawned_nest = surface.create_entity({
                name = nest_type,
                position = { x = x, y = y },
                force = "enemy", -- Makes it hostile
              })
              if spawned_nest then
                spawned = spawned + 1
              end
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
    end
  end
end
