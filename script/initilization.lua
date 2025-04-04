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

