require "prototypes.biter-data"

local function shoot_boulder(spawner, resource_type, target_position)
    local angle = math.random() * math.pi * 2
    local surface = spawner.surface
    local target_coordinates
    if target_position then
        target_coordinates = target_position
    else
        target_coordinates = {
            spawner.position.x + (math.cos(angle) * math.random(15, 66)),
            spawner.position.y + (math.sin(angle) * math.random(15, 66))
        }
    end
    surface.create_entity({
        name = "boulder-stream-" .. resource_type,
        position = spawner.position,
        target = target_coordinates,
        speed = 0.25,
        source = spawner,
        force = game.forces.enemy,
        --target_type = spawner.surface,
    })
end

local function shoot_acid_stream(spawner, resource_type, target_position)
    local angle = math.random() * math.pi * 2
    local surface = spawner.surface
    local target_coordinates
    if target_position then
        target_coordinates = target_position
    else
        target_coordinates = {
            spawner.position.x + (math.cos(angle) * math.random(15, 66)),
            spawner.position.y + (math.sin(angle) * math.random(15, 66))
        }
    end
    surface.create_entity({
        name = "spitter-stream-" .. resource_type,
        position = spawner.position,
        target_position = target_coordinates,
        speed = .3,
        source = spawner,
        force = game.forces.enemy,

    })
end


local function find_nearby_turrets(spawner)
    local surface = spawner.surface
    -- Define the area around the spawner to search for turrets
    local radius = 35
    local area = {
        { spawner.position.x - radius, spawner.position.y - radius },
        { spawner.position.x + radius, spawner.position.y + radius }
    }
    local turrets = surface.find_entities_filtered {
        area = area,
        type = "ammo-turret"
    }

    if #turrets > 0 then
        return turrets[math.random(#turrets)].position -- Pick one turret at random
    else
        return nil
    end
end


--Checks nest type to determine which projectile to fire, and if it should fire at a turret or not.
local function projectile_type(spawner, resource_type)
    local target_position
    local roll = math.random()
    if roll < 0.2 then
        target_position = find_nearby_turrets(spawner)
    end

    if resource_list[resource_type].spawner_data.nest_attack == "boulder" then
        shoot_boulder(spawner, resource_type, target_position)
    elseif resource_list[resource_type].spawner_data.nest_attack == "spitter" then
        shoot_acid_stream(spawner, resource_type, target_position)
    elseif resource_list[resource_type].spawner_data.nest_attack == "both" then
        local roll = math.random()
        if roll <= 0.5 then
            shoot_acid_stream(spawner, resource_type, target_position)
        elseif roll > 0.5 then
            shoot_acid_stream(spawner, resource_type, target_position)
        end
    end
end
--called every nth tick. random chance to actually fire when called. 
function shoot_nest_projectile(spawner, resource_type)
    local roll = math.random()
    if roll < 0.3 then
        projectile_type(spawner, resource_type)
    elseif roll >= 0.3 then
    end
end
