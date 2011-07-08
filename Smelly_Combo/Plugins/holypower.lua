-- Power Plugin
local T, C, L = unpack(Tukui)

local O = Options["holy"]
if O.holy ~= true then return end

local sHoly = CreateFrame("Frame", "sHoly", UIParent)
for i = 1, 3 do					
	sHoly[i] = CreateFrame("Frame", "sHoly"..i, UIParent)			
	sHoly[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	sHoly[i]:CreateShadow("Default")
	sHoly[i]:SetBackdropBorderColor(228/255,225/255,16/255)
	
	if i == 1 then
		sHoly[i]:Point(unpack(O.anchor))
	else
		sHoly[i]:Point("LEFT", sHoly[i-1], "RIGHT", O.spacing, 0)
	end	
	
	sHoly[i]:RegisterEvent("UNIT_POWER")
	sHoly[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	sHoly[i]:SetScript("OnEvent", function()
		local holy = UnitPower("player", SPELL_POWER_HOLY_POWER)
	
		for i = 1, 3 do
			if (i <= holy) then
				sHoly[i]:Show()
			else
				sHoly[i]:Hide()
			end
		end
	end)
end