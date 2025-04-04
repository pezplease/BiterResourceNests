--get all resource data for the resource types
require "prototypes.biter-data"

--sets up all biter storage and removes normal nests if enabled.
require "script.initilization"

--checks all patches and creates nests
require "script.patch_creation"
--triggers attacks on active nests
require "script.nest_attack"
--debug items to test the mod
require "script.debug_items"
--deals damage to nests when a unit is spawned
require "script.nest_damage"
--checks if a player mines a resource or places a miner near a patch and activates the nest
require "script.nest_activation"

--check nest activity checks to see if an active nest is still being attacked,
-- if still under attack, will launch a projectile.
script.on_nth_tick(75, function()
  check_nest_activity()
  deleteallstartingnests()
end)


