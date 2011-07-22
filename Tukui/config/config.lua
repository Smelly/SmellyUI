local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

C["general"] = {
	["autoscale"] = true,                               -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.71,                                 -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["overridelowtohigh"] = false,                      -- EXPERIMENTAL ONLY! override lower version to higher version on a lower reso.
	["multisampleprotect"] = true,                      -- i don't recommend this because of shitty border but, voila!
	["backdropcolor"] = { 0, 0, 0, 1},                   -- default backdrop color of panels
	["bordercolor"] = { .15, .15, .15, 1 },                     -- default border color of panels
	["blizzardreskin"] = true                           -- reskin all Blizzard frames
}

C["unitframes"] = {
	-- general options
	["enable"] = true,                                  -- do i really need to explain this?
	["enemyhcolor"] = false,                            -- enemy target (players) color by hostility, very useful for healer.
	["unitcastbar"] = true,                             -- enable tukui castbar
	["cblatency"] = false,                              -- enable castbar latency
	["cbicons"] = false,                                 -- enable icons on castbar (not finished)
	["auratimer"] = true,                               -- enable timers on buffs/debuffs
	["auratextscale"] = 11,                             -- the font size of buffs/debuffs timers on unitframes
	["playerauras"] = false,                            -- enable auras
	["targetauras"] = true,                             -- enable auras on target unit frame
	["lowThreshold"] = 20,                              -- global low threshold, for low mana warning.
	["targetpowerpvponly"] = false,                      -- enable power text on pvp target only
	["totdebuffs"] = false,                             -- enable tot debuffs (high reso only)
	["showtotalhpmp"] = false,                          -- change the display of info text on player and target with XXXX/Total.
	["showsmooth"] = true,                              -- enable smooth bar
	["charportrait"] = false,                           -- do i really need to explain this?
	["maintank"] = false,                               -- enable maintank (not done)
	["mainassist"] = false,                             -- enable mainassist (not done)
	["unicolor"] = true,                               -- enable unicolor theme
	["combatfeedback"] = true,                          -- enable combattext on player and target.
	["playeraggro"] = true,                             -- color player border to red if you have aggro on current target.
	["healcomm"] = true,                               -- enable healprediction support.
	["onlyselfdebuffs"] = true,                        -- display only our own debuffs applied on target
	["showfocustarget"] = false,                         -- show focus target (not done)
	["bordercolor"] = { .4,.4,.4 },                     -- unit frames panel border color
	
	["unitframesize"] = {								-- adjust the size of the unitframes (width, height)
		["player_target"] = {225, 30},
		["targetoftarget"] = {130, 22},
		["pet"] = {130, 22},
		["focus"] = {150, 30},
		["boss"] = {200, 30},
	},

	-- raid layout (if one of them is enabled)
	["showrange"] = true,                               -- show range opacity on raidframes
	["raidalphaoor"] = 0.3,                             -- alpha of unitframes when unit is out of range
	-- keep true
	["gridonly"] = true,                               -- enable grid only mode for all healer mode raid layout.
	["showsymbols"] = true,	                            -- show symbol.
	["aggro"] = true,                                   -- show aggro on all raids layouts
	["raidunitdebuffwatch"] = true,                     -- track important spell to watch in pve for grid mode.
	["gridhealthvertical"] = false,                      -- enable vertical grow on health bar for grid mode.
	["showplayerinparty"] = true,                      -- show my player frame in party
	["gridscale"] = 1,                                  -- set the healing grid scaling
	["gradienthealth"] = true,                          -- change raid health color based on health percent.
	["gradient"] = {                                    -- health gradient color if unicolor is true.
		1.0, 0.3, 0.3, -- R, G, B (low HP)
		0.6, 0.3, 0.3, -- R, G, B (medium HP)
		.2, .2, .2,  -- R, G, B (high HP)
	},
	
	-- boss frames
	["showboss"] = true,                                -- enable boss unit frames for PVELOL encounters.

	-- priest only plugin
	["weakenedsoulbar"] = true,                         -- show weakened soul bar
	
	-- class bar
	["classbar"] = true,                                -- enable tukui classbar over player unit
}

C["castbar"] = {
	["bigcastbar"] = true,                              -- enable bigger more visible castbar (reccomended for casters)
	["classcolor"] = true,                              -- color castbars based on class
	["color"] = { .2,.2,.2,1 },                         -- color if classcolor = false
	["nointerrupt"] = { 1,.2,.2,1 },                    -- color of casts which can't be interrupted

	["player"] = {                                      -- player specific castbar options
		["width"] = 250,                                -- width
		["height"] = 20,                                -- height
		["anchor"] = { "CENTER", UIParent, 0, -110 },   -- position
	},
	["target"] = {										-- target specific castbar options
		["width"] = 220,                                -- width
		["height"] = 20,                                -- height
		["anchor"] = { "CENTER", UIParent, 0, -82 },   -- position
	},
	
	["ticks"] = {                                       -- Castbar channeling ticks         
		[GetSpellInfo(1120)] = 5,                       -- drain soul
		[GetSpellInfo(689)] = 5,                        -- drain life
		[GetSpellInfo(5740)] = 4,                       -- rain of fire
		[GetSpellInfo(740)] = 4,                        -- Tranquility
		[GetSpellInfo(16914)] = 10,                     -- Hurricane
		[GetSpellInfo(15407)] = 3,                      -- mind flay
		[GetSpellInfo(48045)] = 5,                      -- mind sear
		[GetSpellInfo(47540)] = 2,                      -- penance
		[GetSpellInfo(5143)] = 5,                       -- arcane missiles
		[GetSpellInfo(10)] = 5,                         -- blizzard
		[GetSpellInfo(12051)] = 4,                      -- evocation
	},
}

C["arena"] = {
	["unitframes"] = true,                              -- enable tukz arena unitframes (requirement : tukui unitframes enabled)
}

C["auras"] = {
	["player"] = true,                                  -- enable tukui buffs/debuffs
}

C["actionbar"] = {
	["enable"] = true,                                  -- enable tukui action bars
	["hotkey"] = false,                                 -- enable hotkey display because it was a lot requested
	["hideshapeshift"] = false,                         -- hide shapeshift or totembar because it was a lot requested.
	["showgrid"] = true,                                -- show grid on empty button
	["buttonsize"] = 25,                                -- normal buttons size
	["petbuttonsize"] = 25,                             -- pet & stance buttons size
	["buttonspacing"] = 4,                              -- buttons spacing
}

C["bags"] = {
	["enable"] = true,                                  -- enable an all in one bag mod that fit tukui perfectly
}

C["loot"] = {
	["lootframe"] = true,                               -- reskin the loot frame to fit tukui
	["rolllootframe"] = true,                           -- reskin the roll frame to fit tukui
	["autogreed"] = true,                               -- auto-dez or auto-greed item at max level, auto-greed Frozen orb
}

C["cooldown"] = {
	["enable"] = true,                                  -- do i really need to explain this?
	["treshold"] = 8,                                   -- show decimal under X seconds and text turn red
}

C["datatext"] = {
	["fps_ms"] = 4,                                     -- show fps and ms on panels
	["system"] = 5,                                     -- show total memory and others systems infos on panels
	["bags"] = 0,                                       -- show space used in bags on panels
	["gold"] = 6,                                       -- show your current gold on panels
	["wowtime"] = 2,                                    -- show time on panels
	["guild"] = 1,                                      -- show number on guildmate connected on panels
	["dur"] = 0,                                        -- show your equipment durability on panels.
	["friends"] = 3,                                    -- show number of friends connected.
	["dps_text"] = 0,                                   -- show a dps meter on panels
	["hps_text"] = 0,                                   -- show a heal meter on panels
	["power"] = 0,                                      -- show your attackpower/spellpower/healpower/rangedattackpower whatever stat is higher gets displayed
	["haste"] = 0,                                      -- show your haste rating on panels.
	["crit"] = 0,                                       -- show your crit rating on panels.
	["avd"] = 0,                                        -- show your current avoidance against the level of the mob your targeting
	["armor"] = 0,                                      -- show your armor value against the level mob you are currently targeting
	["currency"] = 0,                                   -- show your tracked currency on panels
	["hit"] = 0,                                        -- show hit rating
	["mastery"] = 0,                                    -- show mastery rating
	["micromenu"] = 0,                                  -- add a micro menu thought datatext
	["regen"] = 0,                                      -- show mana regeneration

	["battleground"] = false,                            -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["time24"] = false,                                  -- set time to 24h format.
	["localtime"] = true,                              -- set time to local time instead of server time.
	["fontsize"] = 12,                                  -- font size for panels.
}

C["chat"] = {
	["enable"] = true,                                  -- blah
	["whispersound"] = true,                            -- play a sound when receiving whisper
	["background"] = false,								-- keep false
}

C["nameplate"] = {
	["enable"] = true,                                  -- enable nice skinned nameplates that fit into tukui
	["showhealth"] = false,				                -- show health text on nameplate
	["enhancethreat"] = false,			                -- threat features based on if your a tank or not
	["combat"] = false,					                -- only show enemy nameplates in-combat.
	["goodcolor"] = {75/255,  175/255, 76/255},	        -- good threat color (tank shows this with threat, everyone else without)
	["badcolor"] = {0.78, 0.25, 0.25},			        -- bad threat color (opposite of above)
	["transitioncolor"] = {218/255, 197/255, 92/255},	-- threat color when gaining threat
}

C["tooltip"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	["hidecombat"] = false,                             -- hide bottom-right tooltip when in combat
	["hidebuttons"] = false,                            -- always hide action bar buttons tooltip.
	["hideuf"] = false,                                 -- hide tooltip on unitframes
	["cursor"] = false,                                 -- tooltip via cursor only
}

C["merchant"] = {
	["sellgrays"] = true,                               -- automaticly sell grays?
	["autorepair"] = true,                              -- automaticly repair?
	["sellmisc"] = true,                                -- sell defined items automatically
}

C["error"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	filter = {                                          -- what messages to not hide
		[INVENTORY_FULL] = true,                        -- inventory is full will not be hidden by default
	},
}

C["invite"] = { 
	["autoaccept"] = true,                              -- auto-accept invite from guildmate and friends.
}

C["buffreminder"] = {
	["enable"] = true,                                  -- this is now the new innerfire warning script for all armor/aspect class.
	["sound"] = true,                                   -- enable warning sound notification for reminder.
}

C["skin"] = {
	["skada"] = false,
	["omen"] = false,
	["embed"] = {										-- WIP still keep both embedded for now.
		skada = true,
		omen = true,
	},
}
