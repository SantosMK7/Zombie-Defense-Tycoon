--!strict
-- Lässt das Licht des Lagerfeuers flackern (nur Optik, daher auf dem Client).

local RunService = game:GetService("RunService")

local welt = workspace:WaitForChild("Welt")
local camp = welt:WaitForChild("Camp")
local fire = camp:WaitForChild("Lagerfeuer")
local embers = fire:WaitForChild("Glut")
local light = embers:WaitForChild("FeuerLicht") :: PointLight

local baseBrightness = light.Brightness
local baseRange = light.Range
local t = 0

RunService.RenderStepped:Connect(function(dt)
	t += dt
	local flicker = math.noise(t * 3.1, 0.5) + math.noise(t * 7.3, 2.5) * 0.5
	light.Brightness = baseBrightness + flicker * 1.2
	light.Range = baseRange + flicker * 3
end)
