--!strict
-- Verwaltet Waffen (Tools) des Spielers und die Belegung der Hotbar-Slots.
-- Waffen sind normale Roblox-Tools im Backpack. Die Hotbar merkt sich den
-- Tool-Namen pro Slot, damit die Belegung nach dem Respawn erhalten bleibt.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local changedEvent = Instance.new("BindableEvent")

local ItemState = {}

ItemState.SlotCount = Config.Hud.HotbarSlots
ItemState.Changed = changedEvent.Event -- feuert, wenn sich Tools, Ausrüstung oder Slots ändern

local slots: { [number]: string } = {}
local pending = false

local function queueChanged()
	if pending then
		return
	end
	pending = true
	task.defer(function()
		pending = false
		changedEvent:Fire()
	end)
end

function ItemState.getSlot(index: number): string?
	return slots[index]
end

function ItemState.slotOf(name: string): number?
	for index = 1, ItemState.SlotCount do
		if slots[index] == name then
			return index
		end
	end
	return nil
end

function ItemState.findTool(name: string): Tool?
	local character = player.Character
	if character then
		local tool = character:FindFirstChild(name)
		if tool and tool:IsA("Tool") then
			return tool
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild(name)
		if tool and tool:IsA("Tool") then
			return tool
		end
	end
	return nil
end

-- Alle Waffen des Spielers (Backpack + ausgerüstet), nach Name sortiert
function ItemState.getTools(): { Tool }
	local result: { Tool } = {}
	local seen: { [string]: boolean } = {}
	local containers: { Instance } = {}
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		table.insert(containers, backpack)
	end
	if player.Character then
		table.insert(containers, player.Character)
	end
	for _, container in containers do
		for _, child in container:GetChildren() do
			if child:IsA("Tool") and not seen[child.Name] then
				seen[child.Name] = true
				table.insert(result, child)
			end
		end
	end
	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

function ItemState.getEquipped(): Tool?
	local character = player.Character
	return if character then character:FindFirstChildOfClass("Tool") else nil
end

-- Legt eine Waffe in einen Slot. War sie schon in einem anderen Slot,
-- tauschen die beiden Slots.
function ItemState.assign(index: number, name: string)
	local old = ItemState.slotOf(name)
	if old == index then
		return
	end
	if old then
		slots[old] = slots[index]
	end
	slots[index] = name
	queueChanged()
end

function ItemState.swap(a: number, b: number)
	slots[a], slots[b] = slots[b], slots[a]
	queueChanged()
end

function ItemState.clear(index: number)
	slots[index] = nil
	queueChanged()
end

-- Legt die Waffe in den ersten freien Slot. Gibt false zurück, wenn alle voll sind.
function ItemState.addToFreeSlot(name: string): boolean
	if ItemState.slotOf(name) then
		return true
	end
	for index = 1, ItemState.SlotCount do
		if slots[index] == nil then
			ItemState.assign(index, name)
			return true
		end
	end
	return false
end

-- Taste/Klick auf einen Slot: Waffe ausrüsten bzw. wieder wegstecken
function ItemState.toggleSlot(index: number)
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local name = slots[index]
	local tool = if name then ItemState.findTool(name) else nil
	if tool == nil then
		humanoid:UnequipTools()
	elseif tool.Parent == character then
		humanoid:UnequipTools()
	else
		humanoid:EquipTool(tool)
	end
end

local function watch(container: Instance)
	container.ChildAdded:Connect(queueChanged)
	container.ChildRemoved:Connect(queueChanged)
	queueChanged()
end

function ItemState.init()
	-- Backpack und Character werden beim Respawn neu erzeugt
	player.ChildAdded:Connect(function(child)
		if child:IsA("Backpack") then
			watch(child)
		end
	end)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		watch(backpack)
	end
	player.CharacterAdded:Connect(watch)
	if player.Character then
		watch(player.Character)
	end
end

return ItemState
