-- src/client/StarterPlayer/StarterPlayerScripts/ClientMain.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
print("🎮 Клиент подключился!")

-- Диагностика: видим ли мы вообще нажатия клавиш?
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then
        print("🎮 W НАЖАТА (processed=" .. tostring(gameProcessed) .. ")")
    end
end)

-- Собственный контроллер движения (не зависит от стандартного)
local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not character.Parent then
            conn:Disconnect()
            return
        end
        if UserInputService:GetFocusedTextBox() then return end

        local camera = workspace.CurrentCamera
        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        look = Vector3.new(look.X, 0, look.Z)
        right = Vector3.new(right.X, 0, right.Z)
        if look.Magnitude > 0.01 then look = look.Unit end
        if right.Magnitude > 0.01 then right = right.Unit end

        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end

        if move.Magnitude > 0 then
            humanoid:Move(move)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.Jump = true
        end
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end
