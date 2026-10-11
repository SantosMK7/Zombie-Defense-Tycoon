--!strict
-- Erzeugt das Terrain: Mitte flach, außen sanft hügelig, überall Gras.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local W = Config.World
local RESOLUTION = 4 -- Voxelgröße von Roblox-Terrain
local CHUNK = 64 -- so viele Studs werden pro WriteVoxels-Aufruf geschrieben
local MIN_Y = -16 -- Unterkante des Terrains

local Terrain = {}

local function smoothstep(edge0: number, edge1: number, x: number): number
	local t = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
	return t * t * (3 - 2 * t)
end

-- Mehrere Lagen Rauschen übereinander = natürlich wirkende Hügel
local function fbm(x: number, z: number): number
	local total, amplitude, frequency, norm = 0, 1, 1, 0
	for octave = 1, 4 do
		total += math.noise(x * frequency, z * frequency, W.Seed * 0.013 + octave * 17.31) * amplitude
		norm += amplitude
		amplitude *= 0.5
		frequency *= 2
	end
	return total / norm -- ungefähr -0.5 … 0.5
end

-- Höhe der Oberfläche an Position (x, z). Wird auch für Bäume, Steine usw. genutzt.
function Terrain.getHeight(x: number, z: number): number
	local r = math.sqrt(x * x + z * z)
	local blend = smoothstep(W.FlatRadius, W.FlatRadius + W.TransitionWidth, r)
	if blend <= 0 then
		return 0
	end

	local n = fbm(x / W.HillScale, z / W.HillScale)
	local hills = math.max(-1, (n + 0.5) * W.HillHeight)
	local edge = smoothstep(W.EdgeRiseStart, W.MapSize / 2, r) * W.EdgeRise
	return blend * (hills + edge)
end

function Terrain.build()
	local terrain = workspace.Terrain
	terrain:Clear()
	terrain:SetMaterialColor(Enum.Material.Grass, W.GrassColor)
	terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(92, 66, 48))

	-- Gras-Halme (wie im Referenzbild). Ist in manchen Studio-Versionen nicht per Skript setzbar,
	-- dann einmal manuell: Explorer → Workspace → Terrain → Eigenschaft „Decoration" anhaken.
	local ok = pcall(function()
		(terrain :: any).Decoration = true
	end)
	if not ok then
		warn("[Welt] Terrain.Decoration konnte nicht gesetzt werden – bitte in Studio manuell anhaken.")
	end

	local half = W.MapSize / 2
	local maxY = math.ceil((W.HillHeight + W.EdgeRise + 8) / RESOLUTION) * RESOLUTION
	local ny = (maxY - MIN_Y) // RESOLUTION
	local cols = CHUNK // RESOLUTION

	for cx = -half, half - CHUNK, CHUNK do
		for cz = -half, half - CHUNK, CHUNK do
			local materials: { { { Enum.Material } } } = {}
			local occupancies: { { { number } } } = {}

			for ix = 1, cols do
				local matX: { { Enum.Material } } = {}
				local occX: { { number } } = {}
				for iy = 1, ny do
					matX[iy] = {}
					occX[iy] = {}
				end

				for iz = 1, cols do
					local wx = cx + (ix - 0.5) * RESOLUTION
					local wz = cz + (iz - 0.5) * RESOLUTION
					local h = Terrain.getHeight(wx, wz)

					for iy = 1, ny do
						local bottom = MIN_Y + (iy - 1) * RESOLUTION
						local occ = math.clamp((h - bottom) / RESOLUTION, 0, 1)
						local material = Enum.Material.Air
						if occ > 0 then
							-- oben Gras, tief unten Fels
							material = if h - bottom > 10 then Enum.Material.Rock else Enum.Material.Grass
						end
						matX[iy][iz] = material
						occX[iy][iz] = occ
					end
				end

				materials[ix] = matX
				occupancies[ix] = occX
			end

			local region = Region3.new(Vector3.new(cx, MIN_Y, cz), Vector3.new(cx + CHUNK, maxY, cz + CHUNK))
			terrain:WriteVoxels(region, RESOLUTION, materials, occupancies)
		end
		task.wait() -- Server nicht einfrieren
	end

	-- Kleiner Erdfleck rund ums Lagerfeuer
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, 9, Enum.Material.Ground)
end

return Terrain
