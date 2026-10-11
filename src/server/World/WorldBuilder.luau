--!strict
-- Baut die komplette Welt beim Serverstart.

local NightLighting = require(script.Parent.NightLighting)
local Terrain = require(script.Parent.Terrain)
local Forest = require(script.Parent.Forest)
local Camp = require(script.Parent.Camp)

local WorldBuilder = {}

function WorldBuilder.build()
	local started = os.clock()

	-- Standard-Teile aus einer neuen Studio-Vorlage entfernen
	for _, name in { "Baseplate", "SpawnLocation" } do
		local old = workspace:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end

	local old = workspace:FindFirstChild("Welt")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "Welt"
	root.Parent = workspace

	NightLighting.apply()
	Terrain.build()
	Camp.build(root)
	Forest.build(root)

	print(string.format("[Welt] fertig gebaut in %.1f s", os.clock() - started))
end

return WorldBuilder
