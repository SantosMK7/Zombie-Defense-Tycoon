--!strict
-- Einstiegspunkt auf dem Server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)

print(`[{Config.GameName}] Server gestartet – Version {Config.Version}`)

Players.PlayerAdded:Connect(function(player)
	print(`[{Config.GameName}] {player.Name} ist beigetreten`)
end)
