-- src/server/ServerScriptService/Sounds.server.lua
-- Звуки: лай, прыжок, подбор, чекпоинт, победа

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 🔊 ЕСЛИ КАКОЙ-ТО ЗВУК НЕ ИГРАЕТ: замени цифры после rbxassetid://
local SOUNDS = {
    Bark = "rbxassetid://5302725289",       -- лай собаки (клавиша F)
    Collect = "rbxassetid://5869584231",    -- подбор косточки
    Checkpoint = "rbxassetid://1476623440", -- чекпоинт
    Win = "rbxassetid://4639854424",        -- победа
    Jump = "rbxasset://sounds/action_jump.mp3", -- прыжок (встроенный)
}

local barkEvent = Instance.new("RemoteEvent")
barkEvent.Name = "BarkEvent"
barkEvent.Parent = ReplicatedStorage

local lastJump = {}
local lastBark = {}
local joinTime = {}

local function playAt(character, id, volume)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = volume or 0.5
    sound.Parent = root
    sound:Play()
    task.delay(4, function()
        sound:Destroy()
    end)
end

local function hookLeaderstats(player, ls)
    local bones = ls:WaitForChild("Bones", 10)
    local stage = ls:WaitForChild("Stage", 10)
    local last = {bones = bones.Value, stage = stage.Value}

    bones.Changed:Connect(function(v)
        local fresh = (os.clock() - joinTime[player.UserId]) < 2
        if v > last.bones and not fresh then
            playAt(player.Character, SOUNDS.Collect, 0.6)
        end
        last.bones = v
    end)

    stage.Changed:Connect(function(v)
        local fresh = (os.clock() - joinTime[player.UserId]) < 2
        if v > last.stage and not fresh then
            if v == 99 then
                playAt(player.Character, SOUNDS.Win, 0.8)
            else
                playAt(player.Character, SOUNDS.Checkpoint, 0.6)
            end
        end
        last.stage = v
    end)
end

local function hookPlayer(player)
    joinTime[player.UserId] = os.clock()

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Jumping:Connect(function()
            local now = os.clock()
            if now - (lastJump[player.UserId] or 0) > 0.6 then
                lastJump[player.UserId] = now
                playAt(character, SOUNDS.Jump, 0.4)
            end
        end)
    end)

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        hookLeaderstats(player, ls)
    else
        player.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                hookLeaderstats(player, child)
            end
        end)
    end
end

-- Лай по нажатию F (клиент шлет сигнал сюда)
barkEvent.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if now - (lastBark[player.UserId] or 0) > 0.5 then
        lastBark[player.UserId] = now
        playAt(player.Character, SOUNDS.Bark, 0.8)
        print("🐶 " .. player.Name .. " гавкнул!")
    end
end)

Players.PlayerAdded:Connect(hookPlayer)
for _, pl in pairs(Players:GetPlayers()) do
    hookPlayer(pl)
end

print("🔊 Звуки подключены!")