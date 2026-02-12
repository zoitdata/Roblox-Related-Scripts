-- Save Playertime + Store Data
-- @02zoit | 12.02.2026

local DataStoreService = game:GetService("DataStoreService")
local timeStore = DataStoreService:GetDataStore("PlayerPlayTime")
local Players = game:GetService("Players")

local function loadTime(userId)
    local key = "Time_" .. userId
    local success, stored = pcall(function()
        return timeStore:GetAsync(key)
    end)
    if success and typeof(stored) == "number" then
        return stored
    end
    return 0
end

local function saveTime(userId, value)
    local key = "Time_" .. userId
    pcall(function()
        timeStore:SetAsync(key, value)
    end)
end

local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local timePlayed = Instance.new("IntValue")
    timePlayed.Name = "TimePlayed"
    timePlayed.Value = loadTime(player.UserId)
    timePlayed.Parent = leaderstats

    spawn(function()
        while player.Parent do
            task.wait(60)
            timePlayed.Value += 1
        end
    end)
end

local function onPlayerRemoving(player)
    if player.leaderstats and player.leaderstats:FindFirstChild("TimePlayed") then
        saveTime(player.UserId, player.leaderstats.TimePlayed.Value)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
