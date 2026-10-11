--!strict
-- Camp in der flachen Mitte: Zelt, Lagerfeuer, Sitzstämme, Laternen und Spawnpunkt.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartUtil = require(script.Parent.PartUtil)

local W = Config.World
local UPRIGHT = PartUtil.UPRIGHT

local WOOD = Color3.fromRGB(86, 60, 40)
local DARK_WOOD = Color3.fromRGB(58, 40, 28)
local STONE = Color3.fromRGB(105, 105, 110)
local LAMP = Color3.fromRGB(255, 214, 130)

local Camp = {}

local function buildCampfire(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "Lagerfeuer"

	-- Steinring
	for i = 1, 10 do
		local a = (i / 10) * math.pi * 2
		PartUtil.part(model, {
			Name = "Stein",
			Size = Vector3.new(1.4, 0.9, 1.1),
			CFrame = CFrame.new(math.cos(a) * 2.7, 0.35, math.sin(a) * 2.7) * CFrame.Angles(0, -a, 0.15),
			Color = STONE,
			Material = Enum.Material.Slate,
		})
	end

	-- Holzscheite als kleines Zelt (Tipi)
	for i = 1, 4 do
		local a = (i / 4) * math.pi * 2
		local cf = CFrame.new(0, 1.1, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0.7, 0, 0) * CFrame.Angles(0, 0, math.rad(35))
		PartUtil.part(model, {
			Name = "Scheit",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(3, 0.55, 0.55),
			CFrame = cf * UPRIGHT,
			Color = DARK_WOOD,
			Material = Enum.Material.Wood,
			CanCollide = false,
		})
	end

	-- Glut + Feuer + Licht
	local embers = PartUtil.part(model, {
		Name = "Glut",
		Size = Vector3.new(2, 0.3, 2),
		CFrame = CFrame.new(0, 0.2, 0),
		Color = Color3.fromRGB(255, 110, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})

	local fire = Instance.new("Fire")
	fire.Size = 6
	fire.Heat = 9
	fire.Color = Color3.fromRGB(255, 120, 40)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 80)
	fire.Parent = embers

	local smoke = Instance.new("Smoke")
	smoke.Color = Color3.fromRGB(70, 70, 75)
	smoke.Opacity = 0.08
	smoke.RiseVelocity = 4
	smoke.Size = 3
	smoke.Parent = embers

	local light = Instance.new("PointLight")
	light.Name = "FeuerLicht" -- der Client lässt dieses Licht flackern
	light.Color = Color3.fromRGB(255, 150, 70)
	light.Brightness = 2.5
	light.Range = 30
	light.Shadows = true
	light.Parent = embers

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Funken"
	sparks.Color = ColorSequence.new(Color3.fromRGB(255, 170, 60))
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.12, 0)
	sparks.Lifetime = NumberRange.new(1, 2.5)
	sparks.Rate = 8
	sparks.Speed = NumberRange.new(4, 8)
	sparks.SpreadAngle = Vector2.new(20, 20)
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.Acceleration = Vector3.new(0, 1, 0)
	sparks.Parent = embers

	-- Sitzstämme
	for _, info in { { pos = Vector3.new(0, 0.7, 7), rot = 0 }, { pos = Vector3.new(6.5, 0.7, -3), rot = 65 } } do
		PartUtil.part(model, {
			Name = "Sitzstamm",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(6, 1.5, 1.5),
			CFrame = CFrame.new(info.pos) * CFrame.Angles(0, math.rad(info.rot), 0),
			Color = WOOD,
			Material = Enum.Material.Wood,
		})
	end

	model.Parent = parent
end

-- Satteldach-Zelt aus zwei Keilen. Eingang zeigt in lokale +X-Richtung.
local function buildTent(parent: Instance, cf: CFrame)
	local model = Instance.new("Model")
	model.Name = "Zelt"

	local length, height, width = 12, 7, 10
	local fabric = Color3.fromRGB(96, 104, 64)

	PartUtil.part(model, {
		Name = "Boden",
		Size = Vector3.new(length + 1, 0.2, width + 1),
		CFrame = cf * CFrame.new(0, 0.1, 0),
		Color = Color3.fromRGB(60, 55, 45),
		Material = Enum.Material.Fabric,
	})

	-- zwei Keile Rücken an Rücken = Dreiecksprisma
	PartUtil.wedge(model, "Plane1", Vector3.new(length, height, width / 2), cf * CFrame.new(0, height / 2, -width / 4), fabric, Enum.Material.Fabric)
	PartUtil.wedge(model, "Plane2", Vector3.new(length, height, width / 2), cf * CFrame.new(0, height / 2, width / 4) * CFrame.Angles(0, math.pi, 0), fabric, Enum.Material.Fabric)

	-- dunkle Eingangsöffnung
	local doorH, doorW = height * 0.6, width * 0.36
	local dark = Color3.fromRGB(15, 15, 15)
	local doorX = length / 2 + 0.06
	PartUtil.wedge(model, "Eingang1", Vector3.new(0.1, doorH, doorW / 2), cf * CFrame.new(doorX, doorH / 2 + 0.2, -doorW / 4), dark, Enum.Material.Fabric)
	PartUtil.wedge(model, "Eingang2", Vector3.new(0.1, doorH, doorW / 2), cf * CFrame.new(doorX, doorH / 2 + 0.2, doorW / 4) * CFrame.Angles(0, math.pi, 0), dark, Enum.Material.Fabric)

	-- Firststange
	PartUtil.part(model, {
		Name = "Stange",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(length + 1.5, 0.35, 0.35),
		CFrame = cf * CFrame.new(0, height + 0.1, 0),
		Color = DARK_WOOD,
		Material = Enum.Material.Wood,
		CanCollide = false,
	})

	model.Parent = parent
end

local function buildLantern(parent: Instance, position: Vector3)
	local model = Instance.new("Model")
	model.Name = "Laterne"

	PartUtil.part(model, {
		Name = "Pfahl",
		Size = Vector3.new(0.6, 7, 0.6),
		CFrame = CFrame.new(position + Vector3.new(0, 3.5, 0)),
		Color = DARK_WOOD,
		Material = Enum.Material.Wood,
	})

	local lamp = PartUtil.part(model, {
		Name = "Lampe",
		Size = Vector3.new(1.2, 1.2, 1.2),
		CFrame = CFrame.new(position + Vector3.new(0, 7.4, 0)),
		Color = LAMP,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})

	local light = Instance.new("PointLight")
	light.Color = LAMP
	light.Brightness = 1.6
	light.Range = 24
	light.Parent = lamp

	model.Parent = parent
end

function Camp.build(root: Instance)
	local camp = Instance.new("Folder")
	camp.Name = "Camp"
	camp.Parent = root

	buildCampfire(camp)

	-- Zelt westlich vom Feuer, Eingang zeigt zum Feuer
	local tentPos = Vector3.new(-13, 0, -5)
	local tentCf = CFrame.lookAt(tentPos, Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.rad(90), 0)
	buildTent(camp, tentCf)

	-- Laternen im Kreis um das Camp
	for i = 1, W.LanternCount do
		local a = (i / W.LanternCount) * math.pi * 2 + math.rad(15)
		buildLantern(camp, Vector3.new(math.cos(a) * W.LanternRadius, 0, math.sin(a) * W.LanternRadius))
	end

	-- Spawnpunkt südlich vom Feuer (unsichtbar)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(0, 0.5, 16)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.CastShadow = false
	spawn.Duration = 0 -- kein Schutzschild-Effekt
	local decal = spawn:FindFirstChildOfClass("Decal")
	if decal then
		decal:Destroy()
	end
	spawn.Parent = camp
end

return Camp
