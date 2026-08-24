-- src/client/StarterPlayer/StarterPlayerScripts/ClientMain.client.lua
-- Контроллер (клавиатура ИЛИ мобильный джойстик) + камера-следование

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Если есть клавиатура - наш контроллер. Если нет - стандартный джойстик Roblox.
local useKeyboard = UserInputService.KeyboardEnabled

print("🎮 Клиент подключился! Клавиатура: " .. tostring(useKeyboard))

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable

    local first = true
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not character.Parent then
            conn:Disconnect()
            return
        end

        -- ДВИЖЕНИЕ: только для клавиатуры.
        -- На мобильных не трогаем humanoid - там работает джойстик Roblox.
        if useKeyboard then
            if UserInputService:GetFocusedTextBox() then return end

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

            humanoid:Move(move)

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                humanoid.Jump = true
            end
        end

        -- КАМЕРА: работает везде (ПК и мобильные)
        local desired = root.CFrame * CFrame.new(0, 4.5, 11)
        if first then
            camera.CFrame = desired
            first = false
        else
            local newPos = camera.CFrame.Position:Lerp(desired.Position, math.min(1, dt * 8))
            local aim = root.CFrame * CFrame.new(0, -1.5, 0)
            camera.CFrame = CFrame.new(newPos, aim.Position)
        end
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end
