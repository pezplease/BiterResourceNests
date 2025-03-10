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