--!strict
-- Einstiegspunkt auf dem Server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local WorldBuilder = require(script.Parent.World.WorldBuilder)
local Economy = require(script.Parent.Economy)
local TestWeapons = require(script.Parent.TestWeapons)

print(`[{Config.GameName}] Server gestartet – Version {Config.Version}`)

Players.PlayerAdded:Connect(function(player)
	print(`[{Config.GameName}] {player.Name} ist beigetreten`)
end)

Economy.init()
if Config.Debug.GiveTestWeapons then
	TestWeapons.init()
end

-- Spieler erst spawnen, wenn die Welt steht (sonst fallen sie ins Leere)
Players.CharacterAutoLoads = false
WorldBuilder.build()
Players.CharacterAutoLoads = true
for _, player in Players:GetPlayers() do
	if not player.Character then
		player:LoadCharacter()
	end
end
