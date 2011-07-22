local T, C, L = unpack(select(2, ...))

if not IsAddOnLoaded("Omen") or not C["skin"].omen == true then return end

local Omen = Omen
local borderWidth = T.Scale(2, 2)

-- Skin Bar Texture
Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
Omen.UpdateBarTextureSettings = function(self)
	for i, v in ipairs(self.Bars) do
		v.texture:SetTexture(C["media"].normTex)
	end
end

-- Skin Bar fonts
Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
Omen.UpdateBarLabelSettings = function(self)
	self:UpdateBarLabelSettings_()
	for i, v in ipairs(self.Bars) do
		v.Text1:SetFont(C["media"].pfont, 12, "MONOCHROMEOUTLINE")
		v.Text2:SetFont(C["media"].pfont, 12, "MONOCHROMEOUTLINE")
		v.Text3:SetFont(C["media"].pfont, 12, "MONOCHROMEOUTLINE")
	end
end

-- Skin Title Bar
Omen.UpdateTitleBar_ = Omen.UpdateTitleBar
Omen.UpdateTitleBar = function(self)
	Omen.db.profile.Scale = 1
	Omen.db.profile.Background.EdgeSize = 1
	Omen.db.profile.Background.BarInset = borderWidth
	Omen.db.profile.TitleBar.UseSameBG = true
	self:UpdateTitleBar_()
	self.TitleText:SetFont(C["media"].pfont, 12, "MONOCHROMEOUTLINE")
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -1)
end

--Skin Title/Bars backgrounds
Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
Omen.UpdateBackdrop = function(self)
	Omen.db.profile.Scale = 1
	Omen.db.profile.Background.EdgeSize = 1
	Omen.db.profile.Background.BarInset = borderWidth
	self:UpdateBackdrop_()
	self.BarList:SetTemplate("Transparent")
	self.Title:SetTemplate("Transparent")
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -1)
end

-- Hook bar creation to apply settings
local omen_mt = getmetatable(Omen.Bars)
local oldidx = omen_mt.__index
omen_mt.__index = function(self, barID)
	local bar = oldidx(self, barID)
	Omen:UpdateBarTextureSettings()
	Omen:UpdateBarLabelSettings()
	return bar
end

-- Option Overrides
Omen.db.profile.Bar.Spacing = 1
Omen.db.profile.Bar.Texture = C.media.blank
Omen.db.profile.Bar.Font = C.media.pfont
Omen.db.profile.Bar.Height = 18
Omen.db.profile.TitleBar.Font = C.media.pfont
Omen.db.profile.Background.Texture = C.media.blank

-- Force updates
Omen:UpdateBarTextureSettings()
Omen:UpdateBarLabelSettings()
Omen:UpdateTitleBar()
Omen:UpdateBackdrop()
Omen:ReAnchorBars()
Omen:ResizeBars()
T.fadeIn(OmenBarList)

if C.skin.embed.omen == true then
	local fHolder = CreateFrame("Frame", "fHolder", UIParent)
	fHolder:SetSize((T.InfoLeftRightWidth - 4)/2, 160)
	fHolder:Point("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -((T.InfoLeftRightWidth - 4)/2) - 11, 3)
	local Omen_Skin = CreateFrame("Frame")
	Omen_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Omen_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil
		
		Omen.UpdateTitleBar = function() end
		OmenTitle:Kill()
		OmenBarList:ClearAllPoints()
		OmenBarList:SetAllPoints(fHolder)

		Omen.db.profile.FrameStrata = "3-MEDIUM"
	end)	
end