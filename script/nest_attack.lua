function shoot_nest_projectile(spawner, resource_type)
    local angle = math.random() * math.pi * 2  -- Random direction
    local speed = 0.3  -- Adjust as needed
    --local force = game.forces.enemy  -- Or another force if needed
    local surface = spawner.surface

    
    surface.create_entity({
        name = "nest-projectile-" .. resource_type,
        position = spawner.position,
        target_position = {
            spawner.position.x + math.cos(angle) * 15,
            spawner.position.y + math.sin(angle) * 15
        },
        speed = speed,
        source = spawner,
        force = game.forces.enemy,
    })
end