require "prototypes.biter-data"

function create_unique_spitter_puddle(resource)
    local custom_projectile = table.deepcopy(data.raw["stream"]["acid-stream-spitter-behemoth"])
    custom_projectile.name = "nest-projectile-" .. resource.name

    if custom_projectile.particle then
        custom_projectile.particle.tint = resource.color_data
    end


    return custom_projectile
end

function setup_nest_attacks(resource_list)
    local nest_attack_list = {}


    for _, resource in pairs(resource_list) do
        local attack
        if resource.unit_types == spitter_list then
            attack = create_unique_spitter_puddle(resource)
        else
            attack = create_unique_spitter_puddle(resource)
        end
        table.insert(nest_attack_list, attack)
    end

    data:extend(nest_attack_list)
end
