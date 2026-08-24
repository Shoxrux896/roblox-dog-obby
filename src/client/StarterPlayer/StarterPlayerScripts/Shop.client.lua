-- src/client/StarterPlayer/StarterPlayerScripts/Shop.client.lua
-- Кнопка и окно магазина

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shopEvent = ReplicatedStorage:WaitForChild("ShopEvent", 30)

local ITEMS = {
    {id = "Speed", name = "⚡ Скорость", attr = "ShopSpeed", base = 10, mult = 2, max = 5},
    {id = "Jump", name = "🦘 Прыжок", attr = "ShopJump", base = 15, mult = 2, max = 5},
    {id = "Magnet", name = "🧲 Магнит", attr = "ShopMagnet", base = 25, mult = 3, max = 3},
}

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

---------------- КНОПКА ----------------
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(56, 56)
toggle.Position = UDim2.new(1, -72, 0, 16)
toggle.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
toggle.Text = "🛒"
toggle.TextSize = 28
toggle.Parent = gui
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 14)
tc.Parent = toggle

---------------- ОКНО ----------------
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(330, 280)
frame.Position = UDim2.new(1, -350, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 14)
fc.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🛒 Магазин улучшений"
title.TextColor3 = Color3.fromRGB(255, 220, 100)
title.TextSize = 20
title.Parent = frame

local rows = {}
for i, item in pairs(ITEMS) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 62)
    row.Position = UDim2.fromOffset(10, 44 + (i - 1) * 70)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    row.BorderSizePixel = 0
    row.Parent = frame
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 10)
    rc.Parent = row

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -100, 1, 0)
    info.Position = UDim2.fromOffset(10, 0)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.TextSize = 16
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = row

    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.fromOffset(80, 40)
    buyBtn.Position = UDim2.new(1, -90, 0.5, -20)
    buyBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 90)
    buyBtn.Text = "Купить"
    buyBtn.TextSize = 15
    buyBtn.Parent = row
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = buyBtn

    buyBtn.MouseButton1Click:Connect(function()
        shopEvent:FireServer(item.id)
    end)

    rows[item.id] = {info = info, btn = buyBtn, item = item}
end

toggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

---------------- ОБНОВЛЕНИЕ ЦЕН ----------------
task.spawn(function()
    while task.wait(0.25) do
        for _, row in pairs(rows) do
            local item = row.item
            local level = player:GetAttribute(item.attr) or 0
            local cost = item.base * (item.mult ^ level)
            if level >= item.max then
                row.info.Text = item.name .. " — ур. " .. level .. " (МАКС)"
                row.btn.Text = "МАКС"
                row.btn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
            else
                row.info.Text = item.name .. " — ур. " .. level .. " | Цена: 🦴 " .. cost
                row.btn.Text = "Купить"
                row.btn.BackgroundColor3 = Color3.fromRGB(80, 180, 90)
            end
        end
    end
end)

print("🛒 Интерфейс магазина загружен!")
