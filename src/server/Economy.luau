--!strict
-- Geld der Spieler. Nur der Server ändert das Geld.
-- Der Kontostand liegt im Attribut "Money" am Player – so sieht ihn der Client
-- automatisch (Geldanzeige), kann ihn aber nicht wirklich verändern.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local ATTRIBUTE = "Money"

local Economy = {}

function Economy.get(player: Player): number
	local value = player:GetAttribute(ATTRIBUTE)
	return if typeof(value) == "number" then value else 0
end

function Economy.set(player: Player, amount: number)
	player:SetAttribute(ATTRIBUTE, math.max(0, math.floor(amount)))
end

function Economy.add(player: Player, amount: number)
	Economy.set(player, Economy.get(player) + amount)
end

-- Zieht Geld ab, falls genug da ist. Gibt zurück, ob es geklappt hat.
function Economy.trySpend(player: Player, amount: number): boolean
	if amount < 0 or Economy.get(player) < amount then
		return false
	end
	Economy.set(player, Economy.get(player) - amount)
	return true
end

local function setup(player: Player)
	if player:GetAttribute(ATTRIBUTE) == nil then
		Economy.set(player, Config.StartMoney)
	end
end

function Economy.init()
	Players.PlayerAdded:Connect(setup)
	for _, player in Players:GetPlayers() do
		setup(player)
	end

	-- Nur zum Testen der Geldanzeige (Config.Debug.TestIncome = 0 schaltet es ab)
	local income = Config.Debug.TestIncome
	if income > 0 then
		task.spawn(function()
			while true do
				task.wait(Config.Debug.TestIncomeInterval)
				for _, player in Players:GetPlayers() do
					Economy.add(player, income)
				end
			end
		end)
	end
end

return Economy
