--get all resource data for the resource types
require "prototypes.biter-data"

--sets up all biter storage and removes normal nests if the setting is enabled.
require "script.initilization"

--checks all patches and creates nests
require "script.patch_nest_creation"
--triggers attacks on active nests
require "script.nest_attack"
--debug items to test the mod
require "script.debug_items"
--deals damage to nests when a unit is spawned
require "script.nest_damage"
--checks if a player mines a resource or places a miner near a patch and activates the nest
require "script.nest_activation"

--allows players to use console commands to remove normal biters when migrating the mod to an existing map
require "script.console_commands"

script.on_nth_tick(25, function()
--check nest activity checks to see if an active nest is still being attacked,
-- if still under attack, will launch a projectile.
  
  check_nest_activity()

  --if enabled, removes the first resource of every type that apears in the init file on the map..
  delete_first_resource_nest_in_list()
  
  --if adding the mod to an existing map, will add resource nests to all uninhabited resource chunks
  old_map_conversion()

  --check_cutoff_patches_again()
end)


