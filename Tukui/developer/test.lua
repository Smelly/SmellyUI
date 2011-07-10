local T, C, L = unpack(select(2, ...))

local orb = {}
for i = 1, 3 do
	orb[i] = CreateFrame("Frame", "orb"..i, UIParent)
	orb[i]:CreatePanel(nil, 100, 20, "CENTER", UIParent, "CENTER", 0, 0)
	orb[i]:SetBackdropBorderColor(.5,0,.7)
	if i == 1 then
		orb[i]:Point("CENTER", UIParent, "CENTER", 0, 0)
	else
		orb[i]:Point("LEFT", orb[i-1], "RIGHT", 3, 0)
	end
end

orb[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
orb[1]:RegisterEvent("UNIT_AURA")
orb[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
orb[1]:SetScript("OnEvent", function()
	count, unitCaster = select(4, UnitAura("player", 95740))
	if count and count > 0 and unitCaster == "player" then
		for i = 1, count do orb[i]:Show() end
	else
		for i = 1, 3 do orb[i]:Hide() end
	end
end)
