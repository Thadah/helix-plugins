local PLUGIN = PLUGIN

local function offsound()
    return "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"
end

local function onsound()
    return "npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav"
end

local function dispatchon()
    return "npc/overwatch/radiovoice/on3.wav"
end

local function dispatchoff()
    return "npc/overwatch/radiovoice/off2.wav"
end

local lookup = {}
lookup["onsound"] = onsound
lookup["offsound"] =  offsound
lookup["dispatchon"] = dispatchon
lookup["dispatchoff"] = dispatchoff

function PLUGIN:PlayConversation(client, convTable)
    if (!IsValid(client)) then return end
    local totalDuration = 0
    local uid = client:UniqueID()

    for k, v in pairs(convTable) do
        if (lookup[v]) then
            convTable[k] = lookup[v]()
        end
    end

    client:EmitSound(convTable[1], 75, 100, 0.55)

    for i = 2, #convTable do
        local wait = 0

        for q = 1, i - 1 do
            local duration = SoundDuration(convTable[q])

            if (convTable[q]:find("vo/off") or convTable[q]:find("radiovoice/off2")) then
                duration = duration + 0.1
            end

            wait = wait + duration
        end

        timer.Create("ConvTimer_" .. uid .. "_" .. i, wait + 0.05, 1, function()
            if (IsValid(client)) then
                client:EmitSound(convTable[i], 75, 100, 0.55)
            end
        end)
    end
end

net.Receive("ixChatterPlayConversation", function(len, ply)
    local table = net.ReadTable()
    PLUGIN:PlayConversation(table[1], table[2])
end)

net.Receive("ixChatterConversationLength", function(len, ply)
    local totalDuration = 0
    local table = net.ReadTable()

    --PrintTable(table)

    for k, v in pairs(table) do
        totalDuration = totalDuration + SoundDuration(v)
    end

    --print(totalDuration)

    net.Start("ixChatterConversationLength", totalDuration)
        net.WriteFloat(totalDuration)
    net.SendToServer()
end)