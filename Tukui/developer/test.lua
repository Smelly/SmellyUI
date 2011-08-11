local T, C, L = unpack(select(2, ...))

--[[ Little side project semi broken atm

local poisons = {
	[1] = {"Crippling Poison"},
	[2] = {"Instant Poison"},
	[3] = {"Deadly Poison"},
	[4] = {"Wound Poison"},
	[5] = {"Mind-Numbing Poison"},
}

local macros = {
	[1] = {"/use Crippling Poison\n/use [button:1] 16\n/use[button:2] 17\n/click StaticPopup1Button1"},
	[2] = {"/use Instant Poison\n/use [button:1] 16\n/use[button:2] 17\n/click StaticPopup1Button1"},
	[3] = {"/use Deadly Poison\n/use [button:1] 16\n/use[button:2] 17\n/click StaticPopup1Button1"},
	[4] = {"/use Wound Poison\n/use [button:1] 16\n/use[button:2] 17\n/click StaticPopup1Button1"},
	[5] = {"/use Mind-Numbing Poison\n/use [button:1] 16\n/use[button:2] 17\n/click StaticPopup1Button1"},
}

local charges = {0,0,0,0,0} -- sets stack amound to 0 initially
local c = 1
local function find_poisons(search)
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag,slot) 
			local itemCount = select(2, GetContainerItemInfo(bag, slot))
			if item and item:find(search) then
			--	print("Found: "..item.."With "..itemCount.." charges.")
				-- make current array index = stack amount
				charges[c] = tonumber(itemCount)
				c = c + 1
			end
		end
	end
end

local function get_poison_count()
	for k, v in ipairs(poisons) do
		find_poisons(unpack(v))
		print(charges[k])
	end
end

local buttons = {}
local function init_buttons()
	for i, v in ipairs(poisons) do
		local itemTexture  = select(10, GetItemInfo(unpack(v)))
		
		buttons[i] = CreateFrame("Button", "buttons", UIParent, "SecureActionButtonTemplate")
		buttons[i]:CreatePanel("Default", 40, 40, "CENTER", UIParent, "CENTER", 0, 0)
		if i == 1 then
			buttons[i]:Point("CENTER", UIParent, "CENTER", 0, 0)
		else
			buttons[i]:Point("LEFT", buttons[i-1], "RIGHT", 4, 0)
		end
		buttons[i]:SetAttribute("type", "macro")
		buttons[i]:SetAttribute("macrotext", unpack(macros[i]))
		buttons[i].Icon = buttons[i]:CreateTexture(nil, "ARTWORK")
		buttons[i].Icon:Point("TOPLEFT", buttons[i], "TOPLEFT", 2, -2)
		buttons[i].Icon:Point("BOTTOMRIGHT", buttons[i], "BOTTOMRIGHT", -2, 2)
		buttons[i].Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		buttons[i].Icon:SetTexture(itemTexture)
		
		buttons[i].count = T.SetFontString(buttons[i], C.media.pfont, 12, "MONOCHROMEOUTLINE")
		buttons[i].count:Point("CENTER", buttons[i])
		buttons[i].count:SetText(charges[i])
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", function()
	get_poison_count()
	init_buttons()
end)]]