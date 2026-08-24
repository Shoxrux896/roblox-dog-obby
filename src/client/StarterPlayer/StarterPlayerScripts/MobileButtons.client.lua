-- src/client/StarterPlayer/StarterPlayerScripts/MobileButtons.client.lua
-- Кнопки прыжка и лая для мобильных + клавиша F на ПК

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local barkEvent = ReplicatedStorage:WaitForChild("BarkEvent", 30)

local function bark()
    barkEvent:FireServer()
end

-- На ПК лай на клавише F
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F then
        bark()
    end
end)

-- На мобильных - большие кнопки
if UserInputService.TouchEnabled then
    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileButtons"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local jumpBtn = Instance.new("TextButton")
    jumpBtn.Size = UDim2.fromOffset(84, 84)
    jumpBtn.Position = UDim2.new(1, -104, 1, -104)
    jumpBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 90)
    jumpBtn.BackgroundTransparency = 0.2
    jumpBtn.Text = "⬆"
    jumpBtn.TextSize = 36
    jumpBtn.Parent = gui
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(1, 0)
    c1.Parent = jumpBtn

    local barkBtn = Instance.new("TextButton")
    barkBtn.Size = UDim2.fromOffset(72, 72)
    barkBtn.Position = UDim2.new(1, -98, 1, -200)
    barkBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
    barkBtn.BackgroundTransparency = 0.2
    barkBtn.Text = "🐶"
    barkBtn.TextSize = 32
    barkBtn.Parent = gui
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(1, 0)
    c2.Parent = barkBtn

    jumpBtn.MouseButton1Click:Connect(function()
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Jump = true
        end
    end)

    barkBtn.MouseButton1Click:Connect(bark)
    print("📱 Мобильные кнопки созданы!")
end
