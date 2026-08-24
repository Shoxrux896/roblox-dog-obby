-- src/server/ServerScriptService/DayNight.server.lua
-- Плавная смена дня и ночи

local Lighting = game:GetService("Lighting")

if not Lighting:FindFirstChild("Atmosphere") then
    local atm = Instance.new("Atmosphere")
    atm.Density = 0.3
    atm.Parent = Lighting
end

-- Полный цикл дня и ночи ~2 минуты
while task.wait(0.1) do
    Lighting.ClockTime = (Lighting.ClockTime + 0.02) % 24
end
