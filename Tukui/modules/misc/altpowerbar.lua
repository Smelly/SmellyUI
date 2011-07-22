local T, C, L = unpack(select(2, ...))
if IsAddOnLoaded("SmellyPowerBar") then return end

PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
local AltPowerBar = CreateFrame("Frame", "TukuiAltPowerBar", UIParent)
AltPowerBar:Size(200, 14)
AltPowerBar:SetFrameStrata("MEDIUM")
AltPowerBar:SetFrameLevel(0)
AltPowerBar:EnableMouse(true)
AltPowerBar:SetTemplate("Transparent")
AltPowerBar:CreateShadow()
AltPowerBar:Point("TOP", UIParent, "TOP", 0, -3)

local AltPowerBarStatus = CreateFrame("StatusBar", "TukuiAltPowerBarStatus", AltPowerBar)
AltPowerBarStatus:SetFrameLevel(AltPowerBar:GetFrameLevel() + 1)
AltPowerBarStatus:SetStatusBarTexture(C.media.blank)
AltPowerBarStatus:SetMinMaxValues(0, 100)
AltPowerBarStatus:Point("TOPLEFT", AltPowerBar, "TOPLEFT", 2, -2)
AltPowerBarStatus:Point("BOTTOMRIGHT", AltPowerBar, "BOTTOMRIGHT", -2, 2)

local AltPowerText = AltPowerBarStatus:CreateFontString(nil, "OVERLAY")
AltPowerText:SetFont(C.media.pfont, 12, "MONOCHROMEOUTLINE")
AltPowerText:Point("CENTER", AltPowerBar, "CENTER", 0, 0)

AltPowerBar:RegisterEvent("UNIT_POWER")
AltPowerBar:RegisterEvent("UNIT_POWER_BAR_SHOW")
AltPowerBar:RegisterEvent("UNIT_POWER_BAR_HIDE")
AltPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
AltPowerBar:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if UnitAlternatePowerInfo("player") then
		self:Show()
	else
		self:Hide()
	end
end)

local TimeSinceLastUpdate = 1
AltPowerBarStatus:SetScript("OnUpdate", function(self, elapsed)
	if not AltPowerBar:IsShown() then return end
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	
	if (TimeSinceLastUpdate >= 1) then
		self:SetMinMaxValues(0, UnitPowerMax("player", ALTERNATE_POWER_INDEX))
		local power = UnitPower("player", ALTERNATE_POWER_INDEX)
		local mpower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
		self:SetValue(power)
		AltPowerText:SetText(power.." / "..mpower)
		local r, g, b = oUFTukui.ColorGradient(power/mpower, 0,.8,0,.8,.8,0,.8,0,0)
		AltPowerBarStatus:SetStatusBarColor(r, g, b)
		self.TimeSinceLastUpdate = 0
	end
end)