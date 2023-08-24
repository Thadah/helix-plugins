local PLUGIN = PLUGIN

PLUGIN.spawnedContainers = PLUGIN.spawnedContainers or {}
PLUGIN.spawners = PLUGIN.spawners or {}
PLUGIN.entitiesToRemove = {}

PLUGIN.curTime = 1
function PLUGIN:Think()
    if !ix.config.Get("lootEnabled") or !self.spawners then return end
    if (CurTime() < (self.curTime + ix.config.Get("lootContainerTime"))) then return end

    self.curTime = CurTime()

    --Remove all invalid containers
    for k, container in pairs(self.spawnedContainers) do
        --If entity has removed itself after decay time we remove it from the table as well
        if (!IsValid(container[1])) then
            table.remove(self.spawnedContainers, k)
        else
            inventory = container[1]:GetInventory()
            items = inventory:GetItems()
            local count = 0
            -- Since it's an indexed table we can't use #items to get item count
            for _, item in pairs(items) do
                count = count + 1
            end
            --If there are no items inside the container we will remove it before decay time
            if (count == 0) then
                container[1]:Remove()
                table.remove(self.spawnedContainers, k)
            end
        end
    end
     
    if (#self.spawnedContainers > ix.config.Get("lootMaxWorldContainers")) then return end
    if (#self.spawnedContainers > (ix.config.Get("lootMaxContainerSpawn")*#self.spawners)) then return end

    for i=1,ix.config.Get("lootMaxContainerSpawn") do
        local point = table.Random(self.spawners)
        if (!point) then return end 
        if #self.spawnedContainers >= ix.config.Get("lootMaxWorldContainers") then return end
        if ix.config.Get("lootMaxContainerSpawn") == 1 then
            for _, v in pairs(self.spawnedContainers) do
                if point[1] == v[2] then return end
            end
        end

        timer.Simple(0.5, function() self:spawnContainer(point) end)
    end
    
    

end

function PLUGIN:AddSpawner(location, model)
    table.insert(PLUGIN.spawners, {location, model})
end

function PLUGIN:RemoveSpawners(location, range)
    local count = 0
    for k, v in pairs(PLUGIN.spawners) do
        PLUGIN.spawners[k] = nil
        local distance = v[1]:Distance(location)
        if distance <= tonumber(range) then
            PLUGIN.spawners[k] = nil
            count = count+1
        end
    end
    PLUGIN:SaveLootContainers()
    return count
end

function PLUGIN:spawnContainer(point)
    local model = point[2]
    if !IsValid(model) then
        model = "models/props_junk/garbage_bag001a.mdl"
    end

    local positionOffset = Vector(math.random(-32, 32), math.random(-32, 32), math.random(0, 16))
    local proposedPosition = point[1] + positionOffset

    // Tracing the world ensures no entities get stuck underground for some reason
    local startPosition = proposedPosition
    local endPosition = proposedPosition + Vector(0, 0, -100)
    local tr = util.TraceLine({
        start = startPosition,
        endpos = endPosition,
        filter = function(ent) 
            if ent:IsWorld() then 
                return true 
            end 
        end
    })
    if !tr.HitWorld then
        return
    end
    local position = tr.HitPos + Vector(0, 0, 5)

    local entity = ents.Create("nut_itemcontainer")
    entity:SetModel(model)
    entity:SetPos(position)
    entity:SetName("itemcontainer-"..math.random())
    entity:Spawn()
    entity:SetSolid(SOLID_VPHYSICS)
    entity:PhysicsInit(SOLID_VPHYSICS)
    
    local physObj = entity:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:SetVelocity(Vector(0, 0, 0))
        physObj:EnableMotion(true)
        physObj:Wake()
    end
    
    if !IsValid(entity) then return end

    local invData = self.containerModel[model]["invData"]
    ix.inventory.New(0, entity:GetName(), function(inventory)
            inventory:SetSize(invData["w"], invData["h"])
            entity:SetInventory(inventory)
    end)

    local result = self:chooseRandom()
    local inv = entity:GetInventory()
    local items = math.random(1, ix.config.Get("lootCount"))
    for i=1, items do
        local item = table.Random(self.category[result])
        inv:Add(item)
    end

    local spawnedContainer = {entity, position}

    table.insert(self.spawnedContainers, spawnContainer)
end

function PLUGIN:chooseRandom()
    local totalWeight = 0.0
    
    for _, rarity in pairs(self.rarity) do
        totalWeight = totalWeight + rarity[1]
    end

    local randomWeight = math.random() * totalWeight
    local selectedRarity

    local result = 0;
    for k, rarity in pairs(self.rarity) do
        if randomWeight < rarity[1] then
            selectedRarity = table.Random(rarity[2])
            break
        end
        randomWeight = randomWeight - rarity[1]
    end

    return selectedRarity or self.rarity["common"][2]
end

function PLUGIN:PlayerSpawnedProp(client, model, entity)
    local data = self.models[model]
    if (!data) then return end
    if (hook.Run("CanPlayerSpawnTrashcan", client, model, entity) == false) then return end

    local trashcan = ents.Create("ix_trashcan")
    trashcan:SetPos(entity:GetPos())
    trashcan:SetAngles(entity:GetAngles())
    trashcan:SetModel(model)
    trashcan:Spawn()
    trashcan.id = math.random(10000,99999)

    self:SaveLootContainers()
    entity:Remove()
    
end

timer.Create("SaveLootContainers", ix.config.Get("lootSaveTime", 300), 0, function()
    PLUGIN:SaveLootContainers()
end)

function PLUGIN:SaveLootContainers()
    local data = {}

  	data.containers = {}
    data.spawnedContainers = {}
    data.spawners = {}
    data.trashcans = {}

    if (ix.config.Get("lootPersistentContainers")) then
        for _, entity in ipairs(ents.FindByClass("nut_itemcontainer")) do
            if (hook.Run("CanSaveStorage", entity, entity:GetInventory()) == false) then
                entity.nutForceDelete = true
                continue
            end
            if (entity:GetInventory()) then
                local lootcontainer = {}
                lootcontainer[1] = entity:GetPos()
                lootcontainer[2] = entity:GetAngles()
                lootcontainer[3] = entity:GetNetVar("id")
                lootcontainer[4] = entity:GetModel():lower()

                table.insert(data.containers, lootcontainer)
            end
        end
        table.insert(data.spawnedContainers, PLUGIN.spawnedContainers)
    end
    table.insert(data.spawners, PLUGIN.spawners)

    for _, v in ipairs(ents.FindByClass("ix_trashcan")) do
        local trashcan = {}
        trashcan.position = v:GetPos()
        trashcan.angles = v:GetAngles()
        trashcan.model = v:GetModel():lower()
        trashcan.id = v.id

        table.insert(data.trashcans, trashcan)
        
    end

  	self:SetData(data)
end

function PLUGIN:SaveData()
    if (!ix.shuttingDown) then
        self:SaveLootContainers()
    end
end

function PLUGIN:LoadData()
	local data = self:GetData() or {}
	if (!data) then return end

    if (ix.config.Get("lootPersistentContainers")) then
        for _, info in ipairs(data.containers) do
            local position, angles, invID, model = unpack(info)
            local storage = self.containerModel[model]
            if (!storage) then continue end

            local storage = ents.Create("nut_itemcontainer")
            storage:SetPos(position)
            storage:SetAngles(angles)
            storage:Spawn()
            storage:SetModel(model)
            storage:SetSolid(SOLID_VPHYSICS)
            storage:PhysicsInit(SOLID_VPHYSICS)

            local invData = PLUGIN.containerModel[storage:GetModel()]["invData"]
            
            ix.inventory.Restore(inventoryID, invData["w"], invData["h"], function(inventory)
                if (IsValid(entity)) then
                    entity:SetInventory(inventory)
                end
            end)

            local physObject = storage:GetPhysicsObject()

            if (physObject) then
                physObject:EnableMotion()
            end
        end
        self.spawnedContainers = data.spawnedContainers[#data.spawnedContainers-1]
    end

    for _, trashcan in pairs(data.trashcans) do
        local model = self.models[trashcan.model:lower()]
        if !model then return end

        local entity = ents.Create("ix_trashcan") 
        entity:SetPos(trashcan.position)
        entity:SetAngles(trashcan.angles)
        entity:Spawn()
        entity:SetModel(trashcan.model)
        entity:SetSolid(SOLID_VPHYSICS)
        entity:PhysicsInit(SOLID_VPHYSICS)

        if (trashcan.id) then
            entity.id = trashcan.id
            entity:SetNetVar("id", trashcan.id)
        end
        

        local physObject = entity:GetPhysicsObject()
        if (physObject) then
            physObject:EnableMotion()
        end
        
    end

    self.spawners = data.spawners[#data.spawners]

	self.loadedData = true
end

timer.Create("BatchRemove", ix.config.Get("lootEntityRemoveTime", 60), 0, function()
    if (#PLUGIN.entitiesToRemove > 0) then
        local query = mysql:Delete("ix_items")
        query:WhereIn("inventory_id", PLUGIN.entitiesToRemove)
        query:Execute()

        query = mysql:Delete("ix_inventories")
        query:WhereIn("inventory_id", PLUGIN.entitiesToRemove)
        query:Execute()

        PLUGIN.entitiesToRemove = {}
    end
end)