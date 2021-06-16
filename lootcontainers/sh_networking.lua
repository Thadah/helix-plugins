local PLUGIN = PLUGIN

if SERVER then
    util.AddNetworkString("nutDisplayContSpawnPoints")
else
    net.Receive("nutDisplayContSpawnPoints", function()
        local points = net.ReadTable()
        for k, v in pairs(points) do
            local emitter = ParticleEmitter( v[1] )
            local smoke = emitter:Add( "sprites/glow04_noz", v[1] )
            smoke:SetVelocity( Vector( 0, 0, 1 ) )
            smoke:SetDieTime(15)
            smoke:SetStartAlpha(255)
            smoke:SetEndAlpha(255)
            smoke:SetStartSize(64)
            smoke:SetEndSize(64)
            smoke:SetColor(255,0,0)
            smoke:SetAirResistance(300)
        end
    end)
    
    
    function PLUGIN:exitStorage()
        net.Start("nutStorageExit")
        net.SendToServer()
    end
end    