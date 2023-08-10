local PLUGIN = PLUGIN

PLUGIN.name = "Entity Finder"
PLUGIN.author = "Thadah Denyse"
PLUGIN.desc = "Finds entities"

ix.command.Add("findentity", {
	description = "Finds an entity by model and shows its position",
	adminOnly = true,
	arguments = {
		ix.type.string
	},
	OnRun = function(self, client, model)
		for k, v in ipairs( ents.FindByClass( model ) ) do
			print( v:GetPos() )
		end
	end
})

ix.command.Add("findentities", {
	description = "Finds any prop entity and shows its position",
	adminOnly = true,
	OnRun = function(self, client)
		for k, v in ipairs( ents.FindByClass( "prop_*" ) ) do
			print(v:GetModel())
			print( v:GetPos() )
			print()
		end
	end
})
