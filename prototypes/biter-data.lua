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
                    0.2,
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
                    0.1
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

--resource nest colors
resource_colors = {
    ["iron-ore"] = { r = 0.45, g = 0.6, b = 0.9, a = 1 },
    ["copper-ore"] = { r = 0.803, g = 0.388, b = 0.215, a = 1 },
    ["coal"] = { r = 0.2, g = 0.2, b = 0.2, a = 1 },
    ["stone"] = { r = 0.95, g = 0.8, b = 0.7, a = 1 },
    ["uranium-ore"] = { r = 0.25, g = 0.91, b = 0.25, a = 1 },
    ["crude-oil"] = { r = 0.89, g = 0.349, b = 0.588, a = 1 }
}
resource_types = {
    "iron-ore",
    "copper-ore",
    "coal",
    "stone",
    "uranium-ore",
    "crude-oil"
}
default_nest = {
    "generic-nest"
}

resource_units = {
    ["copper-ore"] = spitter_list
}

resource_overrides = {
    ["iron-ore"] = {
        max_health = 5000,
        spawning_cooldown = { 2, 3 },
    },
    ["copper-ore"] = {
        max_health = 7800
        --results_units = specilized_spitter_results,
    },
    ["crude-oil"] = {
        max_health = 1000,
        spawning_cooldown = { 33, 35 },
    }
}

biter_overrides = {
    ["generic"] = {
        health_multiplier = 1.5,
        speed_multiplier = 0.75,
        damage_multiplier = 1.25,
    },
    ["stone"] = {
        health_multiplier = 3,
        speed_multiplier = .3
    }
}
