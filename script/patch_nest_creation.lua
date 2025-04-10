
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
  -- if surface == "nauvis" then
    chunk_resource_checker(area, surface)
   --end
    -- Find all resources in the chunk

  end)
  

  function chunk_resource_checker(area, surface)
    local processed = {}
      local resource_entities = surface.find_entities_filtered({
      area = area,
      type = "resource"
    })
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
          local building_check = surface.find_entities_filtered{
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
            position = {x = center_x, y = center_y},
            radius = 12
          }
          if #nearbyresourcenests == 0 then
                    local spawned_nest = surface.create_entity({
            name = nest_type,
            position = { x = center_x, y = center_y },
            force = "enemy", -- Makes it hostile
  
          })
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