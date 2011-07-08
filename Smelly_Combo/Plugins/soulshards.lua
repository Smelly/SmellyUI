-- Power Plugin
local T, C, L = unpack(Tukui)

local O = Options["soul"]
if O.soul ~= true then return end

local sSoul = CreateFrame("Frame", "sSoul", UIParent)
for i = 1, 3 do					
	sSoul[i] = CreateFrame("Frame", "sSoul"..i, UIParent)			
	sSoul[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	sSoul[i]:CreateShadow("Default")
	sSoul[i]:SetBackdropBorderColor(255/255,101/255,101/255)
	
	if i == 1 then
		sSoul[i]:Point(unpack(O.anchor))
	else
		sSoul[i]:Point("LEFT", sSoul[i-1], "RIGHT", O.spacing, 0)
	end	
	
	sSoul[i]:RegisterEvent("UNIT_POWER")
	sSoul[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	sSoul[i]:SetScript("OnEvent", function()
		local shard = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	
		for i = 1, 3 do
			if (i <= shard) then
				sSoul[i]:Show()
			else
				sSoul[i]:Hide()
			end
		end
	end)
end