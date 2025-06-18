-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- // shared modules
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

-- // Modules
local DataTemplate = require(script.Template)
local ProfileStore = require(script.ProfileStore)

-- // Packages
local Packages = ReplicatedStorage.Packages
local Replica = require(Packages.Replica)

-- // Ordered DS
local StealsOrderedDS = DataStoreService:GetOrderedDataStore("OrderedSteals")
local CashOrderedDS = DataStoreService:GetOrderedDataStore("OrderedCash")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes

-- // Utils
local Utils = script.Parent
local Bike = require(Utils.Bike)
local Signals = require(Utils.Signals)

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Const
local DATA_TOKEN = Replica.Token("PlayerData")
local MAX_OFFLINE_EARNINGS_TIME = 10800

-- // Var
local Profiles = {} :: { [Player]: typeof(ProfileStore:StartSessionAsync()) }
local BikeReferences = {}
local PlayersPurchasingBikes = {}
local Replicas = {}

-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end
local function GetDictionaryLength(Dictionary: {})
	local i = 0
	for _, _ in Dictionary do
		i += 1
	end
	return i
end

-- // Module
local DataUtil = {}

function DataUtil.new(Player: Player)
	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})
	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()

		Profile.OnSessionEnd:Connect(function()
			Profiles[Player] = nil
			Player:Kick("Profile session end - Please Rejoin")
		end)

		if Player.Parent == Players then
			Profiles[Player] = Profile
			if GetDictionaryLength(Profile.Data.Index) > 3 and GetDictionaryLength(Profile.Data.Index.Normal) == 0 then
				local normalTable = {}
				for index, value in Profile.Data.Index do
					if typeof(index) == "string" then
						continue
					end
					normalTable[index] = value
				end
				Profile.Data.Index = {}
				Profile.Data.Index["Normal"] = normalTable
				Profile.Data.Index.Golden = {}
				Profile.Data.Index.Diamond = {}
			end
			if Profile.Data.Cash > 1_000_000_000_000 then
				Profile.Data.Cash = 500
			end
			if Profile.Data.Steals > 10_000 then
				Profile.Data.Steals = 0
			end
			DataUtil:_SetupLeaderstats(Player)
			DataUtil:LoadBikes(Player)
		else
			Profile:EndSession()
		end
	else
		Player:Kick(`Profile load fail - Please Rejoin`)
	end
end

function DataUtil:SetupReplica(Player: Player)
	local Profile = Profiles[Player]
	if Player:IsDescendantOf(Players) and not Profile then
		repeat
			task.wait()
		until Profiles[Player]
		Profile = Profiles[Player]
	end
	local _replica = Replica.New({
		Token = DATA_TOKEN,
		Data = Profile.Data,
	})
	Replicas[Player] = _replica
	_replica:Subscribe(Player)
	_replica:Set({ "Index" }, Profile.Data.Index)
end

function DataUtil:FirstTimePlayer(Player: Player): boolean
	local Profile = Profiles[Player]
	if Profile then
		return Profile.Data.NewPlayer == true
	end
end

function DataUtil:_SetupLeaderstats(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats

	local Steals = Instance.new("IntValue")
	Steals.Name = "Steals"
	Steals.Parent = leaderstats

	local Rebirths = Instance.new("IntValue")
	Rebirths.Name = "Rebirths"
	Rebirths.Parent = leaderstats

	local Profile = Profiles[Player]
	if Profile then
		Cash.Value = Profile.Data.Cash
		Steals.Value = Profile.Data.Steals
		Rebirths.Value = Profile.Data.Rebirths
	end
end

function DataUtil:IsProfileLoaded(Player: Player)
	if Profiles[Player] then
		return true
	end
	return false
end

function DataUtil:IncrementCash(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Cash += Amount
		Player.leaderstats.Cash.Value = Profile.Data.Cash
	end
end

function DataUtil:IncrementSteals(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Steals += Amount
		Player.leaderstats.Steals.Value = Profile.Data.Steals
	end
end

function DataUtil:IncrementRebirths(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Rebirths += Amount
		Player.leaderstats.Rebirths.Value = Profile.Data.Rebirths
	end
end

function DataUtil:SetFreePetClaimed(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.ClaimedFreePet = true
	end
end

function DataUtil:SetVIPPetClaimed(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.ClaimedVIPPet = true
	end
end

function DataUtil:IncrementLockTime(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.LockTime += Amount
	end
end

function DataUtil:GetPlayersPurchasingBikes()
	return PlayersPurchasingBikes
end

function DataUtil:UpdatePlayersPurchasingBikes(NewTable: {})
	PlayersPurchasingBikes = NewTable
end

function DataUtil:AddBikeToPlayer(Player: Player, BikeObj)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Slots[BikeObj.Model:GetAttribute("ID")] = {
			Name = BikeObj.Name,
			--Info = BikeObj.Info,
			Rarity = BikeObj.Rarity,
			Stand = BikeObj.CurrentStand.Name,
			Special = BikeObj.Special,

			-- // cleanup on game end:
			--Model = BikeObj.Model,
		}
		BikeReferences[BikeObj.Model:GetAttribute("ID")] = BikeObj.Model

		local Table = Profile.Data.Index.Normal
		if BikeObj.Special then
			Table = Profile.Data.Index[BikeObj.Special]
		end
		if not table.find(Table, BikeObj.Name) then
			local _replica = Replicas[Player]
			table.insert(Table, BikeObj.Name)
			_replica:Set({ "Index" }, Profile.Data.Index)
			local Text = "You have discovered the " .. BikeObj.Name .. " Bike! It has been added to your Index."
			if BikeObj.Special then
				Text =
					`You have discovered the {string.upper(Bike.Special)} {BikeObj.Name}! It has been added to your {BikeObj.Special} Index.`
			end
			Remotes.ShowNotification:FireClient(Player, Text, Color3.fromRGB(0, 217, 255))
		end
	end
end

function DataUtil:LoadBikes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		local PlayerBase = GetPlayerBase(Player)

		local Slots = Profile.Data.Slots
		local CurrentOfflineCash = 0
		for ID, Slot in Slots do
			local OpenSlot = PlayerBase.Slots:FindFirstChild(Slot.Stand) or Bike:GetOpenSlot(PlayerBase.Slots)
			if OpenSlot and OpenSlot:GetAttribute("Bike") then
				OpenSlot = Bike:GetOpenSlot(PlayerBase.Slots)
			end
			if not OpenSlot then
				continue
			end
			OpenSlot:SetAttribute("Bike", Slot.Name)
			print(Slot.Special)
			local _bike = Bike.new(Slot.Name, Slot.Rarity, CFrame.new(0, 0, 0), Slot.Special, true)
			BikeReferences[ID] = _bike.Model
			_bike.Model:SetAttribute("ID", ID)
			_bike.PurchasePlayer = Player
			_bike.CurrentStand = OpenSlot
			--Profile.Data.Slots[ID].Model = _bike.Model
			task.cancel(_bike.CurrentMove)
			local offlineEarnings = self:CalculateOfflineEarnings(Player, _bike)
			CurrentOfflineCash += offlineEarnings
			_bike:AddToSlot(OpenSlot, true, offlineEarnings)

			Signals.DoubleOfflineCash:Connect(function(_Player: Player)
				if Player == _Player then
					_bike:SetOfflineCash(offlineEarnings, offlineEarnings * 2)
				end
			end)
		end
		task.delay(3, function()
			if CurrentOfflineCash > 0 then
				Remotes.DoubleCashFrame:FireClient(Player, CurrentOfflineCash)
			end
		end)
	end
end

function DataUtil:CalculateOfflineEarnings(Player: Player, BikeObj): number?
	local Profile = Profiles[Player]
	if Profile then
		local LastJoin = Profile.Data.LastJoin
		if LastJoin then
			local Time = tick() - LastJoin
			local Income = BikeObj.Info.Income
				* (Time < MAX_OFFLINE_EARNINGS_TIME and Time or MAX_OFFLINE_EARNINGS_TIME)

			return math.abs(math.ceil(Income / 2))
		end
	end
	return nil
end

function DataUtil:RemoveBikeFromPlayer(Player: Player, BikeObj, ID: string?)
	local Profile = Profiles[Player]
	if ID then
		Profile.Data.Slots[ID] = nil
	else
		if Profile and BikeObj.Model:GetAttribute("ID") then
			Profile.Data.Slots[BikeObj.Model:GetAttribute("ID")] = nil
		end
	end
end

function DataUtil:GetCurrentBikes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		return Profile.Data.Slots
	end
end

function DataUtil:GetCurrentBikeReferences()
	return BikeReferences
end

function DataUtil:GetData(Player: Player): Types.UserData
	if self:IsProfileLoaded(Player) then
		return Profiles[Player].Data
	else
		return "Profile not loaded"
	end
end

function DataUtil:CleanupProfile(Player: Player)
	if Profiles[Player] then
		for ID, Slot in Profiles[Player].Data.Slots do
			if Slot.Model then
				Profiles[Player].Data.Slots[ID].Model = nil
			end
		end
		task.spawn(function()
			local data = Profiles[Player].Data
			CashOrderedDS:SetAsync(Player.UserId, math.ceil(data.Cash))
			StealsOrderedDS:SetAsync(Player.UserId, math.ceil(data.Steals))
		end)
		Profiles[Player].Data.LastJoin = tick()
		Profiles[Player].Data.NewPlayer = false
		Profiles[Player]:EndSession()
	end
end

return DataUtil
