local PLUGIN = PLUGIN

PLUGIN.spawnedContainers = PLUGIN.spawnedContainers or {}
PLUGIN.spawners = PLUGIN.spawners or {}

PLUGIN.curTime = 1
function PLUGIN:Think()
    if ix.config.Get("lootEnabled") and self.spawners != nil then
        if (CurTime() < (self.curTime + ix.config.Get("lootContainerTime"))) then return end
        self.curTime = CurTime()

        --Remove all invalid containers
        for k, v in pairs(self.spawnedContainers) do
            --If entity has removed itself after decay time we remove it from the table as well
            if (!IsValid(v[1])) then
                table.remove(self.spawnedContainers, k)
            else
                inventory = v[1]:GetInventory()
                items = inventory:GetItems()
                local count = 0
                -- Since it's an indexed table we can't use #items to get item count
                for _, v in pairs(items) do
                    count = count + 1
                end
                --If there are no items inside the container we will remove it before decay time
                if (count == 0) then
                    v[1]:Remove()
                    table.remove(self.spawnedContainers, k)
                end
            end
        end
        
        if (#self.spawnedContainers < ix.config.Get("lootMaxWorldContainers")) then
            if (#self.spawnedContainers < (ix.config.Get("lootMaxContainerSpawn")*#self.spawners)) then          
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
        end	
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
    PLUGIN:saveStorage()
    return count
end

function PLUGIN:spawnContainer(point)
    local entity = ents.Create("nut_itemcontainer")
    entity:SetPos(point[1] + Vector(math.random(1, 64), math.random(1, 64), 16))
    entity:SetAngles(entity:GetAngles())
    entity:Spawn()
    entity:SetModel(point[2])
    entity:SetSolid(SOLID_VPHYSICS)
    entity:PhysicsInit(SOLID_VPHYSICS)
    local physObj = entity:GetPhysicsObject()

    if (IsValid(physObj)) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end

    local invName = "itemcontainer-"..math.random()
    local invData = PLUGIN.containerModel[entity:GetModel()]["invData"]
    
    ix.inventory.New(0, invName, function(inventory)
        if (IsValid(entity)) then
            inventory:SetSize(invData["w"], invData["h"])
            entity:SetInventory(inventory)
        end
    end)

    local result = self:chooseRandom()
    local inv = entity:GetInventory()
    local items = math.random(1,ix.config.Get("lootCount"))
    for i=1, items do
        local item = table.Random(self.category[result])
        inv:Add(item)
    end

    self.spawnedContainers[#self.spawnedContainers + 1] = {entity, point[1]}
end

function PLUGIN:chooseRandom()
    local weight = 0.0
    for _, v in pairs(self.rarity) do
        weight = weight + v[1]
    end
    local at = math.random() * weight

    local result = 0;
    for k, v in pairs(self.rarity) do
        if at < v[1] then
            result = table.Random(v[2])
            break
        end
        at = at - v[1]
    end

    if !result then
        result = self.rarity["common"][2]
    end

    return result
end

function PLUGIN:saveStorage()
  	local data = {}

    if (ix.config.Get("lootPersistentContainers")) then
        for _, entity in ipairs(ents.FindByClass("nut_itemcontainer")) do
            if (hook.Run("CanSaveStorage", entity, entity:GetInventory()) == false) then
                entity.nutForceDelete = true
                continue
            end
            if (entity:GetInventory()) then
                data[#data + 1] = {
                    entity:GetPos(),
                    entity:GetAngles(),
                    entity:GetNetVar("id"),
                    entity:GetModel():lower()
                }
            end
        end
        data[#data + 1] = self.spawnedContainers
    end
    data[#data + 1] = self.spawners

  	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData() or {}
	if (not data) then return end

    if (ix.config.Get("lootPersistentContainers")) then
        for _, info in ipairs(data) do
            local position, angles, invID, model = unpack(info)
            local storage = self.containerModel[model]
            if (not storage) then continue end

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
        self.spawnedContainers = data[#data-1]
    end

    self.spawners = data[#data]

	self.loadedData = true
end