local PLUGIN = PLUGIN

PLUGIN.name = "Loot Containers"
PLUGIN.author = "Chessnut, Thadah Denyse"
PLUGIN.desc = "Spawns different containers that can be looted"

ix.util.Include("sv_containers.lua")
ix.util.Include("sh_networking.lua")
ix.util.Include("sh_categoriesrarities.lua")
ix.util.Include("sh_models.lua")

ix.config.Add("lootEnabled", true, "Whether or not Loot Containers is enabled.", nil, {category = "Loot Containers"})
ix.config.Add("lootPersistentCointainers", true, "Whether or not the containers will survive server restarts.", nil, {category="Loot Containers"})
ix.config.Add("lootCount", 10, "Maximum number of items each container will have inside.", nil, {data = {min = 1, max = 20}, category = "Loot Containers"})
ix.config.Add("lootMaxContainerSpawn", 1, "Number of containers each spawn will have.", nil, {data = {min = 1, max = 50}, category = "Loot Containers"})
ix.config.Add("lootMaxWorldContainers", 6, "Number of containers the World will have.", nil, {data = {min = 1, max = 20}, category = "Loot Containers"})
ix.config.Add("lootContainerTime", 20, "How much time it will take for a container to spawn.", nil, {data = {min = 1, max = 86400}, category = "Loot Containers"})
ix.config.Add("lootContainerDeathTime", 120, "How much time it will take for a container to dissapear (in seconds).", nil, {data = {min = 10, max = 84600}, category = "Loot Containers"})



ix.command.Add("LootAddSpawn", {
	description = "Add a new container spawnpoint",
	adminOnly = true,
	arguments = {
		ix.type.string
	},
	OnRun = function(self, client, model)
		local location = client:GetEyeTrace().HitPos
		location.z = location.z + 10
		PLUGIN:AddSpawner(location, model)
		client:Notify("You've added a new container spawner")
	end
})

ix.command.Add("LootRemoveSpawn", {
	description = "Remove all spawnpoints within a distance",
	adminOnly = true,
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, distance)
		local location = client:GetEyeTrace().HitPos
		local count = PLUGIN:RemoveSpawners(location, distance)
		client:Notify(count.." spawners have been removed")
	end
})


ix.command.Add("LootDisplaySpawn", {
	description = "Display all spawnpoints with a light",
	adminOnly = true,
	OnRun = function(self, client)
		if SERVER then
			net.Start("nutDisplayContSpawnPoints")
				net.WriteTable(PLUGIN.spawners)
			net.Send(client)
			client:Notify("Displaying all container spawnpoints for 15 seconds")
		end
	end
})