-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataTemplate: Types.UserData = {
	Cash = 400,
	Rebirths = 0,
	Steals = 0,
	LockTime = 60,
	Slots = {},
	LastJoin = nil,
	Index = {
		Normal = {},
		Golden = {},
		Diamond = {},
	},
	NewPlayer = true,
	ClaimedVIPPet = true,
	ClaimedFreePet = false,
}

return DataTemplate
