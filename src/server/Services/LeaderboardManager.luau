-- // Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local UserService = game:GetService("UserService")

-- // Ordered DS
local StealsOrderedDS = DataStoreService:GetOrderedDataStore("OrderedSteals")
local CashOrderedDS = DataStoreService:GetOrderedDataStore("OrderedCash")

-- // const
local REFRESH_INTERVAL = 120

-- // obj
local LeaderboardsFolder = workspace.Leaderboards

-- // Constants
local NUMBER_SUFFIX = { "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "d", "U", "D" }
local RANK_COLORS = {
	[1] = Color3.fromRGB(255, 170, 0),
	[2] = Color3.fromRGB(158, 158, 158),
	[3] = Color3.fromRGB(84, 42, 0),
}

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

local function GetPlayerName(UserId: number)
	local MAX_RETRIES = 5
	local RETRY_DELAY = 0.1

	for _ = 1, MAX_RETRIES do
		local Success, Name = pcall(function()
			return Players:GetNameFromUserIdAsync(UserId)
		end)
		if Success then
			return Name
		end
		task.wait(RETRY_DELAY)
	end
	return nil
end

-- // Init
local LeaderboardManager = {}

function LeaderboardManager:Start()
	task.wait(3)

	task.spawn(function()
		self:RefreshLeaderboard("Cash")
	end)
	task.spawn(function()
		self:RefreshLeaderboard("Steal")
	end)
	while task.wait(REFRESH_INTERVAL) do
		task.spawn(function()
			self:RefreshLeaderboard("Cash")
		end)
		task.spawn(function()
			self:RefreshLeaderboard("Steal")
		end)
	end
end

function LeaderboardManager:RefreshLeaderboard(Name: "Cash" | "Steal")
	local Leaderboard = LeaderboardsFolder[Name]

	local MainContents = Leaderboard.Main.LeaderboardGui.List

	self:ClearFrame(MainContents)

	-- // load data
	local Pages
	if Name == "Cash" then
		Pages = CashOrderedDS:GetSortedAsync(false, 100, 0, 10e30)
	else
		Pages = StealsOrderedDS:GetSortedAsync(false, 100, 0, 10e30)
	end
	local leaderboardData = Pages:GetCurrentPage()
	for rank, data in leaderboardData do
		local Template = MainContents.Template:Clone()
		local PlayerName = GetPlayerName(data.key)
		if not PlayerName then
			continue
		end
		local PlayerThumbnail =
			Players:GetUserThumbnailAsync(data.key, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		Template.Name = data.key
		Template.Current.Username.Text = PlayerName
		Template.LayoutOrder = rank
		Template.Current.Rank.Text = "#" .. rank
		Template.Current.Value.Text = FormatNumber(data.value)
		Template.Current.Icon.Image = PlayerThumbnail
		Template.Current.Iconback.Image = PlayerThumbnail

		local success, result = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({ tonumber(data.key) })
		end)

		if success then
			for _, Data in ipairs(result) do
				Template.Current.DisplayName.Text = Data.DisplayName
			end
		end

		if RANK_COLORS[rank] then
			Template.Current.Rank.TextColor3 = RANK_COLORS[rank]
			Template.Current.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, RANK_COLORS[rank]),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})
		end
		Template.Parent = MainContents
		Template.Visible = true
	end
end

function LeaderboardManager:ClearFrame(ScrollingFrame: ScrollingFrame)
	for _, v in ScrollingFrame:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end
end

return LeaderboardManager
