-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Remotes
--local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- // Objects

-- // Init
local PlayerHandler = {}

function PlayerHandler:Start()
	local StealAnim = nil
	LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
		local isStealing = LocalPlayer:GetAttribute("Stealing")

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not isStealing)

		if StealAnim then
			pcall(function()
				StealAnim:Stop()
				StealAnim:Destroy()
				StealAnim = nil
			end)
		end

		if isStealing and LocalPlayer.Character then
			LocalPlayer.Character.Humanoid:UnequipTools()

			local Animator: Animator = LocalPlayer.Character.Humanoid.Animator
			StealAnim = Animator:LoadAnimation(ReplicatedStorage.Objects.StealAnim)

			StealAnim:Play()
		end
	end)
	local BikeAnim = nil
	LocalPlayer:GetAttributeChangedSignal("OnBike"):Connect(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not LocalPlayer:GetAttribute("OnBike"))

		if BikeAnim then
			pcall(function()
				BikeAnim:Stop()
				BikeAnim:Destroy()
				BikeAnim = nil

				RunService:UnbindFromRenderStep("fuckass bikes")
				for _, v in LocalPlayer.Character:GetDescendants() do
					if v:IsA("BasePart") then
						v.Massless = false
					end
				end
			end)
		end

		if LocalPlayer:GetAttribute("OnBike") then
			if LocalPlayer.Character then
				LocalPlayer.Character.Humanoid:UnequipTools()

				local Animator: Animator = LocalPlayer.Character.Humanoid.Animator
				BikeAnim = Animator:LoadAnimation(ReplicatedStorage.Objects.BikeAnim)

				BikeAnim:Play()
				RunService:BindToRenderStep("fuckass bikes", Enum.RenderPriority.Character.Value + 2, function()
					for _, v in LocalPlayer.Character:GetDescendants() do
						if v:IsA("BasePart") then
							v.Massless = true
						end
					end
				end)
			end
		end
	end)
end

return PlayerHandler
