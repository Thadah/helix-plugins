local PLUGIN = PLUGIN

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local DEFAULT_OPEN_SOUND = "items/ammocrate_open.wav"

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.receivers = {}
	self.timeToDelete = CurTime() + ix.config.Get("lootContainerDeathTime")

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(true)
		physObj:Wake()
	end
end

function ENT:SetInventory(inventory)
	if (inventory) then
		self:SetNetVar("id", inventory:GetID())
	end
end

function ENT:OnRemove()
	local index = self:GetNetVar("id")

	if (!ix.shuttingDown and !self.ixIsSafe and ix.entityDataLoaded and index) then
		local inventory = ix.item.inventories[index]

		if (inventory) then
			ix.item.inventories[index] = nil

			local query = mysql:Delete("ix_items")
				query:Where("inventory_id", index)
			query:Execute()

			query = mysql:Delete("ix_inventories")
				query:Where("inventory_id", index)
			query:Execute()

			hook.Run("ContainerRemoved", self, inventory)
		end
	end
	PLUGIN:saveStorage()
end

function ENT:OpenInventory(activator)
	local inventory = self:GetInventory()
	local name = "Loot"

	ix.storage.Open(activator, inventory, {
		name = name,
		entity = self,
		searchTime = ix.config.Get("containerOpenTime", 0.7),
		OnPlayerClose = function()
			ix.log.Add(activator, "closeContainer", name, inventory:GetID())
		end
	})

	local openSound = self:GetStorageInfo().openSound
	self:EmitSound(openSound or DEFAULT_OPEN_SOUND)

	ix.log.Add(activator, "openContainer", name, inventory:GetID())
end

function ENT:Use(activator)
	local inventory = self:GetInventory()
	if (inventory and (activator.ixNextOpen or 0) < CurTime()) then
		self:OpenInventory(activator)
	end

	activator.ixNextOpen = CurTime() + 1
end

function ENT:Think()
	if (self.timeToDelete <= CurTime()) then
		self:Remove()
	end
end