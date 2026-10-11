--!strict
-- Baut das HUD auf: Lebensanzeige, Geld, Hotbar, Inventar, Shop- und Build-Button.
-- Die einzelnen Teile liegen im Ordner UI/.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local UI = script.Parent:WaitForChild("UI")
local Theme = require(UI.Theme)
local ItemState = require(UI.ItemState)
local Drag = require(UI.Drag)
local Panels = require(UI.Panels)
local HealthBar = require(UI.HealthBar)
local MoneyDisplay = require(UI.MoneyDisplay)
local Hotbar = require(UI.Hotbar)
local Inventory = require(UI.Inventory)
local SideMenu = require(UI.SideMenu)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local keys = Config.Hud.Keys

-- Standard-Roblox-Leiste und -Lebensanzeige ausblenden (wir haben eigene)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

-- Haupt-GUI
local screenGui = Theme.new("ScreenGui", {
	Name = "HUD",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

-- Alles in "root" skaliert mit der Bildschirmgröße (kleiner auf Handys)
local root = Theme.new("Frame", {
	Name = "Root",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Parent = screenGui,
})
local uiScale = Theme.new("UIScale", { Parent = root })

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 760), 0.55, 1)
	uiScale.Scale = scale
	root.Size = UDim2.fromScale(1 / scale, 1 / scale)
end
updateScale()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- Eigene GUI für gezogene Gegenstände (unskaliert, ganz oben)
local dragGui = Theme.new("ScreenGui", {
	Name = "HUDDrag",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ScreenInsets = Enum.ScreenInsets.None,
	DisplayOrder = 100,
	Parent = playerGui,
})
Drag.init(Theme.new("Frame", {
	Name = "DragLayer",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Parent = dragGui,
}))

-- Bausteine
ItemState.init()
HealthBar.create(root)
MoneyDisplay.create(root)
local hotbar = Hotbar.create(root)

Panels.init(root)

local function placeholder(body: Frame, headline: string, text: string)
	Theme.label({
		Position = UDim2.fromScale(0, 0.28),
		Size = UDim2.new(1, 0, 0, 30),
		Text = headline,
		TextSize = 24,
		ZIndex = 12,
		Parent = body,
	})
	Theme.label({
		Position = UDim2.new(0, 0, 0.28, 38),
		Size = UDim2.new(1, 0, 0, 40),
		Text = text,
		TextSize = 14,
		FontFace = Theme.FontMedium,
		TextColor3 = Theme.Colors.TextDim,
		TextWrapped = true,
		ZIndex = 12,
		Parent = body,
	})
end

placeholder(
	Panels.register("Shop", "SHOP"),
	"Coming soon",
	"Buy weapons and base upgrades here with your money."
)
placeholder(
	Panels.register("Build", "BUILD"),
	"Coming soon",
	"Place walls, turrets and traps to defend your base."
)
Inventory.create(Panels.register("Inventory", "INVENTORY"), hotbar)

local sideMenu = SideMenu.create(root, {
	{ name = "Shop", label = "SHOP", icon = "🛒", key = keys.Shop },
	{ name = "Build", label = "BUILD", icon = "🔨", key = keys.Build },
	{ name = "Inventory", label = "INVENTORY", icon = "🎒", key = keys.Inventory },
}, Panels.toggle)

Panels.Changed:Connect(function(openName: string?)
	sideMenu.setActive(openName)
	hotbar.setEditMode(openName == "Inventory")
end)

-- Tastatur
local slotKeys: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	local key = input.KeyCode
	local slot = slotKeys[key]
	if slot and slot <= ItemState.SlotCount then
		ItemState.toggleSlot(slot)
	elseif key == keys.Inventory then
		Panels.toggle("Inventory")
	elseif key == keys.Shop then
		Panels.toggle("Shop")
	elseif key == keys.Build then
		Panels.toggle("Build")
	end
end)
