-- src/client/StarterPlayer/StarterPlayerScripts/Hud.client.lua
-- Красивый HUD: счетчики, подсказка, уведомления

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "DogHud"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

---------------- СЧЕТЧИКИ ----------------
local topBar = Instance.new("Frame")
topBar.Size = UDim2.fromOffset(230, 76)
topBar.Position = UDim2.fromOffset(16, 16)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BackgroundTransparency = 0.3
topBar.BorderSizePixel = 0
topBar.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = topBar

local bonesLabel = Instance.new("TextLabel")
bonesLabel.Name = "BonesLabel"
bonesLabel.Size = UDim2.new(1, -24, 0.5, 0)
bonesLabel.Position = UDim2.fromOffset(12, 4)
bonesLabel.BackgroundTransparency = 1
bonesLabel.Text = "🦴 Косточки: 0"
bonesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bonesLabel.TextSize = 22
bonesLabel.TextXAlignment = Enum.TextXAlignment.Left
bonesLabel.Parent = topBar

local stageLabel = Instance.new("TextLabel")
stageLabel.Name = "StageLabel"
stageLabel.Size = UDim2.new(1, -24, 0.5, 0)
stageLabel.Position = UDim2.fromOffset(12, 38)
stageLabel.BackgroundTransparency = 1
stageLabel.Text = "🚩 Этап: 1"
stageLabel.TextColor3 = Color3.fromRGB(140, 255, 180)
stageLabel.TextSize = 22
stageLabel.TextXAlignment = Enum.TextXAlignment.Left
stageLabel.Parent = topBar

---------------- ПОДСКАЗКА ----------------
local hint = Instance.new("TextLabel")
hint.Size = UDim2.fromOffset(440, 36)
hint.Position = UDim2.new(0.5, -220, 1, -52)
hint.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hint.BackgroundTransparency = 0.35
hint.BorderSizePixel = 0
hint.Text = "WASD — бег • Space — прыжок • F гав • Собирай косточки 🦴"
hint.TextColor3 = Color3.fromRGB(255, 255, 255)
hint.TextSize = 16
hint.Parent = gui
local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 10)
hintCorner.Parent = hint

---------------- УВЕДОМЛЕНИЯ ----------------
local function showNotify(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(420, 44)
    label.Position = UDim2.new(0.5, -210, 0, 90)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    label.BackgroundTransparency = 0.15
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 220, 100)
    label.TextSize = 20
    label.Parent = gui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = label

    task.wait(0.6)
    local tween = TweenService:Create(label, TweenInfo.new(1.8), {
        BackgroundTransparency = 1,
        TextTransparency = 1,
    })
    tween:Play()
    task.delay(2, function()
        label:Destroy()
    end)
end

local notifyEvent = ReplicatedStorage:WaitForChild("NotifyEvent", 30)
if notifyEvent then
    notifyEvent.OnClientEvent:Connect(showNotify)
end

---------------- ОБНОВЛЕНИЕ СЧЕТЧИКОВ ----------------
task.spawn(function()
    while task.wait(0.25) do
        local ls = player:FindFirstChild("leaderstats")
        local bones = ls and ls:FindFirstChild("Bones")
        local stage = ls and ls:FindFirstChild("Stage")
        bonesLabel.Text = "🦴 Косточки: " .. (bones and bones.Value or 0)
        local stageVal = stage and stage.Value or 1
        stageLabel.Text = "🚩 Этап: " .. (stageVal == 99 and "ФИНИШ!" or stageVal)
    end
end)

showNotify("🐶 Добро пожаловать! Пройди трассу и собери косточки!")
print("🖥️ HUD загружен!")
