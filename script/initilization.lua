require "script.patch_nest_creation"

script.on_init(function()
  storage.spawned_nests = {}
  storage.chunk_resource_spillover_check = {}

  --storage.last_biter_kill = 0
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

  storage.mod_previously_initialized = false
  storage.remove_patches = settings.startup["resource-nests-starting-resource-exemption"].value
  --old_map_conversion()
  remove_normal_nests_check()
end)

script.on_configuration_changed(function(data)
  if not storage.chunk_resource_spillover_check then
    storage.chunk_resource_spillover_check = {}
  end
end)


function old_map_conversion()
  -- Check if the map was created before the mod was installed
  if storage.mod_previously_initialized == true then return end

  local surface = game.surfaces["nauvis"]
  storage.mod_previously_initialized = true
  for chunk in surface.get_chunks() do
    if surface.is_chunk_generated(chunk) then
      local area = chunk.area
      chunk_resource_checker(chunk, surface)
    end
  end
end

--[[ script.on_load(function()
  --if storage.mod_previously_initialized == false then
    old_map_conversion()
  --end
end)
 ]]

function remove_normal_nests()
    local surface = game.surfaces["nauvis"]
  local map_settings = surface.map_gen_settings
  map_settings.autoplace_controls["enemy-base"] = { frequency = "none", size = "none", richness = "none" }
  surface.map_gen_settings = map_settings
  for _, entity in pairs(surface.find_entities_filtered { type = { "unit", "turret" }, force = "enemy" }) do
    entity.destroy()
  end
  for _, entity in pairs(surface.find_entities_filtered { name = "biter-spawner", force = "enemy" }) do
    entity.destroy()
  end
  for _, entity in pairs(surface.find_entities_filtered { name = "spitter-spawner", force = "enemy" }) do
    entity.destroy()
  end
end

function remove_normal_nests_check()
  if settings.startup["resource-nests-remove-normal-nests"].value == true then
   remove_normal_nests()
  end
end

function destroy_all_nests_in_starting_area()
  if settings.startup["resource-nests-destroy-all-starting-nests"].value == true then
    local surface = game.surfaces["nauvis"]
    local area = {
      { -4000, -4000 },
      { 4000,  4000 }
    }

    -- Find all resource nests in the starting area
    local nests = surface.find_entities_filtered {
      area = area,
      type = "unit-spawner",
    }

    -- Destroy each nest found
    for _, nest in pairs(nests) do
      if nest.valid then
        nest.destroy()
      end
    end
  end
end

function delete_first_resource_nest_in_list()
  if not storage.spawned_nests or not storage.remove_patches then return end


  local closest_nests = {}
  for resource_name, resource_count in pairs(storage.patches_to_remove) do
    if storage.patches_to_remove[resource_name] < 1 then break end
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
      storage.patches_to_remove[closest_nest.resource_name] = storage.patches_to_remove[closest_nest.resource_name] - 1
      -- Add chart tag

      -- Destroy the entity
      local radius = 44
      local nests_to_remove = surface.find_entities_filtered({
        area = {
          { closest_nest.entity.position.x - radius, closest_nest.entity.position.y - radius },
          { closest_nest.entity.position.x + radius, closest_nest.entity.position.y + radius }
        },
        type = { "unit-spawner" }
      })

      for _, nest in pairs(nests_to_remove) do
        nest.destroy()
      end
    end
  end
end
