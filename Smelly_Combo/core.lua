-- sCombo
local T, C, L = unpack(Tukui)

local O = Options["core"]
local sCombo = CreateFrame("Frame", "sCombo", UIParent)
for i = 1, 5 do
	sCombo[i] = CreateFrame("Frame", "sCombo"..i, UIParent)
	sCombo[i]:CreatePanel("Default", O.width, O.height, "CENTER", UIParent, "CENTER", 0, 0)
	sCombo[i]:CreateShadow("Default")
		
	if i == 1 then
		sCombo[i]:Point(unpack(O.anchor))
	else
		sCombo[i]:Point("LEFT", sCombo[i-1], "RIGHT", O.spacing, 0)
	end
	
	sCombo[i]:SetBackdropBorderColor(unpack(Options["colors"][i]))
	sCombo[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	sCombo[i]:RegisterEvent("UNIT_COMBO_POINTS")
	sCombo[i]:RegisterEvent("PLAYER_TARGET_CHANGED")
	sCombo[i]:SetScript("OnEvent", function()
		local points = GetComboPoints("player", "target")
		if points and points > 0 then
			for i = 1, points do sCombo[i]:Show() end
		else
			for i = 1, 5 do sCombo[i]:Hide() end
		end
	end)
end