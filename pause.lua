-- Credits to AgentCucco and Chronoscope, toggles freeze
-- Bugs:
-- Tears don't freeze
-- Entites can be killed by GridEntities like spikes and fireplaces

local zeroV = Vector(0,0)
local randomV = Vector(0,0)
local game = Game()
local music = MusicManager()
local last = nil

return function(doFreeze)
    if last == doFreeze then
        return
    end
    last = doFreeze
    local player = Isaac.GetPlayer(0) -- get player data
    local entities = Isaac.GetRoomEntities()
    if not doFreeze then
        for i,v in pairs(entities) do
            if v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                v:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
                if v.Type == EntityType.ENTITY_TEAR then
                    local data = v:GetData()
                    if data.Frozen then
                        data.Frozen = nil
                        tear = v:ToTear()
                        entities[i].Velocity = data.StoredVel
                        tear = entities[i]:ToTear()
                        tear.FallingSpeed = data.StoredFall
                        tear.FallingAcceleration = data.StoredAcc
                    end
                elseif v.Type == EntityType.ENTITY_LASER then
                    local data = v:GetData()
                    data.Frozen = nil
                elseif v.Type == EntityType.ENTITY_KNIFE then
                    local data = v:GetData()
                    data.Frozen = nil
                end
            end
        end
        music:Resume()
    else
        for i,v in pairs(entities) do
            if entities[i].Type ~= EntityType.ENTITY_PLAYER and entities[i].Type ~= EntityType.ENTITY_FAMILIAR then
                if entities[i].Type ~= EntityType.ENTITY_PROJECTILE then
                    if not v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
                        entities[i]:AddEntityFlags(EntityFlag.FLAG_FREEZE)
                    end
                end

                if entities[i].Type == EntityType.ENTITY_TEAR then
                    local data = v:GetData()
                    if not data.Frozen then
                        if v.Velocity.X ~= 0 or v.Velocity.Y ~= 0 or not player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                            data.Frozen = true
                            data.StoredVel = entities[i].Velocity
                            local tear = entities[i]:ToTear()
                            data.StoredFall = tear.FallingSpeed
                            data.StoredAcc = tear.FallingAcceleration
                        else
                            local tear = entities[i]:ToTear()
                            tear.FallingSpeed = 0
                        end
                    else
                        local tear = entities[i]:ToTear()
                        entities[i].Velocity = zeroV
                        tear.FallingAcceleration = -0.1
                        tear.FallingSpeed = 0
                    end
                elseif entities[i].Type == EntityType.ENTITY_BOMBDROP then
                    bomb = v:ToBomb()
                    bomb:SetExplosionCountdown(2)
                    if v.Variant  == 4 then
                        bomb.Velocity = zeroV
                    end
                elseif entities[i].Type == EntityType.ENTITY_LASER then
                    if v.Variant ~= 2 then
                        local laser = v:ToLaser()
                        local data = v:GetData()
                        if not data.Frozen and not laser:IsCircleLaser() then
                            local newLaser = player:FireBrimstone(Vector.FromAngle(laser.StartAngleDegrees))
                            newLaser.Position = laser.Position
                            newLaser.DisableFollowParent = true
                            local newData = newLaser:GetData()
                            newData.Frozen = true
                            laser.CollisionDamage = -100
                            data.Frozen = true
                            laser.DisableFollowParent = true
                            laser.Visible = false
                        end
                        laser:SetTimeout(19)
                    end
                elseif v.Type == EntityType.ENTITY_KNIFE then
                    local data = v:GetData()
                    local knife = v:ToKnife()
                    if knife:IsFlying() then
                        local number = 1
                        local offset = 0
                        local offset2 = 0
                        local brimDamage = 0
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                            number = math.random(math.floor(3+knife.Charge*3),math.floor(4+knife.Charge*4))
                            offset = math.random(-150,150)/10
                            offset2 = math.random(-300,300)/1000
                            brimDamage = 1.5
                        end
                        for i = 1,number do
                            local newKnife = player:FireTear(knife.Position,zeroV,false,true,false)
                            local newData = newKnife:GetData()
                            newData.Knife = true
                            newKnife.TearFlags = 1<<1
                            newKnife.Scale = 1
                            newKnife:ResetSpriteScale()
                            newKnife.FallingAcceleration = -0.1
                            newKnife.FallingSpeed = 0
                            newKnife.Height = -10
                            randomV.X = 0
                            randomV.Y = 1+offset2
                            newKnife.Velocity = randomV:Rotated(knife.Rotation-90+offset)*15*player.ShotSpeed
                            newKnife.CollisionDamage = knife.Charge*(player.Damage)*(3-brimDamage)
                            newKnife.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                            newKnife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

                            newKnife.SpriteRotation = newKnife.Velocity:GetAngleDegrees()+90
                            local sprite = newKnife:GetSprite()
                            sprite:ReplaceSpritesheet(0,"gfx/tearKnife.png")
                            sprite:LoadGraphics()

                            knife:Reset()
                            offset = math.random(-150,150)/10
                            offset2 = math.random(-300,300)/1000
                        end
                    end
                end
            end
        end
        music:Pause()
    end
end
