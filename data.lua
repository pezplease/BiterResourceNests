require "prototypes.biter-data"
require "prototypes.resource-biters"


--remote.add_interface("resource_list", {
--  get_resource_list = function()
--    return resource_types
--  end
--})

setup_biter_corpses(resource_list)
--setup_resource_nest_corpse(resource_list)

--setup all biter types for each resource, with a generic fallback nest
setup_resource_biters(resource_list)
--setup_resource_biters(default_nest)

--setup all resource nests for each resource, with a generic fallback nest
setup_resource_nests(resource_list)
--setup_resource_nests(default_nest)
