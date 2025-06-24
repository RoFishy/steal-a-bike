-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamepassItems = ReplicatedStorage.GamepassItems
local Tools = ReplicatedStorage.Tools

local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

return {
	["Cloud"] = {
		Id = 1274287132,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Flying Cloud"]:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	["Sledgehammer"] = {
		Id = 1274426978,
		Callback = function(Player: Player)
			local Tool = GamepassItems.Sledgehammer:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	["Admin"] = {
		Id = 1274180916,
		Callback = function(Player: Player)
			local hdMain = require(game:GetService("ReplicatedStorage"):WaitForChild("HDAdminSetup")):GetMain()
			local hd = hdMain:GetModule("API")
			local plrRankId = hd:GetRank(Player)
			local rank = "VIP"
			local rankType = "Server"
			local rankId = tonumber(rank) or hd:GetRankId(rank)
			if plrRankId > rankId then
				return
			end
			hd:SetRank(Player, rankId, rankType)
		end,
	},
	["Galaxy Bat"] = {
		Id = 1273599049,
		Callback = function(Player: Player)
			local bat = GamepassItems["Galaxy Bat"]:Clone()
			bat.Parent = Player.Backpack
		end,
	},
	["Remote Lock"] = {
		Id = 1274574728,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Remote Lock"]:Clone()
			Tool.Parent = Player.Backpack
		end,
	},
	["VIP"] = {
		Id = 1274562729,
		Callback = function(Player: Player)
			Player:SetAttribute("VIP", true)
			Player.Character.Humanoid.WalkSpeed *= 1.25
		end,
	},
	["Laser Gun"] = {
		Id = 1273913204,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Laser Gun"]:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	["x2 Cash"] = {
		Id = 1273885277,
		Callback = function(Player: Player)
			Player:SetAttribute("2xCash", true)
		end,
	},
	["x2 Speed"] = {
		Id = 1274416964,
		Callback = function(Player: Player)
			Player.Character.Humanoid.WalkSpeed *= 2
		end,
	},
	["Starter Pack"] = {
		Id = 1274275109,
		Callback = function(Player: Player)
			local Bike = require(game:GetService("ServerScriptService").Utils.Bike)
			local dataUtil = require(game:GetService("ServerScriptService").Utils.DataUtil)
			dataUtil:IncrementCash(Player, 2_500)

			local tool = Tools["Speed Coil"]:Clone()
			tool.Parent = Player.Backpack

			local bat = GamepassItems["Galaxy Bat"]:Clone()
			bat.Parent = Player.Backpack

			local PlayerBase = GetPlayerBase(Player)
			local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				return
			end
			local data = dataUtil:GetData(Player)
			if data.ClaimedVIPPet ~= true then
				local _bike = Bike.new("John Pork", "Legendary", CFrame.new(0, 0, 0))
				_bike.Model:SetAttribute("ID", game:GetService("HttpService"):GenerateGUID(false))
				_bike.PurchasePlayer = Player
				_bike.CurrentStand = OpenSlot
				task.cancel(_bike.CurrentMove)
				_bike:AddToSlot(OpenSlot)
				dataUtil:SetVIPPetClaimed(Player)
			end
		end,
	},
}
