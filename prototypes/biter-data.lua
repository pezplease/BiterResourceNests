function specilized_biter_results(resource_type)
    biter_units = {
        {
            resource_type .. "-" .. "small-biter",
            {
                {
                    0,
                    0.3
                },
                {
                    0.6,
                    0
                }
            }
        },
        {
            resource_type .. "-" .. "medium-biter",
            {
                {
                    0,
                    .1
                },
                {
                    0.6,
                    0.3
                },
                {
                    0.7,
                    0.1
                }
            }
        },
        {
            resource_type .. "-" .. "big-biter",
            {
                {
                    0.2,
                    0
                },
                {
                    1,
                    0.4
                }
            }
        },
        {
            resource_type .. "-" .. "behemoth-biter",
            {
                {
                    0.85,
                    0
                },
                {
                    1,
                    0.3
                }
            }
        }
    }
    return biter_units
end

function specilized_spitter_results(resource_type)
    spitter_units = {
        {
            resource_type .. "-" .. "small-biter",
            {
                {
                    0,
                    0.3
                },
                {
                    0.35,
                    0
                }
            }
        },
        {
            resource_type .. "-" .. "small-spitter",
            {
                {
                    0,
                    0.3
                },
                {
                    0.35,
                    0.1
                },
                {
                    0.6,
                    0
                }
            }
        },
        {
            resource_type .. "-" .. "medium-spitter",
            {
                {
                    0.2,
                    0.2
                },
                {
                    0.7,
                    0.3
                },
                {
                    0.9,
                    0.1
                }
            }
        },
        {
            resource_type .. "-" .. "big-spitter",
            {
                {
                    0.2,
                    0.05
                },
                {
                    1,
                    0.4
                }
            }
        },
        {
            resource_type .. "-" .. "big-biter",
            {
                {
                    0.25,
                    0.01
                },
                {
                    1,
                    0.4
                }
            }
        },
        {
            resource_type .. "-" .. "behemoth-spitter",
            {
                {
                    0.75,
                    0
                },
                {
                    1,
                    0.15
                }
            }
        }
    }
    return spitter_units
end

--default list of biters for generic resource
biter_list = {
    "small-biter",
    "medium-biter",
    "big-biter",
    "behemoth-biter",
}
--specialized list of biters and spitters
spitter_list = {
    "small-biter",
    "medium-biter",
    "big-biter",
    "behemoth-biter",

    "small-spitter",
    "medium-spitter",
    "big-spitter",
    "behemoth-spitter",
}


generic_spawner_data = {
    name = "generic",
    color_data = {
         r = 0.3, g = 0.3, b = 0.3, a = 1
    },
    biter_data = {
        health_multiplier = 1.5,
        speed_multiplier = 0.75,
        damage_multiplier = 1.25,
    },
    unit_types = biter_list,
    spawner_data = {
        max_health = 10000,
        spawning_cooldown = { 2, 3 },
        max_units = 50,
    },
    resistance_data =
    {
        physdec = 10,
        physperc = 40,
        expdec = 0,
        expperc = 50,
        aciddec = 0,
        acidperc = 50,
        firedec = 0,
        fireperc = 50,
        laserdec = 0,
        laserperc = 50,
        elecdec = 0,
        elecperc = 50,
        poisdec = 0,
        poisperc = 50,
        impdec = 0,
        impperc = 50
    }
}
function create_biter_template(overrides)
    local function deep_copy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = deep_copy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end
    local template = deep_copy(generic_spawner_data)
    if overrides then
        for k, v in pairs(overrides) do
            if type(v) == "table" and type(template[k]) == "table" then
                for sub_k, sub_v in pairs(v) do
                    template[k][sub_k] = sub_v -- Override only specific sub-keys
                end
            else
                template[k] = v -- Override full values
            end
        end
    end

    return template
end

resource_list = {
    ["iron-ore"] = create_biter_template(
        {
            name = "iron-ore",
            biter_data = { health_multiplier = 1.8, speed_multiplier = 0.7 },
            color_data = { r = 0.45, g = 0.6, b = 0.9, a = 1 }
        }),

    ["generic"] = create_biter_template({ name = "generic" }),

    ["copper-ore"] = create_biter_template({
        name = "copper-ore",
        unit_types = spitter_list,
        color_data = { r = 0.803, g = 0.388, b = 0.215, a = 1 },
        --color_data = {}
    }),
    ["coal"] = create_biter_template({
        name = "coal",
        color_data = { r = 0.2, g = 0.2, b = 0.2, a = 1 },
        biter_overrides = {
            health_multiplier = 3,
            speed_multiplier = .4,
            damage_multiplier = 3,
        }
    }),
    ["stone"] = create_biter_template({
        name = "stone",
        color_data = { r = 0.95, g = 0.85, b = 0.75, a = 1 },
    }),
    ["uranium-ore"] = create_biter_template({
        name = "uranium-ore",
        color_data = { r = 0.25, g = 0.91, b = 0.25, a = 1 }
    }
    ),
    ["crude-oil"] = create_biter_template({
        name = "crude-oil",
        spawner_data = {
            max_health = 1000,
            spawning_cooldown = {8,12}
        },
        biter_data = {
            health_multiplier = 1.2,
            speed_multiplier = 1.33,
            damage_multiplier = 0.75,
        },
        color_data = { r = 0.89, g = 0.349, b = 0.588, a = 1 }
    })

}


function add_res_list_to_table(res_name, overrides)
        table.insert(resource_list, {
            [res_name] = create_biter_template(overrides)
        })
end
