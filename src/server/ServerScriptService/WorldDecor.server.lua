-- src/server/ServerScriptService/WorldDecor.server.lua
-- Украшаем мир: вода, деревья, цветы, будка, фонари, облака

local Lighting = game:GetService("Lighting")

-- Убираем серую пустоту
local base = workspace:FindFirstChild("Baseplate")
if base then
    base:Destroy()
end

-- Вода внизу
local water = Instance.new("Part")
water.Name = "Water"
water.Size = Vector3.new(600, 2, 600)
water.Position = Vector3.new(0, -6, 0)
water.Anchored = true
water.CanCollide = false
water.Material = Enum.Material.Water
water.Color = Color3.fromRGB(30, 90, 160)
water.Transparency = 0.1
water.Parent = workspace

-- Атмосфера
Lighting.FogEnd = 700
Lighting.FogStart = 150
Lighting.FogColor = Color3.fromRGB(180, 210, 235)
Lighting.Ambient = Color3.fromRGB(120, 120, 130)

pcall(function()
    local clouds = Instance.new("Clouds")
    clouds.Cover = 0.3
    clouds.Density = 0.5
    clouds.Parent = Lighting
end)

local decor = Instance.new("Folder")
decor.Name = "Decor"
decor.Parent = workspace

local TOP = 3.5

local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.Parent = decor
    return p
end

local function makeTree(x, z)
    part("Trunk", Vector3.new(0.8, 4, 0.8), Vector3.new(x, TOP + 2, z),
        Color3.fromRGB(100, 70, 40), Enum.Material.Wood)
    part("Leaf1", Vector3.new(3.5, 2.5, 3.5), Vector3.new(x, TOP + 5, z),
        Color3.fromRGB(40, 140, 60), Enum.Material.Grass)
    part("Leaf2", Vector3.new(2.2, 2, 2.2), Vector3.new(x, TOP + 6.8, z),
        Color3.fromRGB(60, 170, 80), Enum.Material.Grass)
end

local function makeRock(x, z, s)
    local r = part("Rock", Vector3.new(s, s, s), Vector3.new(x, TOP + s / 2 - 0.2, z),
        Color3.fromRGB(120, 120, 125), Enum.Material.Slate)
    r.Shape = Enum.PartType.Ball
end

local function makeFlower(x, z)
    local colors = {
        Color3.fromRGB(255, 90, 90),
        Color3.fromRGB(255, 220, 90),
        Color3.fromRGB(255, 140, 220),
        Color3.fromRGB(140, 120, 255),
    }
    part("Stem", Vector3.new(0.1, 0.7, 0.1), Vector3.new(x, TOP + 0.35, z),
        Color3.fromRGB(50, 150, 60))
    local head = part("FlowerHead", Vector3.new(0.35, 0.35, 0.35),
        Vector3.new(x, TOP + 0.8, z), colors[math.random(1, #colors)])
    head.Shape = Enum.PartType.Ball
end

local function makeLamp(x, z)
    part("Pole", Vector3.new(0.3, 5, 0.3), Vector3.new(x, TOP + 2.5, z),
        Color3.fromRGB(50, 50, 55), Enum.Material.Metal)
    local bulb = part("Bulb", Vector3.new(0.8, 0.8, 0.8), Vector3.new(x, TOP + 5.2, z),
        Color3.fromRGB(255, 230, 150), Enum.Material.Neon)
    bulb.Shape = Enum.PartType.Ball
    local light = Instance.new("PointLight")
    light.Range = 18
    light.Brightness = 1.5
    light.Color = Color3.fromRGB(255, 220, 140)
    light.Parent = bulb
end

-- Деревья по углам и краям
makeTree(-8, -8)
makeTree(8, -8)
makeTree(-8, 7)
makeTree(8, 7)
makeTree(-8, 0)
makeTree(8, 0)

-- Камни
makeRock(-5, -3, 1.4)
makeRock(5, -6, 1.8)
makeRock(3, 7, 1.2)
makeRock(-6, 5, 1.6)

-- Цветы
for i = 1, 14 do
    makeFlower(math.random(-9, 9), math.random(-9, 9))
end

-- Будка собаки
local house = part("DogHouse", Vector3.new(3, 2.5, 3), Vector3.new(-4, TOP + 1.25, 4),
    Color3.fromRGB(150, 90, 50), Enum.Material.Wood)
local roof = part("DogHouseRoof", Vector3.new(3.6, 0.4, 3.6), Vector3.new(-4, TOP + 2.7, 4),
    Color3.fromRGB(180, 60, 50))
local entrance = part("DogHouseDoor", Vector3.new(1.2, 1.4, 0.2), Vector3.new(-4, TOP + 0.7, 5.5),
    Color3.fromRGB(25, 20, 20))

-- Фонари по углам
makeLamp(-9, -9)
makeLamp(9, -9)
makeLamp(-9, 9)
makeLamp(9, 9)

print("🌍 Мир украшен!")
