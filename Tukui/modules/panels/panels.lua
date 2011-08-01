local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local TukuiBar1 = CreateFrame("Frame", "TukuiBar1", UIParent, "SecureHandlerStateTemplate")
TukuiBar1:CreatePanel("Transparent", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 3)
TukuiBar1:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar1:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar1:SetFrameStrata("BACKGROUND")
TukuiBar1:SetFrameLevel(1)

local TukuiBar2 = CreateFrame("Frame", "TukuiBar2", UIParent)
TukuiBar2:CreatePanel("Transparent", 1, 1, "BOTTOMRIGHT", TukuiBar1, "BOTTOMLEFT", -6, 0)
TukuiBar2:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar2:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar2:SetFrameStrata("BACKGROUND")
TukuiBar2:SetFrameLevel(2)
TukuiBar2:SetAlpha(0)
if T.lowversion then
	TukuiBar2:SetAlpha(0)
else
	TukuiBar2:SetAlpha(1)
end

local TukuiBar3 = CreateFrame("Frame", "TukuiBar3", UIParent)
TukuiBar3:CreatePanel("Transparent", 1, 1, "BOTTOMLEFT", TukuiBar1, "BOTTOMRIGHT", 6, 0)
TukuiBar3:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar3:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar3:SetFrameStrata("BACKGROUND")
TukuiBar3:SetFrameLevel(2)
if T.lowversion then
	TukuiBar3:SetAlpha(0)
else
	TukuiBar3:SetAlpha(1)
end

local TukuiBar4 = CreateFrame("Frame", "TukuiBar4", UIParent)
TukuiBar4:SetPoint("BOTTOM", TukuiBar1, "BOTTOM", 0, 0)
TukuiBar4:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar4:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar4:SetFrameStrata("BACKGROUND")
TukuiBar4:SetFrameLevel(2)
TukuiBar4:SetAlpha(0)

local TukuiBar5 = CreateFrame("Frame", "TukuiBar5", UIParent)
TukuiBar5:CreatePanel("Transparent", 1, (T.buttonsize * 12) + (T.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", -3, -14)
TukuiBar5:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar5:SetFrameStrata("BACKGROUND")
TukuiBar5:SetFrameLevel(2)
TukuiBar5:SetAlpha(0)

local TukuiBar6 = CreateFrame("Frame", "TukuiBar6", UIParent)
TukuiBar6:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar6:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar6:SetPoint("LEFT", TukuiBar5, "LEFT", 0, 0)
TukuiBar6:SetFrameStrata("BACKGROUND")
TukuiBar6:SetFrameLevel(2)
TukuiBar6:SetAlpha(0)

local TukuiBar7 = CreateFrame("Frame", "TukuiBar7", UIParent)
TukuiBar7:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar7:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar7:SetPoint("TOP", TukuiBar5, "TOP", 0 , 0)
TukuiBar7:SetFrameStrata("BACKGROUND")
TukuiBar7:SetFrameLevel(2)
TukuiBar7:SetAlpha(0)

local petbg = CreateFrame("Frame", "TukuiPetBar", UIParent, "SecureHandlerStateTemplate")
petbg:CreatePanel("Transparent",(T.petbuttonsize * 10) + (T.petbuttonspacing * 11), T.petbuttonsize + (T.petbuttonspacing * 2), "BOTTOM", TukuiBar1 or TukuiBar4, "TOP", 0, 4)
-- fucking spirit wolves.
if T.myclass == "SHAMAN" then
	petbg:Point("BOTTOM", TukuiBar1 or TukuiBar4, "TOP", 0, 13)
end
petbg:SetAlpha(0)

local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground", petbg)
ltpetbg1:CreatePanel("Default", 24, 265, "LEFT", petbg, "RIGHT", 0, 0)
ltpetbg1:SetParent(petbg)
ltpetbg1:SetFrameStrata("BACKGROUND")
ltpetbg1:SetFrameLevel(0)
ltpetbg1:SetAlpha(0)

-- INVISIBLE FRAME COVERING BOTTOM ACTIONBARS JUST TO PARENT UF CORRECTLY
local invbarbg = CreateFrame("Frame", "InvTukuiActionBarBackground", UIParent)
if T.lowversion then
	invbarbg:SetPoint("TOPLEFT", TukuiBar1)
	invbarbg:SetPoint("BOTTOMRIGHT", TukuiBar1)
	TukuiBar2:Hide()
	TukuiBar3:Hide()
else
	invbarbg:SetPoint("TOPLEFT", TukuiBar2)
	invbarbg:SetPoint("BOTTOMRIGHT", TukuiBar3)
end

if not C.chat.background then
	-- CUBE AT LEFT, ACT AS A BUTTON (CHAT MENU)
	local cubeleft = CreateFrame("Frame", "TukuiCubeLeft", TukuiBar1)
	cubeleft:CreatePanel("Default", 10, 10, "BOTTOM", ileftlv, "TOP", 0, 0)
	cubeleft:EnableMouse(true)
	cubeleft:SetScript("OnMouseDown", function(self, btn)
		if TukuiInfoLeftBattleGround and UnitInBattleground("player") then
			if btn == "RightButton" then
				if TukuiInfoLeftBattleGround:IsShown() then
					TukuiInfoLeftBattleGround:Hide()
				else
					TukuiInfoLeftBattleGround:Show()
				end
			end
		end
		
		if btn == "LeftButton" then	
			ToggleFrame(ChatMenu)
		end
	end)

	-- CUBE AT RIGHT, ACT AS A BUTTON (CONFIGUI or BG'S)
	local cuberight = CreateFrame("Frame", "TukuiCubeRight", TukuiBar1)
	cuberight:CreatePanel("Default", 10, 10, "BOTTOM", irightlv, "TOP", 0, 0)
	if C["bags"].enable then
		cuberight:EnableMouse(true)
		cuberight:SetScript("OnMouseDown", function(self)
			if T.toc < 40200 then ToggleKeyRing() else ToggleAllBags() end
		end)
	end
end

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "TukuiInfoLeft", TukuiBar1)
ileft:CreatePanel("Default", T.InfoLeftRightWidth, 23, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 3)
ileft:SetFrameLevel(2)
ileft:SetFrameStrata("BACKGROUND")
ileft:SetAlpha(0)

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "TukuiInfoRight", TukuiBar1)
iright:CreatePanel("Default", T.InfoLeftRightWidth, 23, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -3, 3)
iright:SetFrameLevel(2)
iright:SetFrameStrata("BACKGROUND")
iright:SetAlpha(0)

-- CHAT BG LEFT
local chatleftbg = CreateFrame("Frame", "TukuiChatBackgroundLeft", UIParent)
chatleftbg:CreatePanel("Transparent", T.InfoLeftRightWidth, 160, "BOTTOM", TukuiInfoLeft, "BOTTOM", 0, 0)

local linfoline = CreateFrame("Frame", "TukuiLeftInfoLine", TukuiChatBackgroundLeft)
linfoline:CreatePanel("Default", chatleftbg:GetWidth() - 16, 2, "BOTTOMLEFT", chatleftbg, "BOTTOMLEFT", 8, 20)

-- CHAT BG RIGHT
local chatrightbg = CreateFrame("Frame", "TukuiChatBackgroundRight", UIParent)
chatrightbg:CreatePanel("Transparent", T.InfoLeftRightWidth, 160, "BOTTOM", TukuiInfoRight, "BOTTOM", 0, 0)

local rinfoline = CreateFrame("Frame", "TukuiRightInfoLine", TukuiChatBackgroundRight)
rinfoline:CreatePanel("Default", chatrightbg:GetWidth() - 16, 2, "BOTTOMLEFT", chatrightbg, "BOTTOMLEFT", 8, 20)

local toggleFrame = CreateFrame("Frame", "toggleFrame", UIParent)
toggleFrame:CreatePanel("Default", 45, 15, "TOPLEFT", UIParent, "TOPLEFT", 3, -3, true)
toggleFrame:EnableMouse()
toggleFrame.text:SetText("Chat")
T.ApplyHover(toggleFrame)

T.fadeIn(TukuiChatBackgroundLeft)
T.fadeIn(TukuiChatBackgroundRight)

toggleFrame:SetScript("OnMouseDown", function(self)
	if not TukuiChatBackgroundLeft:IsVisible() then
		TukuiChatBackgroundLeft:Show()
		TukuiChatBackgroundRight:Show()
	else
		T.fadeOut(TukuiChatBackgroundLeft)
		T.fadeOut(TukuiChatBackgroundRight)
	end
end)

--BATTLEGROUND STATS FRAME (not done yet)
if C["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	bgframe:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetFrameLevel(0)
	bgframe:EnableMouse(true)
end

-- minimap button skinning, credits to Elv for original base code
local function SkinButton(f)
    if f:GetObjectType() ~= "Button" then return end
	f:SetPushedTexture(nil)
    f:SetHighlightTexture(nil)
    f:SetDisabledTexture(nil)
	f:SetSize(22, 22)
	
    for i=1, f:GetNumRegions() do
        local region = select(i, f:GetRegions())
        if region:GetObjectType() == "Texture" then
            local tex = region:GetTexture()
            if tex:find("Border") or tex:find("Background") then
                region:SetTexture(nil)
            else
				region:SetDrawLayer("OVERLAY", 5)
                region:ClearAllPoints()
                region:Point("TOPLEFT", f, "TOPLEFT", 2, -2)
                region:Point("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
                region:SetTexCoord(.08, .92, .08, .92)
            end
        end
    end
	f:SetTemplate("Default")
	f:SetFrameLevel(f:GetFrameLevel() + 2)
	f.bg:SetFrameLevel(f:GetFrameLevel() - 1)
    T.ApplyHover(f)
	
end
local x = CreateFrame("Frame")
x:RegisterEvent("PLAYER_LOGIN")
x:SetScript("OnEvent", function(self, event)
    for i=1, Minimap:GetNumChildren() do
        SkinButton(select(i, Minimap:GetChildren()))
    end
    self = nil
end)

-- move button
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:Point("BOTTOMRIGHT", TukuiMinimap, "BOTTOMRIGHT", -4, 4)