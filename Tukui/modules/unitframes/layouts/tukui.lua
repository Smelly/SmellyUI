local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(select(2, ...)) 
if not C["unitframes"].enable == true or C["unitframes"].style == "Hydra" then return end

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

T.Player, T.Target, T.ToT, T.Pet, T.Focus, T.Boss = 225, 225, 130, 130, 130, 200

local font1 = C["media"].uffont
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex
local blankTex = C["media"].blank

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

PLAYER_TARGET_WIDTH = T.Scale(C.unitframes.unitframesize.player_target[1])
PLAYER_TARGET_HEIGHT = T.Scale(C.unitframes.unitframesize.player_target[2])

TARGET_TARGET_WIDTH = C.unitframes.unitframesize.targetoftarget[1]
TARGET_TARGET_HEIGHT = C.unitframes.unitframesize.targetoftarget[2]

PET_WIDTH = C.unitframes.unitframesize.pet[1]
PET_HEIGHT = C.unitframes.unitframesize.pet[2]

FOCUS_WIDTH = C.unitframes.unitframesize.focus[1]
FOCUS_HEIGHT = C.unitframes.unitframesize.focus[2]

BOSS_WIDTH = C.unitframes.unitframesize.boss[1]
BOSS_HEIGHT = C.unitframes.unitframesize.boss[2]

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self:SetFrameLevel(5)
	
	-- menu? lol
	self.menu = T.SpawnMenu

	-- this is the glow border
	self:CreateShadow("Default")
	
	self.shadow:Hide()
	
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:Height(20)
	RaidIcon:Width(20)
	RaidIcon:SetPoint("TOP", 0, 11)
	self.RaidIcon = RaidIcon
	
	-- health
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(blankTex)
	health:SetFrameStrata("LOW")
	self.Health = health
	
	local healthBG = health:CreateTexture(nil, 'BORDER')
	healthBG:SetAllPoints()
	self.Health.bg = healthBG
	
	health:CreateBorder(false, true)
	
	-- power
	local power = CreateFrame('StatusBar', nil, self)
	power:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 4, 4)
	power:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", -4, 4)
	power:SetStatusBarTexture(blankTex)
	self.Power = power

	local powerBG = power:CreateTexture(nil, 'BORDER')
	powerBG:SetAllPoints(power)
	powerBG:SetTexture(blankTex)
	powerBG.multiplier = 0.3
	self.Power.bg = powerBG
	
	power:CreateBorder(false, true)

	-- colors
	health.frequentUpdates = true
	power.frequentUpdates = true
	power.colorDisconnected = true

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end
		
	if C["unitframes"].unicolor == true then
		health.colorTapping = false
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.2, .2, .2)
		healthBG:SetTexture(1, 1, 1)
		healthBG:SetVertexColor(.05, .05, .05)	
			
		power.colorTapping = true
		power.colorDisconnected = true
		power.colorClass = true
		power.colorReaction = true
	else
		healthBG:SetTexture(.1, .1, .1)

		health.colorTapping = true
		health.colorDisconnected = true
		health.colorReaction = true
		health.colorClass = true
		if T.myclass == "HUNTER" then
			health.colorHappiness = true
		end
		
		power.colorPower = true
	end
		
	-- unitframe bg
	local panel = CreateFrame("Frame", nil, self)
	panel:SetFrameLevel(health:GetFrameLevel() - 1)
	panel:SetFrameStrata(health:GetFrameStrata())
	panel:Point("TOPLEFT", health, -2, 2)
	panel:Point("BOTTOMRIGHT", health, 2, -2)
	panel:SetBackdrop({
		bgFile = C["media"].blank,
		insets = { left = -T.mult, right = -T.mult, top = -T.mult, bottom = -T.mult }
	})
	panel:SetBackdropColor(unpack(C["media"].bordercolor))
	panel:CreateBorder(true, true)
	panel:CreateShadow("Default")
	self.panel = panel
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		-- health bar
		health:Height(PLAYER_TARGET_HEIGHT)
		power:Height(2)
		
		health.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		health.value:SetParent(self)
		health.PostUpdate = T.PostUpdateHealth
		
		power.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.value:SetParent(self)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower

		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", nil, health)
			portrait:SetFrameLevel(health:GetFrameLevel())
			portrait:SetAllPoints(health)
			portrait:SetAlpha(.5)
			portrait.PostUpdate = T.PortraitUpdate 
			self.Portrait = portrait
				
			local overlay = CreateFrame("Frame", nil, self)
			overlay:SetFrameLevel(self:GetFrameLevel() - 2)
				
			health.bg:ClearAllPoints()
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)
			health.bg:SetDrawLayer("OVERLAY", 7)
			health.bg:SetParent(overlay)
		end
		
		if T.myclass == "PRIEST" and C["unitframes"].weakenedsoulbar then
			local ws = CreateFrame("StatusBar", self:GetName().."_WeakenedSoul", power)
			ws:Height(2)
			ws:Point("BOTTOMLEFT", power, "TOPLEFT", 0, 1)
			ws:Point("BOTTOMRIGHT", power, "TOPRIGHT", 0, 1)
			ws:SetStatusBarTexture(blankTex)
			ws:GetStatusBarTexture():SetHorizTile(false)
			ws:SetBackdrop(backdrop)
			ws:SetBackdropColor(unpack(C.media.backdropcolor))
			ws:SetStatusBarColor(191/255, 10/255, 10/255)
			
			self.WeakenedSoul = ws
		end
	
		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:Height(19)
			Combat:Width(19)
			Combat:SetPoint("BOTTOM",0,1)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(health)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			FlashInfo.ManaLevel:SetPoint("CENTER", health, "CENTER", 0, 1)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			status:SetPoint("CENTER", health, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31)
			status:Hide()
			self.Status = status
			self:Tag(status, "[pvp]")
			
			-- leader icon
			local Leader = InvFrame:CreateTexture(nil, "OVERLAY")
			Leader:Height(14)
			Leader:Width(14)
			Leader:Point("TOPLEFT", 2, 8)
			self.Leader = Leader
			
			-- master looter
			local MasterLooter = InvFrame:CreateTexture(nil, "OVERLAY")
			MasterLooter:Height(14)
			MasterLooter:Width(14)
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)

			-- experience bar on player via mouseover for player currently levelling a character
			if T.level ~= MAX_PLAYER_LEVEL then
				local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
				--Experience:SetParent(TukuiMinimap)
				Experience:SetStatusBarTexture(blankTex)
				Experience:SetStatusBarColor(0, 0.4, 1, 1)
				Experience:SetBackdrop(backdrop)
				Experience:SetBackdropColor(unpack(C["media"].backdropcolor))
				Experience:Width(5)
				Experience:Height(PLAYER_TARGET_HEIGHT)
				Experience:Point("RIGHT", TukuiPlayer, "LEFT", -7, 4)
				Experience:SetOrientation("Vertical")
				Experience:SetFrameLevel(12)
				Experience:SetAlpha(0)				
				Experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
				Experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
				Experience.Tooltip = true		
				Experience.Rested = CreateFrame('StatusBar', nil, self)
				Experience.Rested:SetParent(Experience)
				Experience.Rested:SetAllPoints(Experience)
				Experience.Rested:SetStatusBarTexture(blankTex)
				Experience.Rested:SetOrientation("Vertical")
				Experience.Rested:SetStatusBarColor(0, 1, 0, .2)
				local xpBG = CreateFrame("Frame", nil, Experience)
				xpBG:CreatePanel("Transparent", Experience:GetWidth(), Experience:GetHeight(), "TOPLEFT", Experience, "TOPLEFT", -2, 2)
				xpBG:Point("BOTTOMRIGHT", Experience, "BOTTOMRIGHT", 2, -2)
	
				local Resting = Experience:CreateTexture(nil, "OVERLAY")
				Resting:Height(28)
				Resting:Width(28)
				Resting:SetPoint("BOTTOMRIGHT", TukuiPlayer, "TOPLEFT", 3, 3)
				Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
				Resting:SetTexCoord(0, 0.5, 0, 0.421875)
				self.Resting = Resting
				self.Experience = Experience
			end
			
			-- reputation bar for max level character
			if T.level == MAX_PLAYER_LEVEL then
				local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
				--Reputation:SetParent(TukuiMinimap)
				Reputation:SetStatusBarTexture(blankTex)
				Reputation:SetBackdrop(backdrop)
				Reputation:SetBackdropColor(unpack(C["media"].backdropcolor))
				Reputation:Width(5)
				Reputation:SetOrientation("Vertical")
				Reputation:Height(PLAYER_TARGET_HEIGHT)
				Reputation:Point("RIGHT", TukuiPlayer, "LEFT", -7, 4)
				Reputation:SetFrameLevel(10)
				Reputation:SetOrientation("Vertical")
				
				Reputation:SetAlpha(0)

				Reputation:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
				Reputation:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
				
				local repBG = CreateFrame("Frame", nil, Reputation)
				repBG:CreatePanel("Transparent", Reputation:GetWidth(), Reputation:GetHeight(), "TOPLEFT", Reputation, "TOPLEFT", -2, 2)
				repBG:Point("BOTTOMRIGHT", Reputation, "BOTTOMRIGHT", 2, -2)

				Reputation.PostUpdate = T.UpdateReputationColor
				Reputation.Tooltip = true
				self.Reputation = Reputation
			end
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
					if T.lowversion then
						eclipseBar:Size(186, 8)
					else
						eclipseBar:Size(250, 8)
					end
					eclipseBar:SetFrameStrata("MEDIUM")
					eclipseBar:SetFrameLevel(8)
					eclipseBar:SetTemplate("Default")
					eclipseBar:SetBackdropBorderColor(0,0,0,0)
					eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
					
					local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
					lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
					lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					lunarBar:SetStatusBarTexture(normTex)
					lunarBar:SetStatusBarColor(.30, .52, .90)
					eclipseBar.LunarBar = lunarBar

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar

					local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
					eclipseBarText:SetPoint('TOP', panel)
					eclipseBarText:SetPoint('BOTTOM', panel)
					eclipseBarText:SetFont(font1, 12)
					eclipseBar.PostUpdatePower = T.EclipseDirection
					
					-- hide "low mana" text on load if eclipseBar is show
					if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end

					self.EclipseBar = eclipseBar
					self.EclipseBar.Text = eclipseBarText
				end
				
				-- shaman totem bar
				if T.myclass == "SHAMAN" then
					
					local TotemBar = {}
					TotemBar.Destroy = true
					for i = 1, 4 do
						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
						if i == 1 then
							TotemBar[i]:Point("BOTTOMLEFT", TukuiBar1 or TukuiBar4, "TOPLEFT", 2, 5)
						else
							TotemBar[i]:Point("LEFT", TotemBar[i-1], "RIGHT", 8, 0)
						end
						TotemBar[i]:Size((TukuiBar1:GetWidth() / 4) - 7, 3)
						TotemBar[i]:SetStatusBarTexture(blankTex)
						TotemBar[i]:SetBackdrop(backdrop)
						TotemBar[i]:SetBackdropColor(0, 0, 0)
						TotemBar[i]:SetMinMaxValues(0, 1)

						TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
						TotemBar[i].bg:SetAllPoints(TotemBar[i])
						TotemBar[i].bg:SetTexture(blankTex)
						TotemBar[i].bg.multiplier = 0.3
						
						tBorder = CreateFrame("Frame", nil, TotemBar[i])
						tBorder:Point("TOPLEFT", TotemBar[i], "TOPLEFT", -2, 2)
						tBorder:Point("BOTTOMRIGHT", TotemBar[i], "BOTTOMRIGHT", 2, -2)
						tBorder:SetFrameLevel(TotemBar[i]:GetFrameLevel() - 1)
						tBorder:SetTemplate("Default")
						tBorder:CreateShadow()
					end
					self.TotemBar = TotemBar
				end
			end
			
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:Hide()
				status:Show()
				UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:Show()
				status:Hide()
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			Name:Point("CENTER", panel, "CENTER", 0, 0)
			Name:SetJustifyH("LEFT")
			Name:SetParent(self)

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name
		end

		if (unit == "target" and C["unitframes"].targetauras) or (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 30)	
			buffs:Height(24)
			buffs:Width(PLAYER_TARGET_WIDTH)
			buffs.size = 24
			buffs.num = 8
				
			debuffs:Height(24)
			debuffs:Width(PLAYER_TARGET_WIDTH)
			debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 3, 3)
			debuffs.size = 24
			debuffs.num = 27
						
			buffs.spacing = 3
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs	
						
			debuffs.spacing = 3
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			
			-- an option to show only our debuffs on target
			if unit == "target" then
				debuffs.onlyShowPlayer = C.unitframes.onlyselfdebuffs
			end
			
			self.Debuffs = debuffs
		end
		
		-- cast bar for player and target
		if (C["unitframes"].unitcastbar == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(0, 0, 0, 0)
			castbar:SetFrameLevel(6)
			
			if unit == "player" then
				castbar:Size(C.castbar.player.width, C.castbar.player.height)
				castbar:Point(unpack(C.castbar.player.anchor))
			elseif unit == "target" then
				castbar:Size(C.castbar.target.width, C.castbar.target.height)
				castbar:Point(unpack(C.castbar.target.anchor))
			end
				
			local cbborder = CreateFrame("Frame", nil, castbar)
			cbborder:CreatePanel("Transparent", 1, 1, "CENTER", castbar, "CENTER", 0, 0)
			cbborder:ClearAllPoints()
			cbborder:Point("TOPLEFT", castbar, -2, 2)
			cbborder:Point("BOTTOMRIGHT", castbar, 2, -2)
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			if C["unitframes"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:Size(26)
				castbar.button:SetTemplate("Default")
				castbar.button:CreateShadow("Default")

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
				castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					if C["unitframes"].charportrait == true then
						castbar.button:SetPoint("LEFT", -82.5, 26.5)
					else
						castbar.button:SetPoint("LEFT", -46.5, 26.5)
					end
				elseif unit == "target" then
					if C["unitframes"].charportrait == true then
						castbar.button:SetPoint("RIGHT", 82.5, 26.5)
					else
						castbar.button:SetPoint("RIGHT", 46.5, 26.5)
					end					
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and C["unitframes"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
			
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
			CombatFeedbackText:SetPoint("TOP", 0, -1)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			if T.lowversion then
				mhpb:Width(186)
			else
				mhpb:Width(250)
			end
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:Width(250)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") then
		health:Height(TARGET_TARGET_HEIGHT)
		power:Height(2)
		
		-- Unit name
		local Name = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, 1)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if C["unitframes"].totdebuffs == true and T.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:Height(20)
			debuffs:Width(127)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6

			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -0.5, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
		health:Height(PET_HEIGHT)
		power:Height(2)
		
		health.PostUpdate = T.PostUpdatePetColor
	
		-- Unit name
		local Name = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, 1)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
		
		if (C["unitframes"].unitcastbar == true) then
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			self.Castbar = castbar
			
			if not T.lowversion then
				castbar.bg = castbar:CreateTexture(nil, "BORDER")
				castbar.bg:SetAllPoints(castbar)
				castbar.bg:SetTexture(normTex)
				castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
				castbar:SetFrameLevel(6)
				castbar:Point("TOPLEFT", panel, 2, -2)
				castbar:Point("BOTTOMRIGHT", panel, -2, 2)
				
				castbar.CustomTimeText = T.CustomCastTimeText
				castbar.CustomDelayText = T.CustomCastDelayText
				castbar.PostCastStart = T.CheckCast
				castbar.PostChannelStart = T.CheckChannel

				castbar.time = T.SetFontString(castbar, font1, 12)
				castbar.time:Point("RIGHT", panel, "RIGHT", -4, 0)
				castbar.time:SetTextColor(0.84, 0.75, 0.65)
				castbar.time:SetJustifyH("RIGHT")

				castbar.Text = T.SetFontString(castbar, font1, 12)
				castbar.Text:Point("LEFT", panel, "LEFT", 4, 0)
				castbar.Text:SetTextColor(0.84, 0.75, 0.65)
				
				self.Castbar.Time = castbar.time
			end
		end
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit, health and bar color sometime being "grayish".
		self:RegisterEvent("UNIT_PET", T.updateAllElements)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		health:Height(FOCUS_HEIGHT)
		power:Height(2)
		
		health.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		health.PostUpdate = T.PostUpdateHealth
	
		power.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		-- Unit name
		local Name = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, 1)
		Name:SetJustifyH("CENTER")
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name

		-- create debuff for focus
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:Height(FOCUS_HEIGHT + 4)
		debuffs:Width(200)
		debuffs:Point('RIGHT', self, 'LEFT', -6, 2)
		debuffs.size = FOCUS_HEIGHT + 4
		debuffs.num = 4
		debuffs.spacing = 3
		debuffs.initialAnchor = 'RIGHT'
		debuffs["growth-x"] = "LEFT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
		
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("TOP", self, "BOTTOM", 0, -3)
		castbar:Width(FOCUS_WIDTH)
		castbar:Height(14)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Transparent")
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		castbar.bg:CreateShadow()
		
		castbar.time = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(22)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = T.SetFontString(health, font1,12, "OUTLINE")
		health.value:Point("LEFT", 2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.250, .250, .250, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(6)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, font1, 12, "OUTLINE")
		power.value:Point("RIGHT", -2, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:Height(26)
		debuffs:Width(200)
		debuffs:Point('RIGHT', self, 'LEFT', -4, 0)
		debuffs.size = 26
		debuffs.num = 5
		debuffs.spacing = 2
		debuffs.initialAnchor = 'RIGHT'
		debuffs["growth-x"] = "LEFT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
		
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", 2, 0)
		castbar:SetPoint("RIGHT", -24, 0)
		castbar:SetPoint("BOTTOM", 0, -22)
		
		castbar:Height(16)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font1, 12)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font1, 12)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("LEFT", castbar, "RIGHT", 4, 0)
		castbar.button:SetTemplate("Default")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
	
		health:Height(BOSS_HEIGHT)
		health.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		health.PostUpdate = T.PostUpdateHealth
		
		power:Height(2)
		power.value = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		-- names
		local Name = T.SetFontString(health, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if (unit and unit:find("boss%d")) then
			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			AltPowerBar:Height(4)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)

			AltPowerBar:SetPoint("LEFT")
			AltPowerBar:SetPoint("RIGHT")
			AltPowerBar:SetPoint("TOP", self.Health, "TOP")
			
			AltPowerBar:SetBackdrop({
			  bgFile = C["media"].blank, 
			  edgeFile = C["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = T.Scale(1), 
			  insets = { left = 0, right = 0, top = 0, bottom = T.Scale(-1)}
			})
			AltPowerBar:SetBackdropColor(0, 0, 0)

			self.AltPowerBar = AltPowerBar
			
			-- create buff at left of unit if they are boss units
			local buffs = CreateFrame("Frame", nil, self)
			buffs:Height(26)
			buffs:Width(252)
			buffs:Point("RIGHT", self, "LEFT", -4, 0)
			buffs.size = 26
			buffs.num = 3
			buffs.spacing = 2
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
			
			-- because it appear that sometime elements are not correct.
			self:HookScript("OnShow", T.updateAllElements)
		end

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:Height(26)
		debuffs:Width(200)
		debuffs:Point('LEFT', self, 'RIGHT', 4, 0)
		debuffs.size = 26
		debuffs.num = 5
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
				
		-- trinket feature via trinket plugin
		if (C.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:Height(BOSS_HEIGHT + 4)
			Trinketbg:Width(BOSS_HEIGHT + 4)
			Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)				
			Trinketbg:SetTemplate("Transparent")
			Trinketbg:CreateShadow()
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:Point("TOPLEFT", Trinketbg, 2, -2)
			Trinket:Point("BOTTOMRIGHT", Trinketbg, -2, 2)
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
		end
		
		-- boss & arena frames cast bar!
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", 0, 0)
		castbar:SetPoint("RIGHT", 0, 0)
		castbar:SetPoint("TOP", self, "BOTTOM", 0, -8)
		
		castbar:Height(4)
		castbar:SetStatusBarTexture(blankTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.250, .250, .250, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------
oUF:RegisterStyle('Tukui', Shared)

-- spawn
local player = oUF:Spawn('player', "TukuiPlayer")
local target = oUF:Spawn('target', "TukuiTarget")
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
local pet = oUF:Spawn('pet', "TukuiPet")
local focus = oUF:Spawn('focus', "TukuiFocus")

-- sizes
player:Size(PLAYER_TARGET_WIDTH, player.Health:GetHeight() + player.Power:GetHeight() + player.panel:GetHeight() + 6)
target:Size(PLAYER_TARGET_WIDTH, target.Health:GetHeight() + target.Power:GetHeight() + target.panel:GetHeight() + 6)
tot:SetSize(TARGET_TARGET_WIDTH, tot.Health:GetHeight() + tot.Power:GetHeight() + tot.panel:GetHeight() + 6)
pet:SetSize(PET_WIDTH, pet.Health:GetHeight() + pet.Power:GetHeight() + pet.panel:GetHeight() + 6)	
focus:SetSize(FOCUS_WIDTH, focus.Health:GetHeight() + focus.Power:GetHeight() + 3)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)

	if addon == "Tukui_Raid" then
		--[ DPS ]--
		player:Point("TOP", UIParent, "BOTTOM", -179 , 230)
		target:Point("TOP", UIParent, "BOTTOM", 179, 230)
		tot:Point("TOPRIGHT", TukuiTarget, "BOTTOMRIGHT", 0, -7)
		pet:Point("TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -7)
		focus:Point("TOP", UIParent, "BOTTOM", -400, 400)
	elseif addon == "Tukui_Raid_Healing" then
		--[ HEAL ]--
		player:Point("TOP", UIParent, "BOTTOM", -309 , 300)
		target:Point("TOP", UIParent, "BOTTOM", 309, 300)
		tot:Point("TOPRIGHT", TukuiTarget, "BOTTOMRIGHT", 0, -7)
		pet:Point("TOPLEFT", TukuiPlayer, "BOTTOMLEFT", 0, -7)
		focus:Point("TOP", UIParent, "BOTTOM", -400, 400)
		
	end
end)

if C.unitframes.showfocustarget then
	local focustarget = oUF:Spawn("focustarget", "TukuiFocusTarget")
	focustarget:SetPoint("BOTTOM", focus, "TOP", 0 , 35)
	focustarget:Size(200, 29)
end


if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:SetPoint("TOP", UIParent, "BOTTOM", 400, 400)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 35)
		end
		arena[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
	end
end

if C["unitframes"].showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = T.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("TOP", UIParent, "BOTTOM", 400, 400)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 35)             
		end
		boss[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
	end
end

local assisttank_width = 100
local assisttank_height  = 20
if C["unitframes"].maintank == true then
	local tank = oUF:SpawnHeader('TukuiMainTank', nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:Width(%d)
			self:Height(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINTANK',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
 
if C["unitframes"].mainassist == true then
	local assist = oUF:SpawnHeader("TukuiMainAssist", nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:Width(%d)
			self:Height(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINASSIST',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	if C["unitframes"].maintank == true then
		assist:SetPoint("TOPLEFT", TukuiMainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end

local moveUFs = CreateFrame("Frame")
moveUFs:RegisterEvent("PLAYER_ENTERING_WORLD")
moveUFs:RegisterEvent("UNIT_NAME_UPDATE")
moveUFs:RegisterEvent("RAID_ROSTER_UPDATE")
moveUFs:RegisterEvent("RAID_TARGET_UPDATE")
moveUFs:RegisterEvent("PARTY_MEMBERS_CHANGED")
moveUFs:SetScript("OnEvent", function(self)
	if not IsAddOnLoaded("Tukui_Raid_Healing") or not C["unitframes"].actionbarpos then return end

	if TukuiGrid:IsVisible() then
		TukuiBar1:Width((T.buttonsize * 12) + (T.buttonspacing * 13) + 2)
		TukuiBar4:Width((T.buttonsize * 12) + (T.buttonspacing * 13) + 2)
		ActionButton1:SetPoint("BOTTOMLEFT", T.buttonspacing+1, T.buttonspacing)
		MultiBarLeftButton1:SetPoint("TOPLEFT", TukuiBar4, T.buttonspacing+1, -T.buttonspacing)
		player:ClearAllPoints()
		target:ClearAllPoints()
		player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", -40, 116)
		target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 40, 116)
		tot:SetAlpha(0)
	else
		TukuiBar1:Width((T.buttonsize * 12) + (T.buttonspacing * 13))
		TukuiBar4:Width((T.buttonsize * 12) + (T.buttonspacing * 13))
		ActionButton1:SetPoint("BOTTOMLEFT", T.buttonspacing, T.buttonspacing)
		MultiBarLeftButton1:SetPoint("TOPLEFT", TukuiBar4, T.buttonspacing, -T.buttonspacing)
		player:ClearAllPoints()
		target:ClearAllPoints()
		player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 0,8+adjustXY)
		target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0,8+adjustXY)
		tot:SetAlpha(1)
	end
end)