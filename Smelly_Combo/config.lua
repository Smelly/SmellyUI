local T, C, L = unpack(Tukui)

Options = {
	-- Config for combo points
	["core"] = { 
		spacing = T.Scale(3), 			-- spacing between combo points
		width = T.Scale(50),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -107, -135},	-- default anchor (completely centered)
	},
	
	-- Coloring options for combo points
	["colors"] = { 
		[1] = {.69, .31, .31, 1},
		[2] = {.65, .42, .31, 1},
		[3] = {.65, .63, .35, 1},
		[4] = {.46, .63, .35, 1},
		[5] = {.33, .63, .33, 1},
	},
	
	-- Power plugin options
	["power"] = {
		power = false,
		text = true,					-- display power text
		width = T.Scale(262), 			-- perfectly fits width of combo points
		height = T.Scale(10),
		anchor = {"CENTER", UIParent, "CENTER", -1, -215},	-- default anchor
	},
	
	-- Holy Power Plugin
	["holy"] = { 
		holy = true,					-- enable holy power
		spacing = T.Scale(3),			-- spacing between combo points
		width = T.Scale(96),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -100, -135},	-- default anchor
	},
	
	-- Soul Shard Plugin
	["soul"] = { 
		soul = true,					-- enable soul shards
		spacing = T.Scale(3), 			-- spacing between combo points
		width = T.Scale(96),  			-- width of bars
		height = T.Scale(15), 			-- height of bars
		anchor = {"CENTER", UIParent, "CENTER", -100, -135},	-- default anchor
	},
}
