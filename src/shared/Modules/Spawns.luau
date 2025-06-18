-- // Types
local Types = require(script.Parent.Types)

return {
	["Common"] = {
		Rarity = 50, -- 50% spawn chance
		Spawns = {
			["Blue Moped"] = {
				Price = 100,
				Income = 1,
			},
			["Slowped"] = {
				Price = 200,
				Income = 2,

				Sound = 6425216149,
			},
			["Green Mini Dirtbike"] = {
				Price = 250,
				Income = 3,
			},
			["Red Mini Dirtbike"] = {
				Price = 500,
				Income = 5,
			},
			["Fastped"] = {
				Price = 750,
				Income = 7,
			},
		},
	},
	["Rare"] = {
		Rarity = 30,
		Spawns = {
			["Slow Grom"] = {
				Price = 1000,
				Income = 10,
			},
			["Quick Grom"] = {
				Price = 1500,
				Income = 15,
			},
			["Fast Grom"] = {
				Price = 2500,
				Income = 25,
			},
			["z125"] = {
				Price = 5000,
				Income = 50,
			},
		},
	},
	["Epic"] = {
		Rarity = 15,
		Spawns = {
			["Blue 450"] = {
				Price = 12500,
				Income = 125,
			},
			["Red 450"] = {
				Price = 15000,
				Income = 150,
			},
			["New Retro"] = {
				Price = 25000,
				Income = 250,
			},
			["Bzzzz Bike"] = {
				Price = 45000,
				Income = 450,
			},
		},
	},
	["Legendary"] = {
		Rarity = 2,
		Spawns = {
			["Yellow 250"] = {
				Price = 120000,
				Income = 1200,
			},
			["Stunter"] = {
				Price = 215000,
				Income = 2150,
			},
			["New Stunter"] = {
				Price = 300000,
				Income = 3000,
			},
		},
	},
	["Mythical"] = {
		Rarity = 0.5,
		Spawns = {
			["Dyna"] = {
				Price = 700000,
				Income = 5000,
			},
			["R3"] = {
				Price = 1000000,
				Income = 7500,
			},
			["Scout"] = {
				Price = 1750000,
				Income = 12500,
			},
		},
	},
	["Celestial"] = {
		Rarity = 0.25,
		Spawns = {
			["F41"] = {
				Price = 3000000,
				Income = 20000,
			},
			["Ninja 400"] = {
				Price = 5000000,
				Income = 35000,
			},
		},
	},
	["SECRET???"] = {
		Rarity = 0.05,
		Spawns = {
			["636"] = {
				Price = 99_000_000,
				Income = 200000,
			},
		},
	},
	["ROBUX"] = {
		Rarity = 0,
		Spawns = {
			["Shrek"] = {
				Price = 0,
				Income = 250_000,
			},
			["DaBaby Car"] = {
				Price = 0,
				Income = 500_000,
			},
		},
	},
} :: { [string]: Types.Spawn }
