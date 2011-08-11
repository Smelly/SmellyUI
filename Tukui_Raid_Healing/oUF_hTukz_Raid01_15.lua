local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable then return end
if C["unitframes"].gridonly then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local normTex = C["media"].blank

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(C.unitframes.unitframesize.player_target[2])
	health:SetStatusBarTexture(normTex)
	health:CreateBorder(false, true)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(1, 1, 1)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:Point("TOP", 1, -2)
	health.value:SetFont(C.media.pfont, 12, "MONOCHROMEOUTLINE")
	self.Health.value = health.value
	
	health.PostUpdate = T.PostUpdateHealthRaid
	health.frequentUpdates = true
	
	if C.unitframes.unicolor then
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
	
	local power = CreateFrame("StatusBar", nil, self)
	power:SetHeight(2)
	power:CreateBorder(false, true)
	power:SetFrameLevel(health:GetFrameLevel() + 1)
	power:Point("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 4, 4)
	power:Point("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -4, 4)
	power:SetStatusBarTexture(normTex)
	self.Power = power
	
	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	self.Power.bg = power.bg
	
	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end
	
	local name = health:CreateFontString(nil, "OVERLAY")
	name:Point("CENTER", health, 0, -1)
	name:SetFont(C.media.pfont, 12, "MONOCHROMEOUTLINE")
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
	
    local leader = health:CreateTexture(nil, "OVERLAY")
    leader:Height(12*T.raidscale)
    leader:Width(12*T.raidscale)
    leader:SetPoint("TOPLEFT", 4, -3)
	self.Leader = leader
	
    local LFDRole = health:CreateTexture(nil, "OVERLAY")
    LFDRole:Height(6*T.raidscale)
    LFDRole:Width(6*T.raidscale)
	LFDRole:Point("TOPRIGHT", -2, -2)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole
	
    local MasterLooter = health:CreateTexture(nil, "OVERLAY")
    MasterLooter:Height(12*T.raidscale)
    MasterLooter:Width(12*T.raidscale)
	self.MasterLooter = MasterLooter
    self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
	
	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
    end
	
	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(18*T.raidscale)
		RaidIcon:Width(18*T.raidscale)
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
    local debuffs = CreateFrame('Frame', nil, self)
    debuffs:SetPoint('LEFT', self, 'RIGHT', 4, 0)
    debuffs:SetHeight(30)
    debuffs:SetWidth(200)
    debuffs.size = 30
    debuffs.spacing = 2
    debuffs.initialAnchor = 'LEFT'
	debuffs.num = 5
	debuffs.PostCreateIcon = T.PostCreateAura
	debuffs.PostUpdateIcon = T.PostUpdateAura
	self.Debuffs = debuffs
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end
	
	if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		mhpb:SetWidth(150*T.raidscale)
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetWidth(150*T.raidscale)
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end

	return self
end

oUF:RegisterStyle('TukuiHealR01R15', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealR01R15")

	local raid = self:SpawnHeader("oUF_TukuiHealRaid0115", nil, "custom [@raid16,exists] hide;show", 
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
			'initial-width', 150,
			'initial-height', 30,
			"showParty", true,
			"showPlayer", C["unitframes"].showplayerinparty,
			"showRaid", true,
			"xoffset", 0,
			"yOffset", -1,
			"point", "TOP",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", 1,
			"columnAnchorPoint", "TOP"
	)
	raid:Point("LEFT", UIParent, "LEFT", 6 , 0)
	
	local pets = {} 
		pets[1] = oUF:Spawn('partypet1', 'oUF_TukuiPartyPet1') 
		pets[1]:SetPoint('TOPLEFT', raid, 'TOPLEFT', 0, -240*T.raidscale)
		pets[1]:Size(150*T.raidscale, 32*T.raidscale)
	for i =2, 4 do 
		pets[i] = oUF:Spawn('partypet'..i, 'oUF_TukuiPartyPet'..i) 
		pets[i]:SetPoint('TOP', pets[i-1], 'BOTTOM', 0, -8)
		pets[i]:Size(150*T.raidscale, 32*T.raidscale)
	end
		
	local ShowPet = CreateFrame("Frame")
		ShowPet:RegisterEvent("PLAYER_ENTERING_WORLD")
		ShowPet:RegisterEvent("RAID_ROSTER_UPDATE")
		ShowPet:RegisterEvent("PARTY_LEADER_CHANGED")
		ShowPet:RegisterEvent("PARTY_MEMBERS_CHANGED")
		ShowPet:SetScript("OnEvent", function(self)
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				local numraid = GetNumRaidMembers()
				local numparty = GetNumPartyMembers()
				if numparty > 0 and numraid == 0 or numraid > 0 and numraid <= 5 then
					for i,v in ipairs(pets) do v:Enable() end
				else
					for i,v in ipairs(pets) do v:Disable() end
				end
			end
		end)
end)


local RaidBG = CreateFrame("Frame", nil, oUF_TukuiHealRaid0115)
RaidBG:CreatePanel("Transparent", 1, 1, "CENTER", raid, "CENTER", 0, 0)
RaidBG:Hide()

RaidBG:RegisterEvent("UNIT_NAME_UPDATE")
RaidBG:RegisterEvent("RAID_ROSTER_UPDATE")
RaidBG:RegisterEvent("RAID_TARGET_UPDATE")
RaidBG:RegisterEvent("PARTY_LEADER_CHANGED")
RaidBG:RegisterEvent("PARTY_MEMBERS_CHANGED")
RaidBG:SetScript("OnEvent", function(self)
    if oUF_TukuiHealRaid0115:IsVisible() then
        self:ClearAllPoints()
        self:Point("TOPLEFT", oUF_TukuiHealRaid0115, "TOPLEFT", -2, 2)
        self:Point("BOTTOMRIGHT", oUF_TukuiHealRaid0115, "BOTTOMRIGHT", 2, -2)
        self:Show()
        if not self.parented then
            self:SetParent(oUF_TukuiHealRaid0115)
            self.parented = true
        end
    else
        self:Hide()
    end
end)