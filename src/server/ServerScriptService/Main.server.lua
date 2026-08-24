-- src/server/ServerScriptService/Main.server.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 1. Очищаем мир: убираем стандартную серую базу и спавн
for _, child in pairs(workspace:GetChildren()) do
    if child:IsA("BasePart") or child:IsA("SpawnLocation") then
        child:Destroy()
    end
end

-- Функция создания модели собаки
local function createDogModel()
    local dog = Instance.new("Model")
    dog.Name = "DogModel"

    local anim = { legs = {}, tail = nil }

    -- Тело
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 1, 4)
    body.BrickColor = BrickColor.new("Brown")
    body.Material = Enum.Material.SmoothPlastic
    body.CanCollide = false
    body.Massless = true
    body.Parent = dog

    -- Голова
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.5, 1.5, 1.5)
    head.BrickColor = BrickColor.new("Brown")
    head.CanCollide = false
    head.Massless = true
    head.Parent = dog

    local headWeld = Instance.new("Weld")
    headWeld.Part0 = body
    headWeld.Part1 = head
    headWeld.C0 = CFrame.new(0, 0.5, -2.2)
    headWeld.Parent = body

    -- Морда
    local snout = Instance.new("Part")
    snout.Name = "Snout"
    snout.Size = Vector3.new(0.6, 0.5, 0.6)
    snout.BrickColor = BrickColor.new("Dark orange")
    snout.CanCollide = false
    snout.Massless = true
    snout.Parent = dog
    local snoutWeld = Instance.new("Weld")
    snoutWeld.Part0 = head
    snoutWeld.Part1 = snout
    snoutWeld.C0 = CFrame.new(0, -0.2, -0.9)
    snoutWeld.Parent = head

    -- Лапы (4 штуки)
    for i = 1, 4 do
        local leg = Instance.new("Part")
        leg.Name = "Leg" .. i
        leg.Size = Vector3.new(0.5, 1.2, 0.5)
        leg.BrickColor = BrickColor.new("Dark orange")
        leg.CanCollide = false
        leg.Massless = true
        leg.Parent = dog

        local legWeld = Instance.new("Weld")
        legWeld.Part0 = body
        legWeld.Part1 = leg
        local x = (i % 2 == 0) and 0.7 or -0.7
        local z = (i <= 2) and 1.5 or -1.5
        legWeld.C0 = CFrame.new(x, -0.8, z)
        legWeld.Parent = body
        anim.legs[i] = legWeld
    end

    -- Хвост
    local tail = Instance.new("Part")
    tail.Name = "Tail"
    tail.Size = Vector3.new(0.3, 0.3, 1.2)
    tail.BrickColor = BrickColor.new("Brown")
    tail.CanCollide = false
    tail.Massless = true
    tail.Parent = dog

    local tailWeld = Instance.new("Weld")
    tailWeld.Part0 = body
    tailWeld.Part1 = tail
    tailWeld.C0 = CFrame.new(0, 0.4, 2.2) * CFrame.Angles(math.rad(30), 0, 0)
    tailWeld.Parent = body
    anim.tail = tailWeld

    -- Уши
    for _, x in pairs({-0.5, 0.5}) do
        local ear = Instance.new("Part")
        ear.Name = "Ear"
        ear.Size = Vector3.new(0.2, 0.6, 0.2)
        ear.BrickColor = BrickColor.new("Dark orange")
        ear.CanCollide = false
        ear.Massless = true
        ear.Parent = dog
        local earWeld = Instance.new("Weld")
        earWeld.Part0 = head
        earWeld.Part1 = ear
        earWeld.C0 = CFrame.new(x, 0.9, 0)
        earWeld.Parent = head
    end

    return dog, body, anim
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")

        -- Скрываем стандартного персонажа
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CastShadow = false
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        -- Включаем движение
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        -- Опускаем камеру ниже, ближе к собаке
        humanoid.CameraOffset = Vector3.new(0, -1.5, 0)

        -- Создаем собаку
        local dogModel, dogBody, anim = createDogModel()
        dogModel.Parent = character

        -- Привязываем собаку к персонажу (без поворота на 180)
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = dogBody
        weld.C0 = CFrame.new(0, -2, 0)
        weld.Parent = rootPart

        -- Анимация: виляние хвостом и перебор лапами
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not character.Parent then
                conn:Disconnect()
                return
            end
            local t = os.clock()
            local moving = humanoid.MoveDirection.Magnitude > 0
            local speed = moving and 12 or 4
            local amp = moving and 0.6 or 0.1

            for i, legWeld in pairs(anim.legs) do
                local phase = (i == 1 or i == 4) and 0 or math.pi
                legWeld.C1 = CFrame.Angles(math.sin(t * speed + phase) * amp, 0, 0)
            end
            anim.tail.C1 = CFrame.Angles(0, math.sin(t * 8) * 0.5, 0)
        end)

        print("🐕 Собака заспавнена для игрока " .. player.Name)
    end)
end

-- Функция создания зоны спавна
local function createSpawnZone()
    local spawnZone = Instance.new("Model")
    spawnZone.Name = "SpawnZone"
    spawnZone.Parent = workspace

    local platform = Instance.new("Part")
    platform.Name = "Platform"
    platform.Size = Vector3.new(20, 1, 20)
    platform.Position = Vector3.new(0, 0, 0)
    platform.BrickColor = BrickColor.new("Bright green")
    platform.Material = Enum.Material.Grass
    platform.Anchored = true
    platform.Parent = spawnZone

    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(6, 1, 6)
    spawnLocation.Position = Vector3.new(0, 1, 0)
    spawnLocation.BrickColor = BrickColor.new("Bright blue")
    spawnLocation.Material = Enum.Material.Neon
    spawnLocation.Anchored = true
    spawnLocation.Parent = spawnZone

    local walls = {
        {pos = Vector3.new(0, 2.5, 10), size = Vector3.new(20, 5, 1)},
        {pos = Vector3.new(0, 2.5, -10), size = Vector3.new(20, 5, 1)},
        {pos = Vector3.new(10, 2.5, 0), size = Vector3.new(1, 5, 20)},
        {pos = Vector3.new(-10, 2.5, 0), size = Vector3.new(1, 5, 20)}
    }

    for _, wallData in pairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "Wall"
        wall.Size = wallData.size
        wall.Position = wallData.pos
        wall.BrickColor = BrickColor.new("Stone grey")
        wall.Material = Enum.Material.Concrete
        wall.Anchored = true
        wall.Parent = spawnZone
    end

    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 30
    light.Color = Color3.fromRGB(255, 255, 200)
    light.Parent = spawnLocation

    print("🏁 Зона спавна создана!")
end

createSpawnZone()
Players.PlayerAdded:Connect(setupPlayer)
for _, pl in pairs(Players:GetPlayers()) do
    setupPlayer(pl)
end
