--!strict
-- Wald in der Ferne, einzelne Bäume, Steine und Glühwürmchen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Terrain = require(script.Parent.Terrain)
local PartUtil = require(script.Parent.PartUtil)

local W = Config.World
local UPRIGHT = PartUtil.UPRIGHT

local TRUNK_COLOR = Color3.fromRGB(68, 48, 34)
local PINE_COLORS = { Color3.fromRGB(28, 56, 34), Color3.fromRGB(34, 64, 38), Color3.fromRGB(24, 48, 30) }
local LEAF_COLORS = { Color3.fromRGB(42, 74, 40), Color3.fromRGB(50, 82, 42), Color3.fromRGB(36, 64, 36) }

local Forest = {}

-- Nadelbaum: Stamm + gestapelte, nach oben kleiner werdende Etagen
local function pine(parent: Instance, base: Vector3, s: number, rng: Random)
	local model = Instance.new("Model")
	model.Name = "Tanne"
	local trunkH = 14 * s
	PartUtil.part(model, {
		Name = "Stamm",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(trunkH, 1.6 * s, 1.6 * s),
		CFrame = CFrame.new(base + Vector3.new(0, trunkH / 2, 0)) * UPRIGHT,
		Color = TRUNK_COLOR,
		Material = Enum.Material.Wood,
	})

	local color = PINE_COLORS[rng:NextInteger(1, #PINE_COLORS)]
	local tiers = { 13, 11, 8.5, 6, 3.5 }
	local tierH = 4 * s
	local y = 4.5 * s
	for i, diameter in tiers do
		PartUtil.part(model, {
			Name = "Nadeln" .. i,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(tierH, diameter * s, diameter * s),
			CFrame = CFrame.new(base + Vector3.new(0, y + tierH / 2, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), 0) * UPRIGHT,
			Color = color,
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
		y += tierH * 0.8
	end
	model.Parent = parent
end

-- Laubbaum: Stamm + mehrere Kugeln als Krone
local function leafy(parent: Instance, base: Vector3, s: number, rng: Random)
	local model = Instance.new("Model")
	model.Name = "Laubbaum"
	local trunkH = 12 * s
	PartUtil.part(model, {
		Name = "Stamm",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(trunkH, 2 * s, 2 * s),
		CFrame = CFrame.new(base + Vector3.new(0, trunkH / 2, 0)) * UPRIGHT,
		Color = TRUNK_COLOR,
		Material = Enum.Material.Wood,
	})

	local color = LEAF_COLORS[rng:NextInteger(1, #LEAF_COLORS)]
	for i = 1, rng:NextInteger(3, 5) do
		local d = rng:NextNumber(8, 13) * s
		local offset = Vector3.new(rng:NextNumber(-4, 4) * s, trunkH + rng:NextNumber(-1, 4) * s, rng:NextNumber(-4, 4) * s)
		PartUtil.part(model, {
			Name = "Krone" .. i,
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(d, d, d),
			CFrame = CFrame.new(base + offset),
			Color = color,
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
	model.Parent = parent
end

local function randomPointInRing(rng: Random, inner: number, outer: number): (number, number)
	local angle = rng:NextNumber(0, math.pi * 2)
	-- sqrt sorgt für gleichmäßige Verteilung auf der Fläche
	local r = math.sqrt(rng:NextNumber(inner * inner, outer * outer))
	return math.cos(angle) * r, math.sin(angle) * r
end

local function placeTree(parent: Instance, rng: Random, x: number, z: number, scale: number)
	local base = Vector3.new(x, Terrain.getHeight(x, z) - 0.6, z)
	if rng:NextNumber() < 0.7 then
		pine(parent, base, scale, rng)
	else
		leafy(parent, base, scale, rng)
	end
end

function Forest.build(root: Instance)
	local rng = Random.new(W.Seed)

	local trees = Instance.new("Folder")
	trees.Name = "Wald"
	trees.Parent = root

	-- dichter Wald in der Ferne
	for i = 1, W.ForestTreeCount do
		local x, z = randomPointInRing(rng, W.ForestInnerRadius, W.ForestOuterRadius)
		placeTree(trees, rng, x, z, rng:NextNumber(0.9, 1.7))
		if i % 100 == 0 then
			task.wait()
		end
	end

	-- vereinzelte Bäume näher an der Lichtung
	for _ = 1, W.ScatterTreeCount do
		local x, z = randomPointInRing(rng, W.ScatterInnerRadius, W.ForestInnerRadius)
		placeTree(trees, rng, x, z, rng:NextNumber(0.8, 1.3))
	end

	-- Steine
	local rocks = Instance.new("Folder")
	rocks.Name = "Steine"
	rocks.Parent = root
	for _ = 1, W.RockCount do
		local x, z = randomPointInRing(rng, W.FlatRadius + 20, W.ForestOuterRadius)
		local size = Vector3.new(rng:NextNumber(2, 6), rng:NextNumber(1.5, 4), rng:NextNumber(2, 6))
		PartUtil.part(rocks, {
			Name = "Stein",
			Size = size,
			CFrame = CFrame.new(x, Terrain.getHeight(x, z) + size.Y * 0.2, z)
				* CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, math.pi * 2), rng:NextNumber(-0.3, 0.3)),
			Color = Color3.fromRGB(95, 95, 100),
			Material = Enum.Material.Rock,
		})
	end

	-- Glühwürmchen über der Wiese
	local fireflies = Instance.new("Folder")
	fireflies.Name = "Gluehwuermchen"
	fireflies.Parent = root
	for _ = 1, W.FireflyCount do
		local x, z = randomPointInRing(rng, 25, 260)
		local area = PartUtil.part(fireflies, {
			Name = "Bereich",
			Size = Vector3.new(50, 6, 50),
			CFrame = CFrame.new(x, Terrain.getHeight(x, z) + 3, z),
			Color = Color3.new(1, 1, 1),
			Transparency = 1,
			CanCollide = false,
			CastShadow = false,
		})
		area.CanQuery = false
		area.CanTouch = false

		local emitter = Instance.new("ParticleEmitter")
		emitter.Shape = Enum.ParticleEmitterShape.Box
		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		emitter.Color = ColorSequence.new(Color3.fromRGB(210, 255, 120))
		emitter.LightEmission = 1
		emitter.Brightness = 3
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.18),
			NumberSequenceKeypoint.new(0.8, 0.18),
			NumberSequenceKeypoint.new(1, 0),
		})
		emitter.Lifetime = NumberRange.new(4, 8)
		emitter.Rate = 2.5
		emitter.Speed = NumberRange.new(0.3, 1)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.RotSpeed = NumberRange.new(0, 0)
		emitter.Parent = area
	end
end

return Forest
