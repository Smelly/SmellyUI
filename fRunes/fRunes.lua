if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then return end

local T, C, L = unpack(Tukui)

local colors = fRunesSettings.colors

local runes = {}
local runemap = fRunesSettings.runemap

-- Create the frame
fRunes = CreateFrame("Frame", "fRunes", UIParent)
fRunes:SetPoint("TOP", fRunesSettings.anchor, "BOTTOM", fRunesSettings.x, fRunesSettings.y)
if (fRunesSettings.growthDirection == "VERTICAL") then
	fRunes:SetSize(fRunesSettings.barThickness * 6 + 9, fRunesSettings.barLength)
else
	fRunes:SetSize(fRunesSettings.barLength, fRunesSettings.barThickness * 6 + 9)
end

-- Styling
fRunes:SetTemplate("Default")
fRunes:CreateShadow("Default")

-- Create the runes
for i = 1, 6 do
	local rune = CreateFrame("StatusBar", "fRunesRune"..i, fRunes)
	rune:SetStatusBarTexture(fRunesSettings.texture)
	rune:SetStatusBarColor(unpack(colors[math.ceil(runemap[i]/2)]))
	rune:SetMinMaxValues(0, 10)
	
	if (fRunesSettings.growthDirection == "VERTICAL") then
		rune:SetOrientation("VERTICAL")
		rune:SetWidth(fRunesSettings.barThickness)
	else
		rune:SetOrientation("HORIZONTAL")
		rune:SetHeight(fRunesSettings.barThickness)
	end
	
	if (i == 1) then
		rune:SetPoint("TOPLEFT", fRunes, "TOPLEFT", 2, -2)
		if (fRunesSettings.growthDirection == "VERTICAL") then
			rune:SetPoint("BOTTOMLEFT", fRunes, "BOTTOMLEFT", 2, 2)
		else
			rune:SetPoint("TOPRIGHT", fRunes, "TOPRIGHT", -2, -2)
		end
	else
		if (fRunesSettings.growthDirection == "VERTICAL") then
			rune:SetHeight(runes[1]:GetHeight())
			rune:SetPoint("LEFT", runes[i-1], "RIGHT", 1, 0)
		else
			rune:SetWidth(runes[1]:GetWidth())
			rune:SetPoint("TOP", runes[i-1], "BOTTOM", 0, -1)
		end
	end
	
	tinsert(runes, rune)
end

-- Create the RP Bar
if (fRunesSettings.displayRpBar) then
	local rpbarbg = CreateFrame("Frame", "fRunesRunicPower", fRunes)
	rpbarbg:SetTemplate("Default")
	rpbarbg:CreateShadow("Default")
	rpbarbg:SetPoint("TOPLEFT", fRunes, "BOTTOMLEFT", 0, -3)
	rpbarbg:SetPoint("TOPRIGHT", fRunes, "BOTTOMRIGHT", 0, -3)
	rpbarbg:SetHeight(fRunesSettings.rpBarThickness or 10)
	
	local rpbar = CreateFrame("StatusBar", nil, rpbarbg)
	rpbar:SetStatusBarTexture(fRunesSettings.texture)
	rpbar:SetStatusBarColor(unpack(colors[5]))
	rpbar:SetMinMaxValues(0, 100)
	
	rpbar:SetPoint("TOPLEFT", rpbarbg, "TOPLEFT", 2, -2)
	rpbar:SetPoint("BOTTOMRIGHT", rpbarbg, "BOTTOMRIGHT", -2, 2)
	
	if (fRunesSettings.displayRpBarText) then
		local fontHeight = rpbar:GetHeight()-4
		if fontHeight < 11 then
			fontHeight = 11
		end
		
		rpbar.text = rpbar:CreateFontString(nil, "ARTWORK")
		rpbar.text:SetFont(C["media"].font, fontHeight, "THINOUTLINE")
		rpbar.text:SetPoint("CENTER", 1, 0)
		rpbar.text:SetTextColor(unpack(colors[5]))
	end
	
	rpbar.TimeSinceLastUpdate = 0
	rpbar:SetScript("OnUpdate", function(self, elapsed)
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 
		
		if (self.TimeSinceLastUpdate > 0.07) then
			self:SetMinMaxValues(0, UnitPowerMax("player"))
			local power = UnitPower("player")
			self:SetValue(power)
			if (self.text) then
				self.text:SetText(power)
			end
			self.TimeSinceLastUpdate = 0
		end
	end)
end  

-- Function to update runes
local function UpdateRune(id, start, duration, finished)
	local rune = runes[id]
	
	rune:SetStatusBarColor(unpack(colors[GetRuneType(runemap[id])]))
	rune:SetMinMaxValues(0, duration)
	
	if (finished) then
		rune:SetValue(duration)
	else
		rune:SetValue(GetTime() - start)
	end
end

local OnUpdate = CreateFrame("Frame")
OnUpdate.TimeSinceLastUpdate = 0
local updateFunc = function(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 	

	if (self.TimeSinceLastUpdate > 0.07) then
		for i = 1, 6 do
			UpdateRune(i, GetRuneCooldown(runemap[i]))
		end
		self.TimeSinceLastUpdate = 0
	end
end
OnUpdate:SetScript("OnUpdate", updateFunc)

fRunes:RegisterEvent("PLAYER_REGEN_DISABLED")
fRunes:RegisterEvent("PLAYER_REGEN_ENABLED")
fRunes:RegisterEvent("PLAYER_ENTERING_WORLD")
fRunes:SetScript("OnEvent", function(self, event)
	if (not fRunesSettings.hideOOC) then
		fRunes:UnregisterAllEvents()
	elseif (event == "PLAYER_REGEN_DISABLED") then
		UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
		OnUpdate:SetScript("OnUpdate", updateFunc)
	elseif (event == "PLAYER_REGEN_ENABLED") then
		UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
		OnUpdate:SetScript("OnUpdate", nil)
	elseif (event == "PLAYER_ENTERING_WORLD") then
		RuneFrame:ClearAllPoints()
		if (not InCombatLockdown()) then
			fRunes:SetAlpha(0)
		end
	end
end)

-- hide blizzard runeframe
RuneFrame:Hide()
RuneFrame:SetScript("OnShow", function(self)
	self:Hide()
end)