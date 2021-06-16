local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Item Container"
ENT.Category = "NutScript"
ENT.Spawnable = false
ENT.isStorageEntity = true
ENT.timeToDelete = 1

function ENT:GetInventory()
	return ix.item.inventories[self:GetNetVar("id", 0)]
end

function ENT:GetStorageInfo()
	self.lowerModel = self.lowerModel or self:GetModel()
	return PLUGIN.containerModel[self.lowerModel]
end
