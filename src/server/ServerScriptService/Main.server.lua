-- src/server/ServerScriptService/Main.server.lua
-- Собака + следы + Obby с чекпоинтами

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local START_SPAWN = CFrame.new(0, 6, 0)
local playerSpawns = {}

local printsFolder = Instance.new("Folder")
printsFolder.Name = "PawPrints"
printsFolder.Parent = workspace

for _, child in pairs(workspace:GetChildren()) do
    if child:IsA("SpawnLocation") then
        child:Destroy()
    end
end

---------------- СОБАКА ----------------
local function createDogModel()
    local dog = Instance.new("Model")
    dog.Name = "DogModel"
    local anim = { legs = {}, tail = nil }

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 1, 4)
    body.BrickColor = BrickColor.new("Brown")
    body.Material = Enum.Material.SmoothPlastic
    body.CanCollide = false
    body.Massless = true
    body.Parent = dog

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

---------------- СЛЕДЫ ЛАП ----------------
local function spawnPawPrint(params, position, forward, sideOffset)
    local origin = position + Vector3.new(0, 2, 0)
    local result = workspace:Raycast(origin, Vector3.new(0, -12, 0), params)
    if not result then return end

    local pos = result.Position + Vector3.new(0, 0.06, 0) + sideOffset
    local paw = Instance.new("Part")
    paw.Name = "PawPrint"
    paw.Size = Vector3.new(0.5, 0.08, 0.7)
    paw.Color = Color3.fromRGB(70, 45, 25)
    paw.Material = Enum.Material.Slate
    paw.Anchored = true
    paw.CanCollide = false
    paw.CFrame = CFrame.lookAt(pos, pos + forward)
    paw.Parent = printsFolder

    local tween = TweenService:Create(paw, TweenInfo.new(1.6), {Transparency = 1})
    tween:Play()
    task.delay(1.7, function()
        paw:Destroy()
    end)
end

---------------- OBBY ТРАССА ----------------
local function createObby()
    local obby = Instance.new("Model")
    obby.Name = "ObbyCourse"
    obby.Parent = workspace

    local platforms = {
        {z = 14, top = 3.5, checkpoint = 1},
        {z = 20, top = 4.0},
        {z = 26, top = 4.5, checkpoint = 2},
        {z = 32, top = 5.0},
        {z = 38, top = 5.5, checkpoint = 3},
        {z = 45, top = 6.0, finish = true},
    }

    for _, data in pairs(platforms) do
        local plat = Instance.new("Part")
        plat.Name = "ObbyPlatform"
        plat.Size = Vector3.new(5, 1, 5)
        plat.Position = Vector3.new(0, data.top - 0.5, data.z)
        plat.Anchored = true
        plat.Material = Enum.Material.SmoothPlastic
        plat.BrickColor = BrickColor.new("Medium stone grey")
        plat.Parent = obby

        if data.checkpoint then
            local pad = Instance.new("Part")
            pad.Name = "Checkpoint" .. data.checkpoint
            pad.Size = Vector3.new(3, 0.3, 3)
            pad.Position = Vector3.new(0, data.top + 0.15, data.z)
            pad.Anchored = true
            pad.Material = Enum.Material.Neon
            pad.BrickColor = BrickColor.new("Cyan")
            pad.Parent = obby

            pad.Touched:Connect(function(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end
                playerSpawns[player] = CFrame.new(0, data.top + 3, data.z)
                local ls = player:FindFirstChild("leaderstats")
                local stage = ls and ls:FindFirstChild("Stage")
                if stage and stage.Value < data.checkpoint + 1 then
                    stage.Value = data.checkpoint + 1
                    print("🚩 " .. player.Name .. " прошел чекпоинт " .. data.checkpoint .. "!")
                end
            end)
        end

        if data.finish then
            local pad = Instance.new("Part")
            pad.Name = "Finish"
            pad.Size = Vector3.new(5, 0.3, 5)
            pad.Position = Vector3.new(0, data.top + 0.15, data.z)
            pad.Anchored = true
            pad.Material = Enum.Material.Neon
            pad.BrickColor = BrickColor.new("New Yolk")
            pad.Parent = obby

            pad.Touched:Connect(function(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end
                print("🏆 " .. player.Name .. " ПРОШЕЛ OBBY! ПОБЕДА!")
                local ls = player:FindFirstChild("leaderstats")
                local stage = ls and ls:FindFirstChild("Stage")
                if stage then stage.Value = 99 end
                task.delay(3, function()
                    playerSpawns[player] = START_SPAWN
                    if stage then stage.Value = 1 end
                    if player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then root.CFrame = START_SPAWN end
                    end
                end)
            end)
        end
    end
    print("🧱 Трасса Obby построена!")
end

---------------- ИГРОК ----------------
local function applyToCharacter(character, player)
    if character:FindFirstChild("DogModel") then return end
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CastShadow = false
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.WalkSpeed = 20
    humanoid.JumpPower = 50

    local dogModel, dogBody, anim = createDogModel()
    dogModel.Parent = character

    local weld = Instance.new("Weld")
    weld.Part0 = rootPart
    weld.Part1 = dogBody
    weld.C0 = CFrame.new(0, -2, 0)
    weld.Parent = rootPart

    -- Рейкаст не должен попадать в самого игрока и в старые следы
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character, printsFolder}

    local conn
    local dbg = 0
    local accum = 0
    local side = false
    local lastPos = rootPart.Position

    conn = RunService.Heartbeat:Connect(function(dt)
        if not character.Parent then
            conn:Disconnect()
            return
        end

        dbg = dbg + dt
        if dbg >= 1 then
            dbg = 0
            print(string.format("DBG move=%.2f Y=%.2f speed=%d",
                humanoid.MoveDirection.Magnitude, rootPart.Position.Y, humanoid.WalkSpeed))
        end

        -- Падение = возврат на последний чекпоинт
        if rootPart.Position.Y < 3.2 then
            rootPart.CFrame = playerSpawns[player] or START_SPAWN
        end

        -- Следы лап
        local md = humanoid.MoveDirection
        local moving = md.Magnitude > 0
        if moving then
            accum = accum + (rootPart.Position - lastPos).Magnitude
            if accum >= 2.2 then
                accum = 0
                side = not side
                local fwd = Vector3.new(md.X, 0, md.Z)
                if fwd.Magnitude > 0.01 then
                    fwd = fwd.Unit
                    local right = fwd:Cross(Vector3.new(0, 1, 0))
                    local off = right * (side and 0.35 or -0.35)
                    spawnPawPrint(rayParams, rootPart.Position, fwd, off)
                end
            end
        end
        lastPos = rootPart.Position

        -- Анимация собаки
        local t = os.clock()
        local speed = moving and 12 or 4
        local amp = moving and 0.6 or 0.1

        for i, legWeld in pairs(anim.legs) do
            local phase = (i == 1 or i == 4) and 0 or math.pi
            legWeld.C1 = CFrame.Angles(math.sin(t * speed + phase) * amp, 0, 0)
        end
        anim.tail.C1 = CFrame.Angles(0, math.sin(t * 8) * 0.5, 0)
    end)

    print("🐕 Собака готова для игрока " .. player.Name .. "!")
end

local function setupPlayer(player)
    -- Таблица лидеров (Stage)
    if not player:FindFirstChild("leaderstats") then
        local ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        local stage = Instance.new("IntValue")
        stage.Name = "Stage"
        stage.Value = 1
        stage.Parent = ls
        ls.Parent = player
    end
    playerSpawns[player] = START_SPAWN

    player.CharacterAdded:Connect(function(character)
        applyToCharacter(character, player)
    end)
    if player.Character then
        applyToCharacter(player.Character, player)
    end
end

---------------- ЗОНА СПАВНА ----------------
local function createSpawnZone()
    local spawnZone = Instance.new("Model")
    spawnZone.Name = "SpawnZone"
    spawnZone.Parent = workspace

    local platform = Instance.new("Part")
    platform.Name = "Platform"
    platform.Size = Vector3.new(20, 1, 20)
    platform.Position = Vector3.new(0, 3, 0)
    platform.BrickColor = BrickColor.new("Bright green")
    platform.Material = Enum.Material.Grass
    platform.Anchored = true
    platform.Parent = spawnZone

    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Size = Vector3.new(6, 1, 6)
    spawnLocation.Position = Vector3.new(0, 4, 0)
    spawnLocation.BrickColor = BrickColor.new("Bright blue")
    spawnLocation.Material = Enum.Material.Neon
    spawnLocation.Anchored = true
    spawnLocation.Parent = spawnZone

    local walls = {
        {pos = Vector3.new(0, 5.5, -10), size = Vector3.new(20, 5, 1)},
        {pos = Vector3.new(10, 5.5, 0), size = Vector3.new(1, 5, 20)},
        {pos = Vector3.new(-10, 5.5, 0), size = Vector3.new(1, 5, 20)},
        -- Передняя стена с ПРОХОДОМ к трассе Obby
        {pos = Vector3.new(-6, 5.5, 10), size = Vector3.new(8, 5, 1)},
        {pos = Vector3.new(6, 5.5, 10), size = Vector3.new(8, 5, 1)},
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

    print("🏁 Зона спавна создана!")
end

Players.PlayerRemoving:Connect(function(player)
    playerSpawns[player] = nil
end)

createSpawnZone()
createObby()
Players.PlayerAdded:Connect(setupPlayer)
for _, pl in pairs(Players:GetPlayers()) do
    setupPlayer(pl)
end
