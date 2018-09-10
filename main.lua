local achievement = Sprite()

local render = false
local gfxUsed = "blank_entry.png"
local setup = false

UILib = {
    togglePause = require("pause.lua"),

    display = function()
        if not setup then
            setup = true
            achievement:Load("gfx/ui/achievement/achievement.anm2", true)
            achievement:Play(achievement:GetDefaultAnimation(), true)
        end

        if render then
            achievement:Update()
            achievement:Render(Vector(120, 60), Vector(0, 0), Vector(0, 0))
        end
    end,

    displayAchievement = function(gfx)
        achievement:ReplaceSpritesheet(1, "gfx/ui/achievement/"..gfx)
        achievement:LoadGraphics()
        render = true

        UILib.togglePause()
    end,

    checkButton = function()
        local player = Isaac.GetPlayer(0)
        if player ~= nil then
            if render and (Input.IsButtonPressed(Keyboard.KEY_ENTER, 0) or Input.IsActionPressed(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex)) then
                render = false
                player.ControlsEnabled = true
                UILib.togglePause()
                return false
            elseif render then
                player.ControlsEnabled = false
            end
        end
    end
}

local mod = RegisterMod("UILib", 1)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, UILib.display)
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, UILib.checkButton)
