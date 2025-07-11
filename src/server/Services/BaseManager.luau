-- // Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Products = require(Modules.Products)
local Rebirths = require(Modules.Rebirths)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local SetupBaseDisplay = Remotes.SetupBaseDisplay
local ShowNotification = Remotes.ShowNotification
local ToggleCollision = Remotes.ToggleCollision

-- // Utils
local Utils = script.Parent.Parent.Utils
local Signals = require(Utils.Signals)

-- // Objects
local BasesFolder = workspace.Bases
local Floor = workspace.Floor

-- // Constants
--local LOCK_COOLDOWN = 30
local BYPASS_COOLDOWN_PRODUCT = Products.BypassLockCooldown.ProductId

-- // Constants
local NUMBER_SUFFIX = { "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "d", "U", "D" }

-- // Local Functions
local function FormatNumber(n)
	if not tonumber(n) then
		return n
	end
	if n < 1000 then
		return math.floor(n)
	end
	local d = math.floor(math.log10(n) / 3) * 3
	local s = tostring(n / (10 ^ d)):sub(1, 5)
	return s .. tostring(NUMBER_SUFFIX[math.floor(d / 3)])
end

function Format(Int)
	return string.format("%02i", Int)
end

function convertToMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Minutes) .. ":" .. Format(Seconds)
end

-- // Module
local BaseManager = {}

function BaseManager.Init()
	BaseManager.Junk = {}
	-- // bike init
	PhysicsService:RegisterCollisionGroup("Bike")
	PhysicsService:CollisionGroupSetCollidable("Bike", "Bike", false)
	PhysicsService:RegisterCollisionGroup("Floor")
	PhysicsService:CollisionGroupSetCollidable("Bike", "Default", false)
	PhysicsService:CollisionGroupSetCollidable("Bike", "Floor", true)
	Floor.CollisionGroup = "Floor"

	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:CollisionGroupSetCollidable("Bike", "Player", false)

	-- // Init bases
	BaseManager.Bases = {}
	BaseManager.PlayersTryingToUnlock = {}
	BaseManager.WhitelistedPlayers = {}
	for _, Base in BasesFolder:GetChildren() do
		BaseManager.Bases[Base.Name] = {
			Owner = nil,
			Locked = false,
			CooldownThread = nil,
			ValueConnection = nil,
		}
		BaseManager.PlayersTryingToUnlock[Base.Name] = {}
		BaseManager:ResetBase(Base.Name)

		-- // physics stuff
		for _, Slot: BasePart in Base.Slots:GetDescendants() do
			if Slot:IsA("BasePart") then
				Slot.CollisionGroup = "Floor"
			end
		end
	end
end

function BaseManager:Start()
	Signals.BypassLockCooldown:Connect(function(Player: Player)
		local BaseData = self.Bases[self:GetBaseNameFromPlayer(Player)]
		if BaseData.CooldownThread then
			task.cancel(BaseData.CooldownThread)
			self:LockBase(self:GetBaseNameFromPlayer(Player))
		end
	end)

	for _, Base in BasesFolder:GetChildren() do
		local Components = Base.Components
		local LockButton: Part = Components.LockButton
		local RobuxLockButton: Part = Components.LockButtonRBX
		--local CollectArea: Model = Components.CollectZone.CollectPart
		local CollisionPart: BasePart = Components.CollectZone.CollisionPart

		CollisionPart.Touched:Connect(function(hit: Part)
			local Player = Players:GetPlayerFromCharacter(hit.Parent)
			if Player then
				if self.Bases[Base.Name].Locked == false then
					return
				end
				if not table.find(self.WhitelistedPlayers[Base.Name], Player) then
					--Player:Kick("Anticheat - Attempted to noclip into wrong base.")
					print(Player.Name .. " tried to noclip into wrong base!")
				end
			end
		end)

		LockButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			local DataUtil = require(script.Parent.Parent.Utils.DataUtil)
			if Player then
				local LockTime = DataUtil:GetData(Player).LockTime
				local BaseData = self.Bases[Base.Name]
				if BaseData.Owner and BaseData.Owner == Player then
					if BaseData.Locked == true then
						return
					end
					if LockButton.Attachment.Billboard.Frame.TextUpper.Text ~= "Lock Base" then -- its o n cooldown
						return MarketplaceService:PromptProductPurchase(Player, BYPASS_COOLDOWN_PRODUCT)
					end
					self:LockBase(Base.Name)
					ShowNotification:FireClient(
						Player,
						`You have locked your base for {LockTime} seconds!`,
						Color3.fromRGB(0, 255, 0)
					)
				end
			end
		end)

		RobuxLockButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			if Player then
				local BaseData = self.Bases[Base.Name]
				if BaseData.Owner and BaseData.Owner == Player then
					if BaseData.Locked == true then
						return
					end
					MarketplaceService:PromptProductPurchase(Player, Products["Lock Base 15 Minutes"].ProductId)
				end
			end
		end)
	end
end

function BaseManager:RemoteLock(Player: Player)
	local Base = BasesFolder[self:GetBaseNameFromPlayer(Player)]
	local Components = Base.Components
	local LockButton: Part = Components.LockButton
	local DataUtil = require(script.Parent.Parent.Utils.DataUtil)

	local LockTime = DataUtil:GetData(Player).LockTime
	local BaseData = self.Bases[Base.Name]
	if BaseData.Owner and BaseData.Owner == Player then
		if BaseData.Locked then
			return
		end
		if LockButton.Attachment.Billboard.Frame.TextUpper.Text ~= "Lock Base" then -- its o n cooldown
			return MarketplaceService:PromptProductPurchase(Player, BYPASS_COOLDOWN_PRODUCT)
		end
		self:LockBase(Base.Name)
		ShowNotification:FireClient(
			Player,
			`You have locked your base for {LockTime} seconds!`,
			Color3.fromRGB(0, 255, 0)
		)
	end
end

function BaseManager:GetBaseNameFromPlayer(Player: Player): string?
	for Name, Base in self.Bases do
		if Base.Owner == Player then
			return Name
		end
	end
	return nil
end

function BaseManager:LockBase(Base: string, Time: number?)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = true

	local DataUtil = require(script.Parent.Parent.Utils.DataUtil)
	local PlayerData = DataUtil:GetData(self.Bases[Base.Name].Owner)
	local LockTime = PlayerData.LockTime

	local Components = Base.Components
	local Locks = Components.Lock
	local CollectArea: Model = Components.CollectZone.CollectPart

	for _, Part in CollectArea:GetChildren() do
		if CollectArea.PrimaryPart == Part then
			continue
		end
		local parts = workspace:GetPartsInPart(Part)
		if parts then
			for _, hit in parts do
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					table.insert(self.WhitelistedPlayers[Base.Name], player)
				end
			end
		end
	end

	local _LockTime = Time or LockTime

	self.Bases[Base.Name].LockThread = task.spawn(function()
		for i = _LockTime, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Locked for: {convertToMS(i)}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Locked for: {convertToMS(i)}`
			task.wait(1)
		end
		self:UnlockBase(Base.Name)
		self.Bases[Base.Name].LockThread = nil
	end)

	Locks.Wall.CanCollide = true

	local Attachment = Instance.new("Attachment")
	Attachment.Parent = Locks.Wall
	Attachment.CFrame = Attachment.CFrame * CFrame.new(0, -5, 0)

	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.Parent = Attachment
	ProximityPrompt.ActionText = "Unlock Base"
	ProximityPrompt.ObjectText = "R$39"

	Remotes.TogglePrompt:FireClient(self.Bases[Base.Name].Owner, ProximityPrompt, false)

	ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered ~= self.Bases[Base.Name].Owner then
			for _Base, _Players in self.PlayersTryingToUnlock do
				if table.find(_Players, playerWhoTriggered) then
					table.remove(
						self.PlayersTryingToUnlock[_Base],
						table.find(self.PlayersTryingToUnlock[_Base], playerWhoTriggered)
					)
				end
			end
			table.insert(self.PlayersTryingToUnlock[Base.Name], playerWhoTriggered)
			MarketplaceService:PromptProductPurchase(playerWhoTriggered, Products["Unlock Base"].ProductId)
		end
	end)

	ToggleCollision:FireAllClients(Locks.Wall, true)
	ToggleCollision:FireClient(self.Bases[Base.Name].Owner, Locks.Wall, false)

	for _, Lock in Locks:GetDescendants() do
		if Lock:IsA("BasePart") then
			if Lock.Name == "Wall" then
				continue
			end
			Lock.Transparency = 0
		end
	end
end

function BaseManager:UnlockForPlayer(Player: Player)
	for _Base, _Players in self.PlayersTryingToUnlock do
		if table.find(_Players, Player) then
			table.remove(self.PlayersTryingToUnlock[_Base], table.find(self.PlayersTryingToUnlock[_Base], Player))

			if not self.WhitelistedPlayers[_Base] then
				self.WhitelistedPlayers[_Base] = {}
			end

			table.insert(self.WhitelistedPlayers[_Base], Player)

			local Base = BasesFolder:FindFirstChild(_Base)
			local Components = Base.Components
			local Locks = Components.Lock

			ToggleCollision:FireClient(Player, Locks.Wall, false)

			ShowNotification:FireClient(
				Player,
				`You have unlocked {Base:GetAttribute("Owner")}'s base! Go inside and have fun!`,
				Color3.fromRGB(0, 255, 0)
			)
			ShowNotification:FireClient(
				Players:FindFirstChild(Base:GetAttribute("Owner")),
				`Your base has been unlocked by {Player.Name}! Be careful!`,
				Color3.fromRGB(255, 0, 0)
			)
		end
	end
end

function BaseManager:UnlockBase(Base: string)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = false

	if self.WhitelistedPlayers[Base] then
		for _, Player in self.WhitelistedPlayers[Base] do
			if Player == self.Bases[Base].Owner then
				continue
			end
			table.remove(self.WhitelistedPlayers[Base], table.find(self.WhitelistedPlayers[Base], Player))
		end
	end

	local Components = Base.Components
	local Locks = Components.Lock
	--[[
		self.Bases[Base.Name].CooldownThread = task.spawn(function()
		for i = LOCK_COOLDOWN, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Cooldown: {i}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Cooldown: {i}`
			task.wait(1)
		end
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = "Lock Base"
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = "Lock Base"
	end)
	]]
	--
	Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = "Lock Base"
	Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = "Lock Base"
	Locks.Wall.CanCollide = false

	local attachment = Locks.Wall:FindFirstChildOfClass("Attachment")
	if attachment then
		attachment:Destroy()
	end
	for _, Lock in Locks:GetDescendants() do
		if Lock:IsA("BasePart") then
			if Lock.Name == "Wall" then
				continue
			end
			Lock.Transparency = 1
		end
	end
end

function BaseManager:GetEmptyBaseName(): string
	for Name, Base in self.Bases do
		if Base.Owner == nil then
			return Name
		end
	end
	return nil
end

function BaseManager:AssignBase(Player: Player, Base: string)
	self.Junk[Player] = {}
	if self:GetBaseNameFromPlayer(Player) then
		return
	end

	local BaseName = Base or self:GetEmptyBaseName()
	assert(BaseName, "No available bases! (Server size limit too high?)")

	if not self.WhitelistedPlayers[BaseName] then
		self.WhitelistedPlayers[BaseName] = {}
	end

	table.insert(self.WhitelistedPlayers[BaseName], Player)

	self.Bases[BaseName].Owner = Player

	local BaseModel = BasesFolder[BaseName]
	BaseModel:SetAttribute("Owner", Player.Name)

	local Components = BaseModel.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui
	local ValueGui = Sign.Main.Value.SurfaceGui
	local CashMultiText = Components.CashMulti.Attachment.Billboard.Frame.TextLow

	local leaderstats = Player:WaitForChild("leaderstats")
	local PlayerRebirths = leaderstats.Rebirths

	local Multiplier = Rebirths[PlayerRebirths.Value] and Rebirths[PlayerRebirths.Value].Rewards.Multiplier or 1
	CashMultiText.Text = `Cash Multiplier: {Multiplier}x`

	PlayerRebirths:GetPropertyChangedSignal("Value"):Connect(function()
		Multiplier = Rebirths[PlayerRebirths.Value].Rewards.Multiplier or 1
		CashMultiText.Text = `Cash Multiplier: {Multiplier}x`
	end)

	if Player:FindFirstChild("TotalValue") then
		ValueGui.name.Text = `TOTAL VALUE: ${FormatNumber(Player.TotalValue.Value)}`
		self.Bases[BaseName].ValueConnection = Player.TotalValue:GetPropertyChangedSignal("Value"):Connect(function()
			ValueGui.name.Text = `TOTAL VALUE: ${FormatNumber(Player.TotalValue.Value)}`
		end)
	else
		ValueGui.name.Text = `TOTAL VALUE: $0`
		Player.ChildAdded:Connect(function(child)
			if child.Name == "TotalValue" then
				ValueGui.name.Text = `TOTAL VALUE: ${FormatNumber(Player.TotalValue.Value)}`
				self.Bases[BaseName].ValueConnection = Player.TotalValue
					:GetPropertyChangedSignal("Value")
					:Connect(function()
						ValueGui.name.Text = `TOTAL VALUE: ${FormatNumber(Player.TotalValue.Value)}`
					end)
			end
		end)
	end

	SignGui:FindFirstChildOfClass("TextLabel").Text = `{Player.Name}'s Dealership`
	self:TeleportPlayerToBase(Player, BaseName)

	-- // Physics
	local Character = Player.Character or Player.CharacterAdded:Wait()
	for _, Item: BasePart in Character:GetDescendants() do
		if Item:IsA("BasePart") then
			Item.CollisionGroup = "Player"
		end
	end

	SetupBaseDisplay:FireClient(Player, BaseName)
end

function BaseManager:TeleportPlayerToBase(Player: Player, Base: string?)
	Base = Base or self:GetBaseNameFromPlayer(Player)
	Base = BasesFolder[Base]

	local Components = Base.Components
	local SpawnPart = Components.SpawnPart

	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character:PivotTo(SpawnPart.CFrame)
end

function BaseManager:ResetBase(Base: string)
	if self.Bases[Base].LockThread then
		task.cancel(self.Bases[Base].LockThread)
	end

	if BaseManager.Bases[Base].Locked then
		self:UnlockBase(Base)
	end
	local DataUtil = require(Utils.DataUtil)

	local CurrentBikes = DataUtil:GetCurrentBikes(self.Bases[Base].Owner)

	if self.Bases[Base].Owner then
		for _, obj in self.Junk[self.Bases[Base].Owner] do
			obj:Disconnect()
		end
	end

	self.Bases[Base].Owner = nil
	Base = BasesFolder[Base]
	Base:SetAttribute("Owner", nil)
	local Components = Base.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui
	local ValueGui = Sign.Main.Value.SurfaceGui
	local CashMultiText = Components.CashMulti.Attachment.Billboard.Frame.TextLow

	CashMultiText.Text = "Cash Multiplier: 1x"

	ValueGui.name.Text = "TOTAL VALUE: N/A"
	if self.Bases[Base.Name].ValueConnection then
		self.Bases[Base.Name].ValueConnection:Disconnect()
		self.Bases[Base.Name].ValueConnection = nil
	end

	for _, Slot in Base.Slots:GetChildren() do
		local collectAt = Slot.Collect.Attachment
		local offlineAt = Slot.Collect.OfflineAttachment
		offlineAt.Billboard.Frame.Visible = false
		collectAt.Billboard.Frame.amount.Text = "$0"
	end

	SignGui:FindFirstChildOfClass("TextLabel").Text = `Unclaimed Dealership`
	if not CurrentBikes then
		return
	end
	for ID, Bike in CurrentBikes do
		local Name = Bike.Name
		local Stand = Bike.Stand
		Base.Slots[Stand]:SetAttribute("Bike", nil)
		for _, _Bike in workspace:GetDescendants() do
			if _Bike.Name == Name then
				if _Bike:GetAttribute("ID") == ID then
					task.spawn(function()
						pcall(function()
							_Bike:Destroy()
						end)
					end)
				end
			end
		end
	end
end

return BaseManager
