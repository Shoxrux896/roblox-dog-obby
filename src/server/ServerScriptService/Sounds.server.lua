-- src/server/ServerScriptService/Sounds.server.lua
-- Звуки: лай, подбор, чекпоинт, победа

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SOUNDS = {
    Bark = "rbxassetid://5302725289",
    Collect = "rbxassetid://130762736",
}

local barkEvent = Instance.new("RemoteEvent")
barkEvent.Name = "BarkEvent"
barkEvent.Parent = ReplicatedStorage

local function playSoundAt(character, id, speed, volume)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local s = Instance.new("Sound")
    s.SoundId = id
    s.PlaybackSpeed = speed or 1
    s.Volume = volume or 0.7
    s.Parent = root
    s:Play()
    task.delay(3, function()
        s:Destroy()
    end)
end

local function showBarkBubble(character)
    if not character then return end
    local dog = character:FindFirstChild("DogModel")
    local head = (dog and dog:FindFirstChild("Head")) or character:FindFirstChild("HumanoidRootPart")
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.fromOffset(120, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.Adornee = head
    bill.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Гав! 🐶"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.TextScaled = true
    label.Parent = bill
    bill.Parent = character
    task.delay(0.9, function()
        bill:Destroy()
    end)
end

barkEvent.OnServerEvent:Connect(function(player)
    showBarkBubble(player.Character)
    playSoundAt(player.Character, SOUNDS.Bark, 1, 0.9)
end)

local function watch(player)
    local function hook(ls)
        local bones = ls:WaitForChild("Bones", 10)
        local stage = ls:WaitForChild("Stage", 10)
        if bones then
            bones.Changed:Connect(function()
                playSoundAt(player.Character, SOUNDS.Collect, 1.1, 0.6)
            end)
        end
        if stage then
            stage.Changed:Connect(function(v)
                if v == 99 then
                    for i = 1, 3 do
                        task.delay((i - 1) * 0.15, function()
                            playSoundAt(player.Character, SOUNDS.Collect, 0.9 + i * 0.2, 0.7)
                        end)
                    end
                elseif v > 1 then
                    playSoundAt(player.Character, SOUNDS.Collect, 0.8, 0.7)
                end
            end)
        end
    end
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        hook(ls)
    else
        player.ChildAdded:Connect(function(c)
            if c.Name == "leaderstats" then hook(c) end
        end)
    end
end

Players.PlayerAdded:Connect(watch)
for _, pl in pairs(Players:GetPlayers()) do
    watch(pl)
end
print("🔊 Звуки подключены!")
