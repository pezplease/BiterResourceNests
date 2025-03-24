require "prototypes.biter-data"


function create_unique_spitter_puddle(resource)
    local puddle = table.deepcopy(data.raw["fire"]["acid-splash-fire-spitter-behemoth"])
    puddle.name = "resource-puddle-" .. resource.name
    puddle.damage_per_tick = { amount = 10, type = "fire" }

    --puddle.burnt_patch_lifetime = 100
--[[     if puddle.working_visualisations then
        for _, layer in pairs(puddle.working_visualisations) do
            if layer.tint then
                layer.tint = resource.color_data
            end
        end
    end ]]
    if puddle.pictures then
        
    for _, picture in pairs(puddle.pictures) do
        if picture.layers then
         
     for _, layer in pairs (picture.layers) do
        
        if layer.tint then
            layer.tint = resource.color_data
        end
    end
end
end
end
    --[[ for _, layer in pairs (puddle.secondary_pictures.layers) do
        if layer.tint then
            layer.tint = resource.color_data
        end
    end  ]]


    return puddle
end

function create_unique_spitter_stream(resource)
    local custom_projectile = table.deepcopy(data.raw["stream"]["acid-stream-spitter-behemoth"])
    custom_projectile.name = "nest-projectile-" .. resource.name

    if custom_projectile.particle then
        custom_projectile.particle.tint = resource.color_data
    end

    --if custom_projectile.initial_action then
--[[         for _, effect in pairs(custom_projectile.initial_action) do
            if effect.type == "create-fire" then
                effect.entity_name = "resource-puddle-" .. resource.name
            end
        end ]]
    --end
    for _, initial in pairs (custom_projectile.initial_action) do
         
        for _, effect in pairs (initial.action_delivery.target_effects) do
            if effect.type == "create-fire" then
                effect.entity_name = "resource-puddle-" .. resource.name
            end
        end
    end

    return custom_projectile
end

function setup_nest_attacks(resource_list)
    local nest_attack_list = {}
    local nest_puddle_list = {}


    for _, resource in pairs(resource_list) do
        table.insert(nest_puddle_list, create_unique_spitter_puddle(resource))
    end

    data:extend(nest_puddle_list)

    for _, resource in pairs(resource_list) do
        local attack
        if resource.unit_types == spitter_list then
            attack = create_unique_spitter_stream(resource)
        else
            attack = create_unique_spitter_stream(resource)
        end
        table.insert(nest_attack_list, attack)
    end

    data:extend(nest_attack_list)
end
