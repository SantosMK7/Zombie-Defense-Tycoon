--!strict
-- Nacht-Stimmung: Mond, Sterne, bläulicher Dunst – aber hell genug zum Spielen.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local L = Config.Lighting

local NightLighting = {}

function NightLighting.apply()
	-- alte Himmel/Effekte entfernen, damit nichts doppelt ist
	for _, child in Lighting:GetChildren() do
		if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("PostEffect") or child:IsA("Clouds") then
			child:Destroy()
		end
	end

	Lighting.ClockTime = L.ClockTime
	Lighting.Brightness = L.Brightness
	Lighting.Ambient = L.Ambient
	Lighting.OutdoorAmbient = L.OutdoorAmbient
	Lighting.ExposureCompensation = L.ExposureCompensation
	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.4

	local sky = Instance.new("Sky")
	sky.StarCount = L.StarCount
	sky.MoonAngularSize = L.MoonSize
	sky.CelestialBodiesShown = true
	sky.Parent = Lighting

	-- Dunst lässt den Wald in der Ferne blau-grau verschwimmen
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.36
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(70, 80, 120)
	atmosphere.Decay = Color3.fromRGB(35, 40, 70)
	atmosphere.Glare = 0
	atmosphere.Haze = 1.4
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.6
	bloom.Size = 24
	bloom.Threshold = 1.4
	bloom.Parent = Lighting

	local color = Instance.new("ColorCorrectionEffect")
	color.Brightness = 0.03
	color.Contrast = 0.08
	color.Saturation = -0.05
	color.TintColor = Color3.fromRGB(228, 232, 255)
	color.Parent = Lighting
end

return NightLighting
