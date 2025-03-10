require "prototypes.biter-data"
require "prototypes.resource-biters"


--remote.add_interface("resource_list", {
--  get_resource_list = function()
--    return resource_types
--  end
--})

--creates the data for the biters and nests
add_res_list_to_table(resource_list)


--setup all biter types for each resource, with a generic fallback nest
setup_resource_biters(resource_types)
setup_resource_biters(default_nest)

--setup all resource nests for each resource, with a generic fallback nest
setup_resource_nests(resource_types)
setup_resource_nests(default_nest)
