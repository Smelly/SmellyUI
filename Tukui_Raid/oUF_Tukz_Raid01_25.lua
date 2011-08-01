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
	health:Height(25)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
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

	local power = CreateFrame("StatusBar", nil, self)
	power:Height(2)
	power:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 4, 4)
	power:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", -4, 4)
	power:SetStatusBarTexture(C["media"].blank)
	power:SetFrameLevel(health:GetFrameLevel() + 1)
	self.Power = power
	power:CreateBorder(false, true)

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(C["media"].normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	self.Power.bg = power.bg

	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
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
	name:Point("CENTER", self, "CENTER", 0, 2)
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

	local LFDRole = health:CreateTexture(nil, "OVERLAY")
    LFDRole:Height(6*T.raidscale)
    LFDRole:Width(6*T.raidscale)
	LFDRole:Point("TOPLEFT", 2, -2)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole

	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck

	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\media\textures\picon]]
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

oUF:RegisterStyle('TukuiDpsP05R10R15R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDpsP05R10R15R25")

	local raid = self:SpawnHeader("oUF_TukuiDpsRaid05101525", nil, "custom [@raid26,exists] hide;show", 
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', T.Scale(120),
		'initial-height', T.Scale(25),	
		"showParty", true, "showPlayer", C["unitframes"].showplayerinparty, "showRaid", true, "groupFilter", "1,2,3,4,5,6,7,8", "groupingOrder", "1,2,3,4,5,6,7,8", "groupBy", "GROUP", "yOffset", T.Scale(-1)
	)
	raid:SetPoint('TOPLEFT', UIParent, 5, -40)

	local pets = {} 
		pets[1] = oUF:Spawn('partypet1', 'oUF_TukuiPartyPet1') 
		pets[1]:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', 0, -6)
		pets[1]:Size(120, 20)
	for i =2, 4 do 
		pets[i] = oUF:Spawn('partypet'..i, 'oUF_TukuiPartyPet'..i) 
		pets[i]:SetPoint('TOP', pets[i-1], 'BOTTOM', 0, -8)
		pets[i]:Size(120, 20)
	end

	local RaidMove = CreateFrame("Frame")
	RaidMove:RegisterEvent("PLAYER_LOGIN")
	RaidMove:RegisterEvent("RAID_ROSTER_UPDATE")
	RaidMove:RegisterEvent("PARTY_LEADER_CHANGED")
	RaidMove:RegisterEvent("PARTY_MEMBERS_CHANGED")
	RaidMove:SetScript("OnEvent", function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local numraid = GetNumRaidMembers()
			local numparty = GetNumPartyMembers()
			if numparty > 0 and numraid == 0 or numraid > 0 and numraid <= 5 then
				raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -399*T.raidscale)
				for i,v in ipairs(pets) do v:Enable() end
			elseif numraid > 5 and numraid < 11 then
				raid:SetPoint('TOPLEFT', UIParent, 5, -350*T.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 10 and numraid < 16 then
				raid:SetPoint('TOPLEFT', UIParent, 5, -280*T.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 15 and numraid < 26 then
				raid:SetPoint('TOPLEFT', UIParent, 5, -172*T.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 25 then
				for i,v in ipairs(pets) do v:Disable() end
			end
		end
	end)
end)

local RaidBG = CreateFrame("Frame", nil, UIParent)
RaidBG:CreatePanel("Transparent", 1, 1, "CENTER", raid, "CENTER", 0, 0)
RaidBG:Hide()
RaidBG:RegisterEvent("UNIT_NAME_UPDATE")
RaidBG:RegisterEvent("RAID_ROSTER_UPDATE")
RaidBG:RegisterEvent("RAID_TARGET_UPDATE")
RaidBG:RegisterEvent("PARTY_MEMBERS_CHANGED")
RaidBG:RegisterEvent("PARTY_LEADER_CHANGED")
RaidBG:SetScript("OnEvent", function(self)
	if oUF_TukuiDpsRaid05101525:IsVisible() then
		self:ClearAllPoints()
		self:Point("TOPLEFT", oUF_TukuiDpsRaid05101525, "TOPLEFT", -2, 2)
		self:Point("BOTTOMRIGHT", oUF_TukuiDpsRaid05101525, "BOTTOMRIGHT", 2, -2)
		self:Show()
	else
		self:Hide()
	end
end)