-- src/server/ServerScriptService/Main.server.lua

local Players = game:GetService("Players")

-- Функция, которая сделает персонажа невидимым и отключит управление
local function disableDefaultCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    -- 1. Делаем все части тела и аксессуары невидимыми
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CastShadow = false
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end

    -- 2. Убираем никнейм и полоску здоровья над головой
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    -- 3. Запрещаем ходить и прыгать (чтобы не бегать "призраком")
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    
    -- 4. Останавливаем все звуки (шаги, дыхание)
    for _, sound in pairs(character:GetDescendants()) do
        if sound:IsA("Sound") then
            sound:Stop()
        end
    end
    
    print("👻 Персонаж игрока скрыт и обездвижен.")
end

Players.PlayerAdded:Connect(function(player)
    print("🐕 Игрок присоединился: " .. player.Name)

    -- Когда Roblox создаст персонажа, мы сразу применяем нашу функцию
    player.CharacterAdded:Connect(function(character)
        disableDefaultCharacter(character)
    end)
end)
