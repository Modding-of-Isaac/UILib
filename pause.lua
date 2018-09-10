local FreezeMain = true

-- Credits to AgentCucco, toggles freeze

return function()
    FreezeMain = not FreezeMain
    local player = Isaac.GetPlayer(0)-- get player data
    local entities = Isaac.GetRoomEntities()
    if FreezeMain == true then
        for i,v in pairs(entities) do
            if v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                entities[i]:RemoveStatusEffects()
                if v.Type == EntityType.ENTITY_TEAR then
                    data = v:GetData()
                    tear = v:ToTear()
                    data.Frozen = false
                    entities[i].Velocity = data.StoredVel
                    tear = entities[i]:ToTear()
                    tear.FallingSpeed = data.StoredFall
                    tear.FallingAcceleration = data.StoredAcc
                end
            end
        end
    else
        for i,v in pairs(entities) do
            if v.Type ~= EntityType.ENTITY_PLAYER then
                if not v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                    entities[i]:AddEntityFlags(EntityFlag.FLAG_FREEZE)
                end
                if entities[i].Type == EntityType.ENTITY_TEAR then
                        data = v:GetData()
                    if not data.Frozen then
                        data.Frozen = true
                        data.StoredVel = entities[i].Velocity
                        tear = entities[i]:ToTear()
                        data.StoredFall = tear.FallingSpeed
                        data.StoredAcc = tear.FallingAcceleration
                    else
                        entities[i].Velocity = zeroV
                        tear.FallingAcceleration = -0.1
                        tear.FallingSpeed = 0
                    end
                elseif entities[i].Type == EntityType.ENTITY_BOMBDROP then
                    bomb = v:ToBomb()
                    bomb:SetExplosionCountdown(2)
                elseif entities[i].Type == EntityType.ENTITY_LASER then
                    laser = v:ToLaser()
                end
            end
        end
    end
end