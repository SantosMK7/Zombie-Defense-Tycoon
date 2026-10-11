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
	local rng = Random.new(W.Seed + 7)

	-- Ascheboden
	PartUtil.part(model, {
		Name = "Asche",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.2, 7.5, 7.5),
		CFrame = CFrame.new(0, 0.1, 0) * UPRIGHT,
		Color = Color3.fromRGB(42, 36, 33),
		Material = Enum.Material.Slate,
		CanCollide = false,
	})

	-- Steinring
	local stoneCount = 14
	for i = 1, stoneCount do
		local a = (i / stoneCount) * math.pi * 2
		local size = Vector3.new(rng:NextNumber(1.8, 2.4), rng:NextNumber(1.2, 1.7), rng:NextNumber(1.5, 2))
		local shade = rng:NextInteger(85, 120)
		PartUtil.part(model, {
			Name = "Stein",
			Size = size,
			CFrame = CFrame.new(math.cos(a) * 4, size.Y * 0.4, math.sin(a) * 4)
				* CFrame.Angles(rng:NextNumber(-0.2, 0.2), -a + rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.2, 0.2)),
			Color = Color3.fromRGB(shade, shade, shade + 5),
			Material = Enum.Material.Slate,
		})
	end

	-- Holzscheite als Tipi
	local logCount = 6
	for i = 1, logCount do
		local a = (i / logCount) * math.pi * 2
		local cf = CFrame.new(0, 1.9, 0) * CFrame.Angles(0, a, 0) * CFrame.new(1.1, 0, 0) * CFrame.Angles(0, 0, math.rad(30))
		PartUtil.part(model, {
			Name = "Scheit",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(5, 0.8, 0.8),
			CFrame = cf * UPRIGHT,
			Color = DARK_WOOD,
			Material = Enum.Material.Wood,
			CanCollide = false,
		})
	end

	-- Glut + Feuer + Licht
	local embers = PartUtil.part(model, {
		Name = "Glut",
		Size = Vector3.new(3, 0.5, 3),
		CFrame = CFrame.new(0, 0.3, 0),
		Color = Color3.fromRGB(255, 110, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})

	local fire = Instance.new("Fire")
	fire.Size = 9
	fire.Heat = 12
	fire.Color = Color3.fromRGB(255, 110, 35)
	fire.SecondaryColor = Color3.fromRGB(255, 205, 80)
	fire.Parent = embers

	local smoke = Instance.new("Smoke")
	smoke.Color = Color3.fromRGB(70, 70, 75)
	smoke.Opacity = 0.1
	smoke.RiseVelocity = 5
	smoke.Size = 4
	smoke.Parent = embers

	local light = Instance.new("PointLight")
	light.Name = "FeuerLicht" -- der Client lässt dieses Licht flackern
	light.Color = Color3.fromRGB(255, 145, 65)
	light.Brightness = 3
	light.Range = 40
	light.Shadows = true
	light.Parent = embers

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Funken"
	sparks.Color = ColorSequence.new(Color3.fromRGB(255, 170, 60))
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.18, 0)
	sparks.Lifetime = NumberRange.new(1.5, 3)
	sparks.Rate = 15
	sparks.Speed = NumberRange.new(5, 10)
	sparks.SpreadAngle = Vector2.new(25, 25)
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.Acceleration = Vector3.new(0, 1, 0)
	sparks.Parent = embers

	-- Sitzstämme im Kreis (zeigen tangential zum Feuer)
	for _, deg in { 60, 330, 125 } do
		local a = math.rad(deg)
		PartUtil.part(model, {
			Name = "Sitzstamm",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(6.5, 1.8, 1.8),
			CFrame = CFrame.new(math.cos(a) * 8.5, 0.85, math.sin(a) * 8.5) * CFrame.Angles(0, -a - math.pi / 2, 0),
			Color = WOOD,
			Material = Enum.Material.Wood,
		})
	end

	-- Brennholzstapel
	for row = 0, 2 do
		local count = 3 - row
		for i = 1, count do
			PartUtil.part(model, {
				Name = "Brennholz",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(4, 0.9, 0.9),
				CFrame = CFrame.new(7.5, 0.45 + row * 0.8, -6.5 + (i - (count + 1) / 2) * 0.95),
				Color = if (i + row) % 2 == 0 then WOOD else DARK_WOOD,
				Material = Enum.Material.Wood,
			})
		end
	end

	model.Parent = parent
end

-- Satteldach-Zelt aus zwei Keilen. Eingang zeigt in lokale +X-Richtung.
local function buildTent(parent: Instance, cf: CFrame)
	local model = Instance.new("Model")
	model.Name = "Zelt"

	local length, height, width = 16, 9.5, 13
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

	-- Erde statt Gras rund um Feuer und Zelt (Ground hat keine Grashalme)
	local terrain = workspace.Terrain
	local tentPos = Vector3.new(-17, 0, -6)
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, 12, Enum.Material.Ground)
	terrain:FillCylinder(CFrame.new(tentPos.X, -2, tentPos.Z), 4, 11, Enum.Material.Ground)

	buildCampfire(camp)

	-- Zelt westlich vom Feuer, Eingang zeigt zum Feuer
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
