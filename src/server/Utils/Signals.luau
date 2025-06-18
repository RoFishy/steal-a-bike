-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)

return {
	BypassLockCooldown = Signal.new(),
	AddBikeToPlayer = Signal.new(),
	RemoveBikeFromPlayer = Signal.new(),
	IncrementCash = Signal.new(),

	PlayerCollectedCash = Signal.new(),

	-- // luck
	ResetServerLuck = Signal.new(),
	IncreaseServerLuck = Signal.new(),

	-- // bikes
	RobuxBuyBike = Signal.new(),
	DoubleOfflineCash = Signal.new(),
}
