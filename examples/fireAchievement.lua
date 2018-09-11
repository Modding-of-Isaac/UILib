local mymod = RegisterMod("MyModName")

local fireCounter = 0

mymod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL , function(_, ent)
	if ent.Type == EntityType.ENTITY_FIREPLACE then
	    fireCounter = fireCounter + 1
	end
	
	if fireCounter == 50 then
		UILib.displayAchievement("my_achievement_file.png")  -- Saved as modRoot/resources/gfx/ui/achievement/my_achievement_file.png
		-- Do stuff here; Add item to item pool, etc.
		-- You'll likely want to save the fact that the user has already gotten the achievement
	end
end)
