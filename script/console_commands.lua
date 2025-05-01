require "script.initilization"
commands.add_command("remove_normal_nests", "Removes all vanilla biter spawners and units from the map", function(command)
    remove_normal_nests()
end)
commands.add_command("clean_up_biter_nests", "Checks all resource nests in the map and makes sure they're actually on a resource", function(command)
    check_resource_nests("nauvis")
end)