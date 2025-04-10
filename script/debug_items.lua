--[[  require "script.initilization"
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    give_player_starter_items(player)
  end)
  
  
  function give_player_starter_items(player)
    -- Ensure the player has car and nuclear fuel in their inventory
    local surface = game.surfaces["nauvis"]
    local car = player.surface.create_entity {
      name = "car",
      position = { player.position.x - 3, player.position.y + 2
      },
      force = player.force
    }
    car.insert { name = "nuclear-fuel", count = 2 } -- Add fuel to the car
    car.insert { name = "gun-turret", count = 50 }
    car.insert { name = "firearm-magazine", count = 100 }
    car.insert { name = "uranium-rounds-magazine", count = 2000 }
    car.insert { name = "stone-wall", count = 400 }
    car.insert { name = "cluster-grenade", count = 100 }
    car.insert { name = "stone-brick", count = 1000 }
  end
    ]]