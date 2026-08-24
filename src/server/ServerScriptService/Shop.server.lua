-- src/server/ServerScriptService/Shop.server.lua
-- Магазин улучшений + магнит косточек + сохранение покупок

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("DogObbyShop_v1")
local bonesFolder = workspace:WaitForChild("BonesFolder", 60)

local notifyEvent = ReplicatedStorage:WaitForChild("NotifyEvent", 30)
local shopEvent = Instance.new("RemoteEvent")
shopEvent.Name = "ShopEvent"
shopEvent.Parent = ReplicatedStorage

local ITEMS = {
    Speed = {name = "⚡ Скорость", attr = "ShopSpeed", base = 10, mult = 2, max = 5},
    Jump = {name = "🦘 Прыжок", attr = "ShopJump", base = 15, mult = 2, max = 5},
    Magnet = {name = "🧲 Магнит", attr = "ShopMagnet", base = 25, mult = 3, max = 3},
}

local MAGNET_RADIUS = {[0] = 0, [1] = 8, [2] = 12, [3] = 16}

local function costOf(item, level)
    return item.base * (item.mult ^ level)
end

local function notify(player, text)
    notifyEvent:FireClient(player, text)
end

local function getHumanoid(player)
    return player.Character and player.Character:FindFirstChild("Humanoid")
end

local function applySpeed(player)
    local humanoid = getHumanoid(player)
    if humanoid then
        humanoid.WalkSpeed = 20
            + (player:GetAttribute("SpeedBonus") or 0)
            + 2 * (player:GetAttribute("ShopSpeed") or 0)
    end
end

local function applyJump(player)
    local humanoid = getHumanoid(player)
    if humanoid then
        humanoid.JumpPower = 50 + 10 * (player:GetAttribute("ShopJump") or 0)
    end
end

---------------- ПОКУПКА ----------------
local function buy(player, itemId)
    local item = ITEMS[itemId]
    if not item then return end

    local level = player:GetAttribute(item.attr) or 0
    if level >= item.max then
        notify(player, "❌ " .. item.name .. " уже на максимуме!")
        return
    end

    local cost = costOf(item, level)
    local ls = player:FindFirstChild("leaderstats")
    local bones = ls and ls:FindFirstChild("Bones")
    if not bones or bones.Value < cost then
        notify(player, "❌ Не хватает косточек! Нужно: " .. cost)
        return
    end

    bones.Value = bones.Value - cost
    player:SetAttribute(item.attr, level + 1)
    applySpeed(player)
    applyJump(player)
    notify(player, "✅ Куплено: " .. item.name .. " (ур. " .. (level + 1) .. ")")
    print("🛒 " .. player.Name .. " купил " .. item.name .. " ур. " .. (level + 1))
end

shopEvent.OnServerEvent:Connect(function(player, itemId)
    buy(player, itemId)
end)

---------------- СОХРАНЕНИЕ ПОКУПОК ----------------
local function saveShop(player)
    pcall(function()
        store:SetAsync(player.UserId, {
            S = player:GetAttribute("ShopSpeed") or 0,
            J = player:GetAttribute("ShopJump") or 0,
            M = player:GetAttribute("ShopMagnet") or 0,
        })
    end)
end

local function loadShop(player)
    local ok, data = pcall(function()
        return store:GetAsync(player.UserId)
    end)
    if ok and type(data) == "table" then
        player:SetAttribute("ShopSpeed", data.S or 0)
        player:SetAttribute("ShopJump", data.J or 0)
        player:SetAttribute("ShopMagnet", data.M or 0)
    end
end

Players.PlayerAdded:Connect(function(player)
    loadShop(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.15)
        applySpeed(player)
        applyJump(player)
    end)
end)

Players.PlayerRemoving:Connect(saveShop)

task.spawn(function()
    while task.wait(30) do
        for _, player in pairs(Players:GetPlayers()) do
            saveShop(player)
        end
    end
end)

game:BindToClose(function()
    for _, player in pairs(Players:GetPlayers()) do
        saveShop(player)
    end
end)

---------------- МАГНИТ ----------------
RunService.Heartbeat:Connect(function(dt)
    for _, player in pairs(Players:GetPlayers()) do
        local radius = MAGNET_RADIUS[player:GetAttribute("ShopMagnet") or 0] or 0
        if radius > 0 and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, bone in pairs(bonesFolder:GetChildren()) do
                    local primary = bone.PrimaryPart
                    if primary then
                        local dist = (primary.Position - root.Position).Magnitude
                        if dist < radius and dist > 1 then
                            local dir = (root.Position - primary.Position).Unit
                            bone:SetPrimaryPartCFrame(primary.CFrame + dir * math.min(30 * dt, dist))
                        end
                    end
                end
            end
        end
    end
end)

print("🛒 Магазин открыт!")
