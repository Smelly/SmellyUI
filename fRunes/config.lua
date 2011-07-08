if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then return end

local T, C, L = unpack(Tukui)

fRunesSettings = {
	texture = C.media.blank,
	barLength = 34,
	barThickness = 14,
	rpBarThickness = 10,
	anchor = UIParent,
	hideOOC = false,
	x = 0,
	y = 232,
	growthDirection = "VERTICAL", -- HORIZONTAL or VERTICAL
	
	displayRpBar = false, -- runic power bar below the runes
	displayRpBarText = true, -- runic power text on the runic power bar
	
	runestrike = false, -- shows a rune strike icon whenever it's usable
	
	colors = {
		{.69,.31,.31}, -- blood
		{.33,.59,.33}, -- unholy
		{.31,.45,.63}, -- frost
		{.84,.75,.65}, -- death
		{0, 0.82, 1}, -- runic power
	},
	
	--[[
		runemap instructions.
		This is the order you want your runes to be displayed in (down to bottom or left to right).
		1,2 = Blood
		3,4 = Unholy
		5,6 = Frost
		(Note: All numbers must be included or it will break)
	]]
	runemap = { 1, 2, 3, 4, 5, 6 },
}