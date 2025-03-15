require "prototypes.biter-data"

function create_unique_spitter_puddle()
    local custom_projectile = table.deepcopy(data.raw[""])
    --[[ {
        type = "projectile",
        name = "biter-nest-acid-spit",
        acceleration = 0.005,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "acid-splash-fire"
                    }
                }
            }
        },
        animation = {
            filename = "__base__/graphics/entity/acid-projectile-purple/acid-projectile-purple.png",
            frame_count = 33,
            line_length = 11,
            width = 16,
            height = 18,
            shift = util.by_pixel(0, 0),
            scale = 0.5,
            tint = {r = 0.8, g = 0.1, b = 0.1, a = 1.0}
        },
        shadow = {
            filename = "__base__/graphics/entity/acid-projectile-purple/acid-projectile-purple-shadow.png",
            frame_count = 33,
            line_length = 11,
            width = 28,
            height = 16,
            shift = util.by_pixel(0, 0),
            scale = 0.5
        },
    } ]]
    data:extend(custom_projectile)
end