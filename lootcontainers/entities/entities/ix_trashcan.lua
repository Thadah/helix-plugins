local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Trashcan"
ENT.Category = "Helix"
ENT.Author = "DrM"
ENT.Spawnable = false
ENT.bNoPersist = true

if (SERVER) then

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.receivers = {}

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Wake()
		end
		
		self.canUse = true
	end
	
	function ENT:Use(activator)
		local character = activator:GetCharacter()
		
		if (activator:Team() == FACTION_CITIZEN or activator:Team() == FACTION_CWU or activator:Team() == FACTION_LAMBDARESISTANCE or activator:Team() == FACTION_LAMBDARESISTANCELEADER or activator:Team() == FACTION_BMD  or activator:Team() == FACTION_CMU or activator:Team() == FACTION_VORTIGAUNT --[[or activator:Team() == FACTION_CWU]]) then
			self.canUse = false
				if (character:GetData("trashcan"..self.id, 0) < os.time()) then
					activator:SetAction("Searching Trashcan",ix.config.Get("trashcanSearchTime"))
					activator:DoStaredAction(self, function()
						local inventory = character:GetInventory()
						local category = PLUGIN:chooseRandom()
						local name = "Missing string"

						local items = math.random(1,ix.config.Get("trashAmount"))
						for i=1, items do
							local item = table.Random(PLUGIN.category[category])
							inventory:Add(item)
						end
						character:SetData("trashcan"..self.id, os.time() + ix.config.Get("trashcanInterval", 1))
						
						activator:Notify("You have found some items inside the trashcan!")
						
						self.canUse = true
					end, ix.config.Get("trashcanSearchTime"), function()
						activator:SetAction()
						self.canUse = true
					end)
				else
					local timeLeft = character:GetData("trashcan"..self.id, 0) - os.time()
					activator:Notify("You still need to wait " ..timeLeft.. " seconds before you can search a trashcan again!")
				end
		else
			activator:Notify("You can't search in trashcans!")
		end
	end
	
	function ENT:Touch( ent )
		if (ent:GetClass() == "ix_item" and ix.config.Get("trashcansRemoveItems") == true) then
			ent:Remove()
		else
			return
		end
	end
else
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(trashcan)
		local info = PLUGIN.models[self:GetModel():lower()]
		
		local title = trashcan:AddRow("name")
		title:SetFont("ixSmallTitleFont")
		title:SetText(self:GetDisplayName())
		title:SetBackgroundColor(ix.config.Get("color"))
		title:SizeToContents()
		
		local description = trashcan:AddRow("description")
		description:SetText(info.description)
		description:SizeToContents()
	end
	
	function ENT:GetDisplayName()
		local info = PLUGIN.models[self:GetModel():lower()]
		return self:GetNetVar("name", info.name)
	end
end