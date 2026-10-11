--!strict
-- Platzhalter-Waffen zum Testen von Hotbar und Inventar.
-- Sie haben noch keine Funktion. Abschalten: Config.Debug.GiveTestWeapons = false
-- (wird in der Waffen-Etappe durch echte Waffen ersetzt).

local Players = game:GetService("Players")

local TestWeapons = {}

type WeaponDef = { name: string, color: Color3, size: Vector3 }

local DEFS: { WeaponDef } = {
	{ name = "Pistol", color = Color3.fromRGB(55, 55, 60), size = Vector3.new(0.35, 0.9, 1.3) },
	{ name = "Shotgun", color = Color3.fromRGB(95, 60, 35), size = Vector3.new(0.4, 0.6, 3.4) },
	{ name = "Machete", color = Color3.fromRGB(170, 170, 175), size = Vector3.new(0.12, 0.5, 2.6) },
}

local function makeTool(def: WeaponDef): Tool
	local tool = Instance.new("Tool")
	tool.Name = def.name
	tool.ToolTip = "Test item (no function yet)"
	tool.CanBeDropped = false
	tool:SetAttribute("TestItem", true)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = def.size
	handle.Color = def.color
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	return tool
end

local function give(player: Player)
	-- StarterGear: wird bei jedem Respawn automatisch ins Backpack kopiert
	local starterGear = player:WaitForChild("StarterGear", 10)
	if not starterGear then
		return
	end
	for _, def in DEFS do
		if not starterGear:FindFirstChild(def.name) then
			makeTool(def).Parent = starterGear
			-- Lebt der Character schon, die Waffe direkt ins Backpack legen
			local backpack = player:FindFirstChildOfClass("Backpack")
			if player.Character and backpack then
				makeTool(def).Parent = backpack
			end
		end
	end
end

function TestWeapons.init()
	Players.PlayerAdded:Connect(give)
	for _, player in Players:GetPlayers() do
		task.spawn(give, player)
	end
end

return TestWeapons
