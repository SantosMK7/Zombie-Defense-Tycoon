--!strict
-- Einstiegspunkt auf dem Client (läuft bei jedem Spieler).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)

print(`[{Config.GameName}] Client gestartet für {Players.LocalPlayer.Name}`)
