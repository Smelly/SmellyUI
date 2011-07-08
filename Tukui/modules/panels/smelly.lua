local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

----------------------------------------------------------------------------------
-- Config Panel ------------------------------------------------------------------
----------------------------------------------------------------------------------

-- BG for action bar config
local actionBarBG = CreateFrame("Frame", "actionBarBG", UIParent)
actionBarBG:CreatePanel("Transparent", 150, 61, "CENTER", UIParent, "CENTER", 0, 0)
if T.lowversion then
	actionBarBG:Height(61)
else
	actionBarBG:Height(80)
end
T.fadeIn(actionBarBG)
actionBarBG:SetFrameLevel(15)
actionBarBG:Hide()

local abHeader = CreateFrame("Frame", "abHeader", actionBarBG)
abHeader:CreatePanel("Transparent", actionBarBG:GetWidth(), 20, "BOTTOM", actionBarBG, "TOP", 0, 3, true)
abHeader.text:SetText("Actionbar Config")
abHeader:CreateShadow()

-- BG for config menu
local extrasBG = CreateFrame("Frame", "extrasBG", UIParent)
extrasBG:CreatePanel("Transparent", 150, 194 , "CENTER", UIParent, "CENTER", 0, 0)
extrasBG:SetFrameLevel(10)
extrasBG:SetFrameStrata("DIALOG")
extrasBG:Hide()
T.fadeIn(extrasBG)

local extraHeader = CreateFrame("Frame", "extraHeader", extrasBG)
extraHeader:CreatePanel("Transparent", extrasBG:GetWidth(), 20, "BOTTOM", extrasBG, "TOP", 0, 3, true)
extraHeader:CreateShadow()
extraHeader.text:SetText("Config")

-- close button inside action bar config
local closeAB = CreateFrame("Frame", "closeAB", actionBarBG)
closeAB:CreatePanel("Default", actionBarBG:GetWidth() - 8, 15, "BOTTOM", actionBarBG, "BOTTOM", 0, 4, true)
closeAB:SetFrameLevel(actionBarBG:GetFrameLevel() + 1)
T.ApplyHover(closeAB)
closeAB.text:SetText("Close")
closeAB:SetScript("OnMouseDown", function()
	T.fadeOut(actionBarBG)
	extrasBG:Show()
end)

-- slash command to open up actionbar config
function SlashCmdList.AB()
	if extrasBG:IsShown() then
		actionBarBG:Show()
		T.fadeOut(extrasBG)
	else
		actionBarBG:Show()
	end
end
SLASH_AB1 = "/ab"

-- setup config button slash commands
local buttons = {
	[1] = {"/rl"},
	[2] = {"/resetui"},
	[3]	= {"/dps"},
	[4] = {"/heal"},
	[5] = {"/moveui"},
	[6] = {"/ab"},
}

-- setup text in each button
local texts = {
	[1] = {"Reload UI"},
	[2] = {"Reset UI"},
	[3]	= {"Dps Layout"},
	[4] = {"Heal Layout"},
	[5] = {"Move UI"},
	[6] = {"Action Bars"},
}

-- create the config buttons
local button = CreateFrame("Button", "button", extrasBG)
for i = 1, getn(buttons) do
	button[i] = CreateFrame("Button", "button"..i, extrasBG, "SecureActionButtonTemplate")
	button[i]:CreatePanel("Default", extrasBG:GetWidth() - 8, 24, "TOP", extrasBG, "TOP", 0, -4, true)
	button[i]:SetFrameLevel(extrasBG:GetFrameLevel() + 1)
	button[i].text:SetText(unpack(texts[i]))
	if i == 1 then
		button[i]:Point("TOP", extrasBG, "TOP", 0, -4)
	else
		button[i]:Point("TOP", button[i-1], "BOTTOM", 0, -3)
	end
	button[i]:SetAttribute("type", "macro")
	button[i]:SetAttribute("macrotext", unpack(buttons[i]))
	button[i]:SetFrameStrata("DIALOG")
	T.ApplyHover(button[i])
end

local close = CreateFrame("Button", "close", extrasBG)
close:CreatePanel("Default", extrasBG:GetWidth() - 8, 24, "TOP", button[6], "BOTTOM", 0, -3, true)
close:SetFrameLevel(extrasBG:GetFrameLevel() + 1)
close:SetFrameStrata("DIALOG")
close.text:SetText("Close")
T.ApplyHover(close)
close:SetScript("OnMouseDown", function()
	T.fadeOut(extrasBG)
end)

local extraToggle = CreateFrame("Frame", "extraToggle", UIParent)
extraToggle:CreatePanel("Default", 45, 15, "LEFT", toggleFrame, "RIGHT", 3, 0, true)
extraToggle.text:SetText("Config")
T.ApplyHover(extraToggle)

extraToggle:SetScript("OnMouseDown", function(self)
	if not extrasBG:IsShown() then
		extrasBG:Show()
		T.fadeOut(actionBarBG)
	else
		T.fadeOut(extrasBG)
	end
end)

----------------------------------------------------------------------------------
-- Addon Manager -----------------------------------------------------------------
----------------------------------------------------------------------------------

-- Create BG
local addonBG = CreateFrame("Frame", "addonBG", UIParent)
addonBG:CreatePanel("Transparent", 280, 400, "CENTER", UIParent, "CENTER", 0, 0)
T.fadeIn(addonBG)
addonBG:Hide()

local addonHeader = CreateFrame("Frame", "addonHeader", addonBG)
addonHeader:CreatePanel("Transparent", addonBG:GetWidth(), 20, "BOTTOM", addonBG, "TOP", 0, 3, true)
addonHeader.text:SetText("Addon Control Menu")
addonHeader:CreateShadow()

-- Create inside BG (uses scroll frame)
local buttonsBG = CreateFrame("Frame", "buttonsBG", addonBG)

-- Create scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "scrollFrame", addonBG, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", addonBG, "TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", addonBG, "BOTTOMRIGHT", -30, 40)
scrollFrame:SetScrollChild(buttonsBG)

buttonsBG:CreatePanel("Default", scrollFrame:GetWidth(), scrollFrame:GetHeight(), "TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)

local saveButton = CreateFrame("Button", "saveButton", addonBG)
saveButton:CreatePanel("Default", 70, 24, "BOTTOMLEFT", addonBG, "BOTTOMLEFT", 10, 10, true)
saveButton.text:SetText("Save")
saveButton:SetScript("OnClick", function() ReloadUI() end)
T.ApplyHover(saveButton)

local closeButton = CreateFrame("Button", "closeButton", addonBG)
closeButton:CreatePanel("Default", 70, 24, "BOTTOMRIGHT", addonBG, "BOTTOMRIGHT", -10, 10, true)
closeButton.text:SetText("Close")
closeButton:SetScript("OnClick", function() T.fadeOut(addonBG) end)
T.ApplyHover(closeButton)

local addonToggle = CreateFrame("Frame", "addonToggle", UIParent)
addonToggle:CreatePanel("Default", 45, 15, "LEFT", extraToggle, "RIGHT", 3, 0, true)
addonToggle.text:SetText("Addon")
T.ApplyHover(addonToggle)
addonToggle:SetScript("OnMouseDown", function()
	if not addonBG:IsShown() then
		addonBG:Show()
	else
		T.fadeOut(addonBG)
	end
end)  

--
local function UpdateAddons()
	local addons = {}
	for i=1, GetNumAddOns() do
		addons[i] = select(1, GetAddOnInfo(i))
	end
	table.sort(addons)
	local oldb
	for i,v in pairs(addons) do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(v)
		local button = CreateFrame("Button", v.."_Button", buttonsBG, "SecureActionButtonTemplate")
		button:SetFrameLevel(buttonsBG:GetFrameLevel() + 1)
		button:Size(50, 16)
		button:SetTemplate("Default")
		button:CreateOverlay()

		-- to make sure the border is colored the right color on reload 
		if enabled then
			button:SetBackdropBorderColor(0,1,0)
		else
			button:SetBackdropBorderColor(1,0,0)
		end

		if i==1 then
			button:Point("TOPLEFT", buttonsBG, "TOPLEFT", 10, -10)
		else
			button:Point("TOP", oldb, "BOTTOM", 0, -7)
		end
		local text = T.SetFontString(button, C.media.pfont, 8, "MONOCHROMEOUTLINE")
		text:Point("LEFT", button, "RIGHT", 8, 0)
		text:SetText(name)
	
		button:SetScript("OnMouseDown", function()
			if enabled then
				button:SetBackdropBorderColor(1,0,0)
				DisableAddOn(name)
			else
				button:SetBackdropBorderColor(0,1,0)
				EnableAddOn(name)
			end
		end)
	
		oldb = button
	end
end

UpdateAddons()