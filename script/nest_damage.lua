--require "control"
require "script.initilization"
--deals damage to the spawner when a unit is spawned
script.on_event(defines.events.on_entity_spawned, function(event)
    local entityspawned = event.entity

    if entityspawned.type == "unit" then
      local spawner = event.spawner

  
      --deals damage to either active or inactive nests. #todo make dealing damage to inactive nests active.
      if spawner and spawner.valid and string.find(spawner.name, "active%-biter%-spawner") then
        local damage_amount = (105 * settings.global["resource-nests-nest-damage-taken-multiplier"].value) -- Adjust the damage as needed

        spawner.damage(damage_amount, spawner.force)
        for i, nest_info in pairs(storage.active_nests) do
          if nest_info.entity == spawner then

            nest_info.lastspawn = game.tick
            break
          end
        end
      end
    end
  end)
  