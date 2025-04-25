require "prototypes.biter-data"

local function create_boulder_impact(resource)
    local boulder_impact = {
        type = "explosion",
        damage_per_tick = { amount = 50, type = "fire" },
        name = "boulder-impact-" .. resource.name,
        spread_delay = 150,
        spread_delay_deviation = 50,
        animations = {
            {
                animation_speed = 0.5,
                draw_as_glow = true,
                filename = "__base__/graphics/entity/medium-explosion/medium-explosion-1.png",
                frame_count = 30,
                height = 224,
                line_length = 6,
                priority = "high",
                scale = 0.5,
                shift = {
                    -0.03125,
                    -1.125
                },
                usage = "explosion",
                width = 124
            },
            {
                animation_speed = 0.5,
                draw_as_glow = true,
                filename = "__base__/graphics/entity/medium-explosion/medium-explosion-2.png",
                frame_count = 41,
                height = 212,
                line_length = 6,
                priority = "high",
                scale = 0.5,
                shift = {
                    -0.40625,
                    -1.0625
                },
                usage = "explosion",
                width = 154
            },
            {
                animation_speed = 0.5,
                draw_as_glow = true,
                filename = "__base__/graphics/entity/medium-explosion/medium-explosion-3.png",
                frame_count = 39,
                height = 236,
                line_length = 6,
                priority = "high",
                scale = 0.5,
                shift = {
                    0.015625,
                    -1.15625
                },
                usage = "explosion",
                width = 126
            }
        },
        light = { intensity = 0.6, size = 5 },
        sound = {
            {
                filename = "__base__/sound/fight/medium-explosion-1.ogg",
                volume = 0.7
            }
        },
        created_effect = {

            type = "area",
            radius = 5.5,         -- aoe radius
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "damage",
                        damage = { amount = (125 * resource.biter_data.damage_multiplier), type = resource.damage_type },
                        apply_damage_to_trees = true
                    },
                    {
                        type = "create-entity",
                        entity_name = "small-scorchmark",
                        check_buildability = true
                    }
                --}
            }
        }
        },
    }

    return boulder_impact
end

local function create_boulder_projectile(resource)
    local boulder_projectile = table.deepcopy(data.raw["projectile"]["grenade"])
    boulder_projectile.name = "boulder-stream-" .. resource.name
    boulder_projectile.horizontal_speed = 0.2
    boulder_projectile.direction_only = false
    boulder_projectile.collision_box = {{-1, -1}, {1, 1}}
    boulder_projectile.force_condition = "not-same"



    --boulder_projectile.particle_horizontal_speed_deviation = 0.05
    --boulder_projectile.acceleration = -0.005  -- arc
    --boulder_projectile.spine_animation = {
    --boulder_projectile.direction_only = true
    boulder_projectile.animation = {
        filename = "__base__/graphics/decorative/big-rock/big-rock-07.png",
        width = 141,
        height = 128,
        scale = 0.5,
        tint = resource.color_data
    }
    boulder_projectile.final_action = {
        {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "boulder-impact-" .. resource.name,
                    }
                }
            }
        }
    }
    --boulder_projectile.working_sound = nil  -- Remove acid sounds
    boulder_projectile.action = {
        {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "create-trivial-smoke",
                        smoke_name = "soft-fire-smoke",
                        repeat_count = 10

                    }
                }
            }
        }
    }
    return boulder_projectile
end

local function create_unique_spitter_puddle(resource)
    local puddle = table.deepcopy(data.raw["fire"]["fire-flame"])
    puddle.type = "fire"
    puddle.name = "resource-puddle-" .. resource.name
    puddle.damage_per_tick = { amount = (.5 * resource.biter_data.damage_multiplier), type = resource.damage_type }
    puddle.maximum_spread_count = 4005       
    puddle.spread_delay = 15             
    puddle.spread_delay_deviation = 8
    puddle.flame_spread_delay = 10
    puddle.flame_spread_deviation = 15
    puddle.spread_radius = 150
    puddle.initial_lifetime = 4300
    puddle.initial_flame_count = 35


    local fire_color = resource.color_data
    if resource.name == "coal" then
        fire_color = { 0.95, 0.95, 0.75, 1} -- makes fire more normal for coal
    end
    puddle.light.color = fire_color

    --puddle.tint = resource.color_data
     if puddle.pictures then
        for _, picture in pairs(puddle.pictures) do
            if picture.tint then
                picture.tint = fire_color
            end
            if picture.layers then
                --picture.scale = 1
                for _, layer in pairs(picture.layers) do
                    --layer.scale = 1
                    if layer.tint then
                        layer.tint = fire_color
                    end
                end
            end
        end
    end 

    return puddle
end


local function create_unique_spitter_stream(resource)
    local custom_projectile = table.deepcopy(data.raw["stream"]["acid-stream-spitter-behemoth"])
    custom_projectile.name = "spitter-stream-" .. resource.name

    if custom_projectile.particle then
        custom_projectile.particle.tint = resource.color_data
    end

    for _, initial in pairs(custom_projectile.initial_action) do
        for _, effect in pairs(initial.action_delivery.target_effects) do
--[[             if effect.type == "create-entity" then 
                effect.entity_name = "resource-cluster-" .. resource.name
             ]]
            if effect.type == "create-fire" then
                effect.entity_name = "resource-puddle-" .. resource.name
            end
        end
    end

    return custom_projectile
end

function setup_nest_attacks(resource_list)
    local nest_projectile_impact_list = {}
    local nest_projectile_cluster_list = {}


    local nest_attack_list = {}
    local nest_puddle_list = {}


    for _, resource in pairs(resource_list) do
        table.insert(nest_projectile_impact_list, create_boulder_impact(resource))
    end
    data:extend(nest_projectile_impact_list)

--[[ 
    for _, resource in pairs(resource_list) do
        table.insert(nest_projectile_cluster_list, create_unique_cluster_puddle(resource))
    end ]]
    --data:extend(nest_projectile_cluster_list)
    --[[     for _, resource in pairs(resource_list) do
        table.insert(nest_projectile_stream_list, create_boulder_projectile(resource))
    end ]]



    for _, resource in pairs(resource_list) do
        table.insert(nest_puddle_list, create_unique_spitter_puddle(resource))
    end

    data:extend(nest_puddle_list)

    for _, resource in pairs(resource_list) do
        local attack
        --if resource.unit_types == spitter_list then
        attack1 = create_unique_spitter_stream(resource)
        --else
        attack2 = create_boulder_projectile(resource)
        --end
        table.insert(nest_attack_list, attack1)
        table.insert(nest_attack_list, attack2)
    end

    data:extend(nest_attack_list)
end
