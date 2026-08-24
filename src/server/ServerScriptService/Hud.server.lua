-- src/server/ServerScriptService/Hud.server.lua
-- Следит за прогрессом и шлет уведомления на клиент

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local notifyEvent = Instance.new("RemoteEvent")
notifyEvent.Name = "NotifyEvent"
notifyEvent.Parent = ReplicatedStorage

local lastValues = {}
local joinTime = {}

local function notify(player, text)
    notifyEvent:FireClient(player, text)
end

local function hookLeaderstats(player, ls)
    local bones = ls:WaitForChild("Bones", 10)
    local stage = ls:WaitForChild("Stage", 10)
    if not bones or not stage then return end

    lastValues[player.UserId] = {bones = bones.Value, stage = stage.Value}

    bones.Changed:Connect(function(v)
        local lv = lastValues[player.UserId]
        local fresh = (os.clock() - (joinTime[player.UserId] or 0)) < 2
        if lv and v > lv.bones and not fresh then
            notify(player, "🦴 +" .. (v - lv.bones) .. "! Всего: " .. v)
        end
        if lv then lv.bones = v end
    end)

    stage.Changed:Connect(function(v)
        local lv = lastValues[player.UserId]
        local fresh = (os.clock() - (joinTime[player.UserId] or 0)) < 2
        if lv and v > lv.stage and not fresh then
            if v == 99 then
                notify(player, "🏆 ПОБЕДА! Obby пройден!")
            else
                notify(player, "🚩 Чекпоинт " .. (v - 1) .. " открыт!")
            end
        end
        if lv then lv.stage = v end
    end)
end

local function watchPlayer(player)
    joinTime[player.UserId] = os.clock()

    player:GetAttributeChangedSignal("SpeedBonus"):Connect(function()
        local bonus = player:GetAttribute("SpeedBonus") or 0
        if bonus > 0 and (os.clock() - joinTime[player.UserId]) > 2 then
            notify(player, "⚡ Скорость повышена! +" .. bonus)
        end
    end)

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        hookLeaderstats(player, ls)
    else
        player.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                hookLeaderstats(player, child)
            end
        end)
    end
end

Players.PlayerAdded:Connect(watchPlayer)
for _, pl in pairs(Players:GetPlayers()) do
    watchPlayer(pl)
end

print("🖥️ HUD-наблюдатель запущен!")
