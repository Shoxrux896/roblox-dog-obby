-- src/client/StarterPlayer/StarterPlayerScripts/Bark.client.lua
-- Клавиша F = гав!

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local barkEvent = ReplicatedStorage:WaitForChild("BarkEvent", 30)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        barkEvent:FireServer()
    end
end)

print("🔊 Лай на клавише F готов!")