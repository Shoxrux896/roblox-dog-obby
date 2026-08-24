-- src/client/StarterPlayer/StarterPlayerScripts/ClientMain.client.lua
-- Контроллер + камера, следующая за собакой

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
print("🎮 Клиент подключился!")

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not character.Parent then
            conn:Disconnect()
            return
        end
        if UserInputService:GetFocusedTextBox() then return end

        -- Движение (WASD относительно камеры)
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

        -- Камера плавно летит за собакой
        local desiredPos = (root.CFrame * CFrame.new(0, 4.5, 11)).Position
        local currentPos = camera.CFrame.Position
        local newPos
        if (desiredPos - currentPos).Magnitude > 25 then
            newPos = desiredPos
        else
            newPos = currentPos:Lerp(desiredPos, math.min(1, dt * 8))
        end
        local aim = root.CFrame * CFrame.new(0, -1.5, 0)
        camera.CFrame = CFrame.new(newPos, aim.Position)
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end
