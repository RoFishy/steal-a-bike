-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

local function GetRandomIndexFromDictionary(dictionary)
	local indexes = {} -- table of all indexes in the dictionary
	for i, _ in pairs(dictionary) do -- insert all of the indexes into the table
		indexes[#indexes + 1] = i
	end
	return indexes[math.random(1, #indexes)]
end

-- // other
local speedConn = nil

return {
	-- // Bases
	BypassLockCooldown = {
		ProductId = 3314400072,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)
			return Signals.BypassLockCooldown:Fire(Player)
		end,
	},

	["Unlock Base"] = {
		ProductId = 3314400318,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:UnlockForPlayer(Player)
			return
		end,
	},

	["Teleport To Base"] = {
		ProductId = 3314400308,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)

			BaseManager:TeleportPlayerToBase(Player)
			return
		end,
	},

	["Lock Base 15 Minutes"] = {
		ProductId = 3314400186,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:LockBase(BaseManager:GetBaseNameFromPlayer(Player), 900)
			return
		end,
	},

	-- // Conveyor SPeed
	["10m Conveyor Speed Boost"] = {
		ProductId = 3314400341,
		Callback = function(Player: Player)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			ReplicatedStorage.SpeedTime.Value += 600
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x conveyor speed for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			if not speedConn then
				speedConn = task.spawn(function()
					while ReplicatedStorage.SpeedTime.Value > 0 do
						task.wait(1)
						ReplicatedStorage.SpeedTime.Value -= 1
					end
					task.cancel(speedConn)
					speedConn = nil
				end)
			end
			return
		end,
	},
	["Twenty Min Conveyor Speed Boost"] = {
		ProductId = 3314400354,
		Callback = function(Player: Player)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			ReplicatedStorage.SpeedTime.Value += 1200
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x conveyor speed for 20 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			if not speedConn then
				speedConn = task.spawn(function()
					while ReplicatedStorage.SpeedTime.Value > 0 do
						task.wait(1)
						ReplicatedStorage.SpeedTime.Value -= 1
					end
					task.cancel(speedConn)
					speedConn = nil
				end)
			end
			return
		end,
	},

	-- // Bikes
	["Legendary Bike"] = {
		ProductId = 3314400163,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyBike:Fire(Player)
			return
		end,
	},

	["Mythical Bike"] = {
		ProductId = 3314400270,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyBike:Fire(Player)
			return
		end,
	},

	["Celestial Bike"] = {
		ProductId = 3314400290,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyBike:Fire(Player)
			return
		end,
	},

	["SECRET??? Bike"] = {
		ProductId = 3314400302,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyBike:Fire(Player)
			return
		end,
	},

	-- // Robux-only Bikes
	["The BEAST"] = {
		ProductId = 3314400178,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local HttpService = game:GetService("HttpService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Bike = require(Utils.Bike)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end
			OpenSlot:SetAttribute("Bike", "The BEAST")
			local _bike = Bike.new("The BEAST", "ROBUX", CFrame.new(0, 0, 0))
			_bike.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_bike.PurchasePlayer = Player
			_bike.CurrentStand = OpenSlot
			task.cancel(_bike.CurrentMove)
			_bike:AddToSlot(OpenSlot)
		end,
	},

	["The BIG BOI"] = {
		ProductId = 3314400170,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Bike = require(Utils.Bike)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end
			OpenSlot:SetAttribute("Bike", "The BIG BOI")
			local _bike = Bike.new("The BIG BOI", "ROBUX", CFrame.new(0, 0, 0))
			_bike.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_bike.PurchasePlayer = Player
			_bike.CurrentStand = OpenSlot
			task.cancel(_bike.CurrentMove)
			_bike:AddToSlot(OpenSlot)
		end,
	},

	-- // Chests/crates
	["Mythical Chest"] = {
		ProductId = 3314400258,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = require(script.Parent.Spawns)
			local RandomMythical = GetRandomIndexFromDictionary(Spawns["Mythical"]["Spawns"])

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Bike = require(Utils.Bike)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has received a MYTHICAL {RandomMythical} from the mythical chest!`,
				Color3.fromRGB(255, 0, 0)
			)

			OpenSlot:SetAttribute("Bike", RandomMythical)
			local _bike = Bike.new(RandomMythical, "Mythical", CFrame.new(0, 0, 0))
			_bike.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_bike.PurchasePlayer = Player
			_bike.CurrentStand = OpenSlot
			task.cancel(_bike.CurrentMove)
			_bike:AddToSlot(OpenSlot)
		end,
	},
	["Bike Crate"] = {
		ProductId = 3314400192,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = {
				["Epic"] = {
					Rarity = 65,
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
					Rarity = 30,
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
					Rarity = 6,
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
					Rarity = 3,
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
					Rarity = 1,
					Spawns = {
						["636"] = {
							Price = 99_000_000,
							Income = 200000,
						},
					},
				},
			}

			local function GetRandomRarity(LuckMultiplier: number?)
				LuckMultiplier = LuckMultiplier or 1
				local adjustedSpawns = {}
				for name, value in pairs(Spawns) do
					adjustedSpawns[name] = {
						Rarity = value.Rarity,
						Spawns = value.Spawns,
					}

					if name == "Epic" then
						adjustedSpawns[name].Rarity = value.Rarity * math.min(LuckMultiplier, 2)
					elseif name == "Mythical" then
						adjustedSpawns[name].Rarity = value.Rarity * LuckMultiplier
					elseif name == "Celestial" or name == "SECRET???" then
						adjustedSpawns[name].Rarity = value.Rarity * (LuckMultiplier * 1.5)
					end
				end

				local adjustedSum = 0
				for _, value in pairs(adjustedSpawns) do
					adjustedSum = adjustedSum + value.Rarity
				end

				local RandomNumber = math.random(adjustedSum)
				for Name, Value in pairs(adjustedSpawns) do
					if RandomNumber <= Value.Rarity then
						return Name
					else
						RandomNumber = RandomNumber - Value.Rarity
					end
				end
			end

			local ChosenRarity = GetRandomRarity()
			local RandomSpawn = GetRandomIndexFromDictionary(Spawns[ChosenRarity].Spawns)

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Bike = require(Utils.Bike)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has received a {ChosenRarity} {RandomSpawn} from the bike crate!`,
				Color3.fromRGB(255, 0, 0)
			)

			OpenSlot:SetAttribute("Bike", RandomSpawn)
			local _bike = Bike.new(RandomSpawn, ChosenRarity, CFrame.new(0, 0, 0))
			_bike.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_bike.PurchasePlayer = Player
			_bike.CurrentStand = OpenSlot
			task.cancel(_bike.CurrentMove)
			_bike:AddToSlot(OpenSlot)
		end,
	},

	-- // Server luck
	["x2 Luck"] = {
		ProductId = 3314400360,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 2

			task.spawn(function()
				while ReplicatedStorage.LuckTime.Value > 0 do
					task.wait(1)
					ReplicatedStorage.LuckTime.Value -= 1
				end
				Signals.ResetServerLuck:Fire()
				ReplicatedStorage.CurrentLuck.Value = 1
			end)
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			return Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x4 Luck"] = {
		ProductId = 3314400373,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 4
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 4x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x8 Luck"] = {
		ProductId = 3314400383,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 8
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 8x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x16 Luck"] = {
		ProductId = 3314400329,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 16
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 16x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},

	-- // Cash
	["Double Offline Cash"] = {
		ProductId = 3314400083,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.Remotes.CloseAllFrames:FireClient(Player)
			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				"You have doubled your offline cash successfully!",
				Color3.fromRGB(0, 255, 0)
			)

			Signals.DoubleOfflineCash:Fire(Player)
		end,
	},

	["Money Pack 1"] = {
		ProductId = 3314400198,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 2_000)
		end,
	},
	["Money Pack 2"] = {
		ProductId = 3314400206,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 20_000)
		end,
	},
	["Money Pack 3"] = {
		ProductId = 3314400214,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 75_000)
		end,
	},
	["Money Pack 4 (MOST POPULAR)"] = {
		ProductId = 3314400230,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 200_000)
		end,
	},
	["Money Pack 5 (BEST DEAL)"] = {
		ProductId = 3314400248,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 1_500_000)
		end,
	},
}
