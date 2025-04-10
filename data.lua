require "prototypes.biter-data"
require "prototypes.resource-biters"
require "prototypes.nest-attack-data"

--[[ add_res_list_to_table("jello", { name = "jello", unit_types = biter_list}) for the life of me i cant figure out why this fails]]
setup_nest_attacks(resource_list)

setup_biter_corpses(resource_list)
--setup_resource_nest_corpse(resource_list)

--setup all biter types for each resource, with a generic fallback nest
setup_resource_biters(resource_list)

--setup all resource nests for each resource, with a generic fallback nest
setup_resource_nests(resource_list)
