-- // services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Util
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)
local Bike = require(Utils.Bike)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local RewardRemote = Remotes.ClaimFreePet

-- // local func
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

-- // Init
local RewardHandler = {}

function RewardHandler:Start()
	RewardRemote.OnServerEvent:Connect(function(Player: Player)
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData.ClaimedFreePet then
			return Remotes.ShowNotification:FireClient(Player, "You have already claimed a free bike!")
		end
		local PlayerBase = GetPlayerBase(Player)
		local OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
		if not OpenSlot then
			return Remotes.ShowNotification:FireClient(Player, "Your base is full!")
		end
		if not Player:IsInGroup(34847223) then
			return Remotes.ShowNotification:FireClient(Player, "You have not completed all of the requirements!")
		end
		DataUtil:SetFreePetClaimed(Player)
		local _bike = Bike.new("Floppa", "Epic", CFrame.new(0, 0, 0))
		_bike.Model:SetAttribute("ID", game:GetService("HttpService"):GenerateGUID(false))
		_bike.PurchasePlayer = Player
		_bike.CurrentStand = OpenSlot
		task.cancel(_bike.CurrentMove)
		_bike:AddToSlot(OpenSlot)
		return Remotes.ShowNotification:FireClient(Player, "You have claimed a free Floppa!")
	end)
end

return RewardHandler
