require "prototypes.biter-data"
require "prototypes.resource-biters"
require "prototypes.nest-attack-data"

--create_unique_spitter_puddle()

setup_biter_corpses(resource_list)
--setup_resource_nest_corpse(resource_list)

--setup all biter types for each resource, with a generic fallback nest
setup_resource_biters(resource_list)

--setup all resource nests for each resource, with a generic fallback nest
setup_resource_nests(resource_list)
