local achievement = Sprite()

local gfxQueue = {}

local render = false
local setup = false

UILib = {
    togglePause = require("pause.lua"),

    _display = function()
        if not setup then
            setup = true
            achievement:Load("gfx/ui/achievement/achievements.anm2", true)
        end

        if render then
            if achievement:IsFinished("Appear") then
                achievement:Play("Idle", true)
            end

            if achievement:IsFinished("Dissapear") then
                render = false
                -- Resume
                local player = Isaac.GetPlayer(0)
                player.ControlsEnabled = true
                UILib.togglePause(false)
            end

            achievement:Update()
            local roomCenter = (Game():GetRoom():GetRenderSurfaceTopLeft()*2 + Vector(442,286))/2  -- "Kube's magic formula" - Nine
            achievement:Render(roomCenter, Vector(0, 0), Vector(0, 0))
        end
    end,

    _preventDamage = function(_, tookDamage)
        if render then
            return false
        end
    end,

    displayAchievement = function(gfx)
        achievement:ReplaceSpritesheet(3, "gfx/ui/achievement/"..gfx)
        achievement:LoadGraphics()
        achievement:Play("Appear", true)
		local player = Isaac.GetPlayer(0)
		player.ControlsEnabled = false
		
        render = true

        UILib.togglePause(true)
    end
}

local mod = RegisterMod("UILib", 1)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, UILib._display)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, UILib._preventDamage)
