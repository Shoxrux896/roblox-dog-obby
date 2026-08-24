-- src/server/ServerScriptService/SaveSystem.server.lua
-- Сохранение прогресса: косточки, Stage, скорость

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("DogObbySave_v1")

local START_SPAWN = CFrame.new(0, 6, 0)
local CHECKPOINTS = {
    [2] = CFrame.new(0, 6.5, 13),
    [3] = CFrame.new(0, 7.5, 27),
    [4] = CFrame.new(0, 8.5, 47),
}

local function getStats(player)
    local ls = player:FindFirstChild("leaderstats")
    local bones = ls and ls:FindFirstChild("Bones")
    local stage = ls and ls:FindFirstChild("Stage")
    local stageVal = stage and stage.Value or 1
    if stageVal == 99 then stageVal = 1 end
    return {
        Bones = bones and bones.Value or 0,
        Stage = stageVal,
        SpeedBonus = player:GetAttribute("SpeedBonus") or 0,
    }
end

local function savePlayer(player)
    local ok, err = pcall(function()
        store:SetAsync(player.UserId, getStats(player))
    end)
    if ok then
        print("💾 Сохранено: " .. player.Name)
    else
        warn("💾 Ошибка сохранения: " .. tostring(err))
    end
end

local function applyStats(player, data)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        ls.Parent = player
    end
    local bones = ls:FindFirstChild("Bones")
    if not bones then
        bones = Instance.new("IntValue")
        bones.Name = "Bones"
        bones.Parent = ls
    end
    local stage = ls:FindFirstChild("Stage")
    if not stage then
        stage = Instance.new("IntValue")
        stage.Name = "Stage"
        stage.Parent = ls
    end
    bones.Value = data.Bones
    stage.Value = data.Stage
    player:SetAttribute("SpeedBonus", data.SpeedBonus)
end

local function loadPlayer(player)
    local data = {Bones = 0, Stage = 1, SpeedBonus = 0}
    local ok, result = pcall(function()
        return store:GetAsync(player.UserId)
    end)

    if ok and type(result) == "table" then
        data.Bones = result.Bones or 0
        data.Stage = result.Stage or 1
        data.SpeedBonus = result.SpeedBonus or 0
        print("💾 Загружено: " .. player.Name .. " | костей: " .. data.Bones .. " | этап: " .. data.Stage)
    else
        warn("💾 Не удалось загрузить сохранение. В Studio: Game Settings -> Security -> включи 'Enable Studio Access to API Services'")
    end

    applyStats(player, data)

    -- Побеждаем гонку событий с другими скриптами
    task.delay(0.3, function()
        if not player.Parent then return end
        applyStats(player, data)
        if data.Stage > 1 then
            player:SetAttribute("RespawnCFrame", CHECKPOINTS[data.Stage] or START_SPAWN)
        end
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 20 + data.SpeedBonus
        end
    end)
end

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(savePlayer)

-- Автосохранение каждые 30 секунд
task.spawn(function()
    while task.wait(30) do
        for _, player in pairs(Players:GetPlayers()) do
            savePlayer(player)
        end
    end
end)

-- Сохранение при закрытии сервера
game:BindToClose(function()
    for _, player in pairs(Players:GetPlayers()) do
        savePlayer(player)
    end
end)
