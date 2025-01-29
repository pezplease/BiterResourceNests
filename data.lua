local fireArmor = table.deepcopy(data.raw["armor"]["heavy-armor"]) -- copy the table that defines the heavy armor item into the fireArmor variable

fireArmor.name = "fire-armor"
fireArmor.icons = {
  {
    icon = fireArmor.icon,
    icon_size = fireArmor.icon_size,
    tint = {r=1,g=0,b=0,a=0.3}
  },
}

local cheatgun = table.deepcopy(data.raw["armor"]["heavy-armor"])

fireArmor.resistances = {
  {
    type = "physical",
    decrease = 6,
    percent = 10
  },
  {
    type = "explosion",
    decrease = 10,
    percent = 30
  },
  {
    type = "acid",
    decrease = 5,
    percent = 30
  },
  {
    type = "fire",
    decrease = 0,
    percent = 100
  }
}

-- create the recipe prototype from scratch
local recipe = {
  type = "recipe",
  name = "fire-armor",
  enabled = true,
  energy_required = 8, -- time to craft in seconds (at crafting speed 1)
  ingredients = {
    {type = "item", name = "copper-plate", amount = 2}
  },
  results = {{type = "item", name = "fire-armor", amount = 1}}
}

data:extend{fireArmor, recipe}
data:extend({
  {
    type = "simple-entity",
    name = "resource-patch-marker",
    icon = "__base__/graphics/icons/small-biter.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    picture = {
      filename = "__base__/graphics/icons/small-biter.png",
      width = 64,
      height = 64,
      scale = 0.5
    }
  }
})

--biter nest variations
local largebiterspawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
largebiterspawner.name = "largebiterspawner"
data:extend({largebiterspawner})

local custom_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
custom_spawner.name = "self-damaging-spawner"
custom_spawner.icon = "__base__/graphics/icons/biter-spawner.png"
custom_spawner.max_health = 3000
custom_spawner.healing_per_tick = .5
custom_spawner.max_count_of_owned_units = 300
custom_spawner.max_defensive_friends_around_to_spawn = 0
custom_spawner.spawning_cooldown = {12, 25} -- Can spawn faster
custom_spawner.active = false
custom_spawner.resistances = {
  {
    type = "physical",
    decrease = 10,
    percent = 99
  },
  {
    type = "explosion",
    decrease = 10,
    percent = 99
  },
  {
    type = "acid",
    decrease = 5,
    percent = 99
  },
  {
    type = "fire",
    decrease = 0,
    percent = 99
  }
}
--custom_spawner.animations[1].filename = "__your-mod-name__/graphics/self-damaging-spawner.png"

data:extend({custom_spawner})

--[[
test
data:extend({
  {
    type = "unit-spawner",
    name = "large-biter-spawner",
    icon = "__base__/graphics/icons/biter-spawner.png",
    icon_size = 64,
    max_health = 1000,
    spawning_cooldown = {200, 100},
    result_units = {{"big-biter", {{0.0, 1.0}, {0.7, 0.4}}}}
  }
})
]]