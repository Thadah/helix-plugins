local PLUGIN = PLUGIN

PLUGIN.name = "Combine Chatter"
PLUGIN.description = "Hear combine chatter at random intervals."
PLUGIN.author = "Thadah Denyse"

ix.config.Add("combineChatterEnabled", ix.config.Get("combineChatterEnabled", true), "Whether or not Combine Chatter is enabled", nil, {
	category = "Combine Chatter"
})

ix.config.Add("combineChatterMinTime", 20, "The minimum time in seconds that will take for another chatter to happen", nil, {
    data = {min = 20, max = 3600},
    category = "Combine Chatter"
})

ix.config.Add("combineChatterMaxTime", 30, "The maximum time in seconds that will take for another chatter to happen", nil, {
    data = {min = 30, max = 7200},
    category = "Combine Chatter"
})


ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")