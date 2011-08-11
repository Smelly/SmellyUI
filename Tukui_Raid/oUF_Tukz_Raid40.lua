local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true then return end

local font2 = C["media"].uffont
local font1 = C["media"].font

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
    health:SetAllPoints(self)
	health:SetStatusBarTexture(C["media"].blank)
	self.Health = health
	health:CreateBorder(false, true)

	health.bg = self.Health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(self.Health)
	health.bg:SetTexture(C["media"].blank)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	
	self.Health.bg = health.bg
	
	health.PostUpdate = T.PostUpdatePetColor
	health.frequentUpdates = true
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.2, .2, .2)
		health.bg:SetVertexColor(.05, .05, .05)	
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true			
	end
	
	if C.unitframes.gradienthealth and C.unitframes.unicolor then
		self:HookScript("OnEnter", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) or (not UnitInRange(self.unit) and not UnitIsPlayer(self.unit)) then return end
			local hover = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
			health:SetStatusBarColor(hover.r, hover.g, hover.b)
			health.classcolored = true
		end)
		
		self:HookScript("OnLeave", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) then return end
			local r, g, b = oUF.ColorGradient(UnitHealth(self.unit)/UnitHealthMax(self.unit), unpack(C["unitframes"].gradient))
			health:SetStatusBarColor(r, g, b)
			health.classcolored = false
		end)
	end
		
	local name = health:CreateFontString(nil, 'OVERLAY')
	name:SetFont(C.media.pfont, 12, "MONOCHROMEOUTLINE")
	name:Point("CENTER", self, "CENTER", 0, 0)
	self:Tag(name, '[Tukui:namemedium] [Tukui:dead][Tukui:afk]')
	self.Name = name
	
	if C["unitframes"].showsymbols == true then
		RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(14*T.raidscale)
		RaidIcon:Width(14*T.raidscale)
		RaidIcon:SetPoint("CENTER", self, "CENTER")
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
    end
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	return self
end

oUF:RegisterStyle('TukuiDpsR40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDpsR40")

	local raid = self:SpawnHeader("oUF_TukuiDpsRaid40", nil, "custom [@raid26,exists] show;hide", 
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', T.Scale(110),
		'initial-height', T.Scale(15),
		"showRaid", true, "groupFilter", "1,2,3,4,5,6,7,8", "groupingOrder", "1,2,3,4,5,6,7,8", "groupBy", "GROUP", "yOffset", T.Scale(-1)
	)
	raid:SetPoint('TOPLEFT', UIParent, 5, -40)
end)

local RaidBG = CreateFrame("Frame", nil, oUF_TukuiDpsRaid40)
RaidBG:CreatePanel("Transparent", 1, 1, "CENTER", raid, "CENTER", 0, 0)
RaidBG:Hide()

RaidBG:RegisterEvent("UNIT_NAME_UPDATE")
RaidBG:RegisterEvent("RAID_ROSTER_UPDATE")
RaidBG:RegisterEvent("RAID_TARGET_UPDATE")
RaidBG:RegisterEvent("PARTY_LEADER_CHANGED")
RaidBG:RegisterEvent("PARTY_MEMBERS_CHANGED")
RaidBG:SetScript("OnEvent", function(self)
    if oUF_TukuiDpsRaid40:IsVisible() then
        self:ClearAllPoints()
        self:Point("TOPLEFT", oUF_TukuiDpsRaid40, "TOPLEFT", -2, 2)
        self:Point("BOTTOMRIGHT", oUF_TukuiDpsRaid40, "BOTTOMRIGHT", 2, -2)
        self:Show()
        if not self.parented then
            self:SetParent(oUF_TukuiDpsRaid40)
            self.parented = true
        end
    else
        self:Hide()
    end
end)