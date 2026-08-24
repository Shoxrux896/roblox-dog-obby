-- src/server/ServerScriptService/Obby.server.lua
-- Трасса с препятствиями: лава, батут, бревно, вращающаяся балка

local Players = game:GetService("RunService") and game:GetService("Players") or nil
local Players2 = game:GetService("Players")
local RunService = game:GetService("RunService")

local START_SPAWN = CFrame.new(0, 6, 0)

local obby = Instance.new("Model")
obby.Name = "ObbyCourse"
obby.Parent = workspace

local function makePart(name, size, top, z, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = Vector3.new(0, top - 0.5, z)
    p.Anchored = true
    if color then p.BrickColor = color end
    if material then p.Material = material end
    p.Parent = obby
    return p
end

local function getRoot(player)
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function respawn(player)
    local root = getRoot(player)
    if root then
        root.CFrame = player:GetAttribute("RespawnCFrame") or START_SPAWN
    end
end

---------------- ПЛАТФОРМЫ ----------------
makePart("P1", Vector3.new(5, 1, 5), 3.5, 14)
makePart("P2", Vector3.new(5, 1, 5), 4.0, 21)
makePart("P3", Vector3.new(5, 1, 5), 4.5, 28)
makePart("P4", Vector3.new(5, 1, 5), 5.5, 38)
makePart("Beam", Vector3.new(1.2, 0.5, 7), 5.5, 43)
makePart("P5", Vector3.new(5, 1, 5), 5.5, 48)
makePart("FinishPlatform", Vector3.new(6, 1, 6), 6.0, 56)

---------------- ЧЕКПОИНТЫ ----------------
local function addCheckpoint(name, top, z, stageNumber)
    local pad = makePart(name, Vector3.new(3, 0.3, 3), top + 0.15, z,
        BrickColor.new("Cyan"), Enum.Material.Neon)
    pad.Touched:Connect(function(hit)
        local player = Players2:GetPlayerFromCharacter(hit.Parent)
        if not player then return end
        player:SetAttribute("RespawnCFrame", CFrame.new(0, top + 3, z))
        local ls = player:FindFirstChild("leaderstats")
        local stage = ls and ls:FindFirstChild("Stage")
        if stage and stage.Value < stageNumber then
            stage.Value = stageNumber
            print("🚩 " .. player.Name .. " открыл чекпоинт " .. name .. "!")
        end
    end)
end

addCheckpoint("Checkpoint1", 3.5, 13, 2)
addCheckpoint("Checkpoint2", 4.5, 27, 3)
addCheckpoint("Checkpoint3", 5.5, 47, 4)

---------------- ЛАВА ----------------
local lava = makePart("Lava1", Vector3.new(5, 0.5, 1.5), 4.3, 21,
    BrickColor.new("Bright red"), Enum.Material.Neon)
lava.Touched:Connect(function(hit)
    local player = Players2:GetPlayerFromCharacter(hit.Parent)
    if player then
        print("🔥 " .. player.Name .. " наступил на лаву!")
        respawn(player)
    end
end)

---------------- БАТУТ ----------------
local bounce = makePart("Bounce1", Vector3.new(3, 0.4, 1.5), 4.7, 29.8,
    BrickColor.new("New Yolk"), Enum.Material.Neon)
bounce.Touched:Connect(function(hit)
    local player = Players2:GetPlayerFromCharacter(hit.Parent)
    if not player then return end
    local root = getRoot(player)
    if root and root.AssemblyLinearVelocity.Magnitude < 30 then
        root.AssemblyLinearVelocity = Vector3.new(0, 50, 25)
        print("⚡ Батут подбросил " .. player.Name .. "!")
    end
end)

---------------- ВРАЩАЮЩАЯСЯ БАЛКА ----------------
local bar = makePart("SpinBar", Vector3.new(9, 0.8, 0.8), 6.8, 49,
    BrickColor.new("Bright red"), Enum.Material.SmoothPlastic)
RunService.Heartbeat:Connect(function(dt)
    bar.CFrame = bar.CFrame * CFrame.Angles(0, dt * 1.5, 0)
end)

---------------- ФИНИШ ----------------
local finish = makePart("Finish", Vector3.new(6, 0.3, 6), 6.15, 56,
    BrickColor.new("New Yolk"), Enum.Material.Neon)
finish.Touched:Connect(function(hit)
    local player = Players2:GetPlayerFromCharacter(hit.Parent)
    if not player then return end
    print("🏆 " .. player.Name .. " ПРОШЕЛ OBBY! ПОБЕДА!")
    local ls = player:FindFirstChild("leaderstats")
    local stage = ls and ls:FindFirstChild("Stage")
    if stage then stage.Value = 99 end
    task.delay(3, function()
        player:SetAttribute("RespawnCFrame", START_SPAWN)
        if stage then stage.Value = 1 end
        local root = getRoot(player)
        if root then root.CFrame = START_SPAWN end
    end)
end)

print("🧱 Трасса Obby v2 построена!")
