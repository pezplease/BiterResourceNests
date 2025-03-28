require "prototypes.biter-data"

local function shoot_boulder(spawner, resource_type)
    local angle = math.random() * math.pi * 2
    local surface = spawner.surface
    surface.create_entity({
        name = "boulder-stream-" .. resource_type,
        position = spawner.position,
        target = {
            spawner.position.x + (math.cos(angle) * math.random(15, 40)),
            spawner.position.y + (math.sin(angle) * math.random(15, 40))
        },
        speed = 0.5,
        source = spawner,
        force = game.forces.enemy,
        --target_type = spawner.surface,
    })
end

local function shoot_acid_stream(spawner, resource_type)
    local angle = math.random() * math.pi * 2
    local surface = spawner.surface
    local target_position = {
        x = spawner.position.x + math.cos(angle) * 20,
        y = spawner.position.y + math.sin(angle) * 20
    }
    surface.create_entity({
        name = "spitter-stream-" .. resource_type,
        position = spawner.position,
        target_position = target_position,
        speed = .3,
        source = spawner,
        force = game.forces.enemy,

    })
end

function shoot_nest_projectile(spawner, resource_type)
    if resource_list[resource_type].spawner_data.nest_attack == "boulder" then
        shoot_boulder(spawner, resource_type)
    elseif resource_list[resource_type].spawner_data.nest_attack == "spitter" then
        shoot_acid_stream(spawner, resource_type)
    elseif resource_list[resource_type].spawner_data.nest_attack == "both" then
        local roll = math.random()
        if roll < 0.6 then
            shoot_boulder(spawner, resource_type)
            shoot_acid_stream(spawner, resource_type)
        elseif roll > 0.6 and roll < 0.75 then
            shoot_acid_stream(spawner, resource_type)
        elseif roll >= 0.75 then
            shoot_acid_stream(spawner, resource_type)
        end
    end
end
