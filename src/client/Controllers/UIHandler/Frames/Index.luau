-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Replica = require(Packages.Replica)

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local IndexFrame = MainUI:WaitForChild("Frames"):WaitForChild("Index")

local NormalHolder = IndexFrame.Normal
local GoldenHolder = IndexFrame.Gold
local DiamondHolder = IndexFrame.Diamond

local NormalButton = IndexFrame.NormalBtn
local GoldenButton = IndexFrame.GoldBtn
local DiamondButton = IndexFrame.DiamondBtn

local TopHolder = IndexFrame.Top
local CloseButton = TopHolder.close
local AmountFound = TopHolder.amountfound

-- // Vars
local PlayerBikeIndex = {}

-- // Start
local Index = {}

function Index.Init()
	Index.Junk = {}

	-- // Data
	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Index" }, function(new_value)
			PlayerBikeIndex = new_value
			Index:SetBikes()
		end)
	end)
	Replica.RequestData()
end

function Index:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			UIManager:CloseAllFrames()
		end)
	)

	table.insert(
		self.Junk,
		Button(GoldenButton, function()
			NormalHolder.Visible = false
			DiamondHolder.Visible = false
			GoldenHolder.Visible = true
		end)
	)
	table.insert(
		self.Junk,
		Button(NormalButton, function()
			NormalHolder.Visible = true
			DiamondHolder.Visible = false
			GoldenHolder.Visible = false
		end)
	)
	table.insert(
		self.Junk,
		Button(DiamondButton, function()
			NormalHolder.Visible = false
			DiamondHolder.Visible = true
			GoldenHolder.Visible = false
		end)
	)
end

function Index:SetBikes()
	local TotalCollected = 0
	for _, BikeFrame in NormalHolder:GetChildren() do
		if not BikeFrame:IsA("Frame") then
			continue
		end
		if table.find(PlayerBikeIndex.Normal, BikeFrame.Name) then
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			BikeFrame.name.Text = BikeFrame.Name
			TotalCollected += 1
		else
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
			BikeFrame.name.Text = "???"
		end
	end
	for _, BikeFrame in GoldenHolder:GetChildren() do
		if not BikeFrame:IsA("Frame") then
			continue
		end
		if table.find(PlayerBikeIndex.Golden, BikeFrame.Name) then
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			BikeFrame.name.Text = BikeFrame.Name
			TotalCollected += 1
		else
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
			BikeFrame.name.Text = "???"
		end
	end
	for _, BikeFrame in DiamondHolder:GetChildren() do
		if not BikeFrame:IsA("Frame") then
			continue
		end
		if table.find(PlayerBikeIndex.Diamond, BikeFrame.Name) then
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			BikeFrame.name.Text = BikeFrame.Name
			TotalCollected += 1
		else
			BikeFrame.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
			BikeFrame.name.Text = "???"
		end
	end
	AmountFound.Text = `{TotalCollected}/98`
end

function Index:Stop()
	for _, v in pairs(self.Junk) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "function" then
			v()
		else
			v:Destroy()
		end
	end
end

return Index
