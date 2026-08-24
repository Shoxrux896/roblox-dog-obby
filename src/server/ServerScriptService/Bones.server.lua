-- src/server/ServerScriptService/Bones.server.lua
-- Косточки-валюта + прокачка скорости

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local bonesFolder = Instance.new("Folder")
bonesFolder.Name = "BonesFolder"
bonesFolder.Parent = workspace

local liveBones = {}

local BONE_SPOTS = {
    Vector3.new(-6, 4.3, -6),
    Vector3.new(6, 4.3, 6),
    Vector3.new(-6, 4.3, 6),
    Vector3.new(6, 4.3, -6),
    Vector3.new(0, 4.3, -7),
    Vector3.new(0, 5.3, 14),
    Vector3.new(0, 5.8, 28),
    Vector3.new(0, 6.8, 38),
    Vector3.new(0, 6.8, 48),
}

local function giveSpeedBonus(player, bonesValue)
    local bonus = math.min(20, math.floor(bonesValue / 5) * 2)
    local old = player:GetAttribute("SpeedBonus") or 0
    player:SetAttribute("SpeedBonus", bonus)
    if bonus > old then
        print("⚡ " .. player.Name .. " ускорился! Бонус скорости: +" .. bonus)
    end
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 20 + bonus
    end
end

local function spawnBone(index, pos)
    local bone = Instance.new("Model")
    bone.Name = "Bone" .. index

    local stick = Instance.new("Part")
    stick.Name = "Stick"
    stick.Size = Vector3.new(0.9, 0.18, 0.18)
    stick.Color = Color3.fromRGB(245, 245, 245)
    stick.Material = Enum.Material.SmoothPlastic
    stick.Anchored = true
    stick.CanCollide = false
    stick.Parent = bone

    for _, x in pairs({-0.45, 0.45}) do
        local knob = Instance.new("Part")
        knob.Name = "Knob"
        knob.Shape = Enum.PartType.Ball
        knob.Size = Vector3.new(0.35, 0.35, 0.35)
        knob.Color = Color3.fromRGB(245, 245, 245)
        knob.Material = Enum.Material.SmoothPlastic
        knob.Anchored = true
        knob.CanCollide = false
        knob.Position = Vector3.new(x, 0, 0)
        knob.Parent = bone
    end

    bone.PrimaryPart = stick
    bone:SetPrimaryPartCFrame(CFrame.new(pos))
    bone.Parent = bonesFolder
    liveBones[index] = bone

    local function onTouched(hit)
        if not bone.Parent then return end
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end

        bone:Destroy()
        liveBones[index] = nil

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
            bones.Value = 0
            bones.Parent = ls
        end
        bones.Value = bones.Value + 1
        print("🦴 " .. player.Name .. " подобрал косточку! Всего: " .. bones.Value)
        giveSpeedBonus(player, bones.Value)

        task.delay(10, function()
            spawnBone(index, pos)
        end)
    end

    for _, part in pairs(bone:GetChildren()) do
        part.Touched:Connect(onTouched)
    end
end

for i, pos in pairs(BONE_SPOTS) do
    spawnBone(i, pos)
end

-- Вращение и парение косточек
RunService.Heartbeat:Connect(function(dt)
    local t = os.clock()
    for index, bone in pairs(liveBones) do
        if bone.Parent then
            local cf = bone:GetPrimaryPartCFrame()
            cf = cf * CFrame.Angles(0, dt * 2, 0)
            cf = cf + Vector3.new(0, math.sin(t * 2 + index) * 0.01, 0)
            bone:SetPrimaryPartCFrame(cf)
        end
    end
end)

-- После возрождения возвращаем бонус скорости
local function reapplySpeed(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        task.wait(0.1)
        humanoid.WalkSpeed = 20 + (player:GetAttribute("SpeedBonus") or 0)
    end)
end

Players.PlayerAdded:Connect(reapplySpeed)
for _, pl in pairs(Players:GetPlayers()) do
    reapplySpeed(pl)
end

print("🦴 Косточки разложены по миру!")
