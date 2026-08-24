-- src/server/ServerScriptService/Main.server.lua

local Players = game:GetService("Players")

-- Функция создания модели собаки из деталей
local function createDogModel()
    local dog = Instance.new("Model")
    dog.Name = "DogModel"

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
    head.Material = Enum.Material.SmoothPlastic
    head.CanCollide = false
    head.Massless = true
    head.Parent = dog

    -- Привязка головы к телу
    local headWeld = Instance.new("Weld")
    headWeld.Part0 = body
    headWeld.Part1 = head
    headWeld.C0 = CFrame.new(0, 0.5, -2.2) * CFrame.Angles(0, math.rad(180), 0)
    headWeld.Parent = body

    -- Лапы (4 штуки)
    for i = 1, 4 do
        local leg = Instance.new("Part")
        leg.Name = "Leg" .. i
        leg.Size = Vector3.new(0.5, 1, 0.5)
        leg.BrickColor = BrickColor.new("Dark orange")
        leg.Material = Enum.Material.SmoothPlastic
        leg.CanCollide = false
        leg.Massless = true
        leg.Parent = dog
        
        local legWeld = Instance.new("Weld")
        legWeld.Part0 = body
        legWeld.Part1 = leg
        local x = (i % 2 == 0) and 0.8 or -0.8
        local z = (i <= 2) and 1.5 or -1.5
        legWeld.C0 = CFrame.new(x, -0.5, z)
        legWeld.Parent = body
    end

    -- Хвост
    local tail = Instance.new("Part")
    tail.Name = "Tail"
    tail.Size = Vector3.new(0.3, 0.3, 1)
    tail.BrickColor = BrickColor.new("Brown")
    tail.Material = Enum.Material.SmoothPlastic
    tail.CanCollide = false
    tail.Massless = true
    tail.Parent = dog

    local tailWeld = Instance.new("Weld")
    tailWeld.Part0 = body
    tailWeld.Part1 = tail
    tailWeld.C0 = CFrame.new(0, 0.5, 2) * CFrame.Angles(math.rad(45), 0, 0)
    tailWeld.Parent = body

    -- Уши
    local ear1 = Instance.new("Part")
    ear1.Name = "Ear1"
    ear1.Size = Vector3.new(0.2, 0.6, 0.2)
    ear1.BrickColor = BrickColor.new("Dark orange")
    ear1.Material = Enum.Material.SmoothPlastic
    ear1.CanCollide = false
    ear1.Massless = true
    ear1.Parent = dog
    
    local ear1Weld = Instance.new("Weld")
    ear1Weld.Part0 = head
    ear1Weld.Part1 = ear1
    ear1Weld.C0 = CFrame.new(-0.5, 0.8, 0)
    ear1Weld.Parent = head

    local ear2 = ear1:Clone()
    ear2.Name = "Ear2"
    ear2.Parent = dog
    local ear2Weld = Instance.new("Weld")
    ear2Weld.Part0 = head
    ear2Weld.Part1 = ear2
    ear2Weld.C0 = CFrame.new(0.5, 0.8, 0)
    ear2Weld.Parent = head

    return dog, body
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")

        -- 1. Скрываем стандартного персонажа
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CastShadow = false
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        -- 2. Включаем ходьбу и прыжки
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50

        -- 3. Создаем собаку
        local dogModel, dogBody = createDogModel()
        dogModel.Parent = character

        -- 4. Привязываем собаку к невидимому персонажу
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = dogBody
        weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0) 
        weld.Parent = rootPart
        
        print("🐕 Собака заспавнена для игрока " .. player.Name)
    end)
end

-- Функция создания зоны спавна
local function createSpawnZone()
    local spawnZone = Instance.new("Model")
    spawnZone.Name = "SpawnZone"
    spawnZone.Parent = workspace

    -- Основная платформа (трава)
    local platform = Instance.new("Part")
    platform.Name = "Platform"
    platform.Size = Vector3.new(20, 1, 20)
    platform.Position = Vector3.new(0, 0, 0)
    platform.BrickColor = BrickColor.new("Bright green")
    platform.Material = Enum.Material.Grass
    platform.Anchored = true
    platform.Parent = spawnZone

    -- Точка спавна (неон)
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(6, 1, 6)
    spawnLocation.Position = Vector3.new(0, 1, 0)
    spawnLocation.BrickColor = BrickColor.new("Bright blue")
    spawnLocation.Material = Enum.Material.Neon
    spawnLocation.Anchored = true
    spawnLocation.Parent = spawnZone
    
    -- Стены по краям
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

    -- Освещение
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 30
    light.Color = Color3.fromRGB(255, 255, 200)
    light.Parent = spawnLocation
    
    print("🏁 Зона спавна создана!")
end

-- Запуск функций при старте сервера
createSpawnZone()

Players.PlayerAdded:Connect(setupPlayer)
