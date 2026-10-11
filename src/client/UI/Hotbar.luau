--!strict
-- Hotbar mit Waffen-Slots über der Lebensanzeige.
-- Normal: Klick oder Taste 1–9 rüstet die Waffe aus / steckt sie weg.
-- Bei offenem Inventar (Bearbeiten-Modus): Slots ziehen zum Tauschen,
-- aus der Hotbar herausziehen zum Entfernen.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local ItemState = require(script.Parent.ItemState)
local Drag = require(script.Parent.Drag)

local Hotbar = {}

local SLOT = 60
local GAP = 6

type Slot = {
	button: TextButton,
	nameLabel: TextLabel,
	icon: ImageLabel,
	stroke: UIStroke,
	scale: UIScale,
}

export type HotbarApi = {
	getSlotAt: (Vector2) -> number?,
	setEditMode: (boolean) -> (),
}

function Hotbar.create(parent: Instance): HotbarApi
	local C = Theme.Colors
	local count = ItemState.SlotCount
	local editMode = false

	local frame = Theme.new("Frame", {
		Name = "Hotbar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -54),
		Size = UDim2.fromOffset(count * SLOT + (count - 1) * GAP, SLOT),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	Theme.new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = frame,
	})

	local slots: { Slot } = {}

	local function getSlotAt(point: Vector2): number?
		for index, slot in slots do
			if Drag.isOver(slot.button, point) then
				return index
			end
		end
		return nil
	end

	for index = 1, count do
		local button = Theme.new("TextButton", {
			Name = "Slot" .. index,
			LayoutOrder = index,
			Size = UDim2.fromOffset(SLOT, SLOT),
			BackgroundColor3 = C.Panel,
			BackgroundTransparency = 0.4,
			AutoButtonColor = false,
			Text = "",
			Parent = frame,
		})
		Theme.corner(button, 10)
		local stroke = Theme.stroke(button)
		local scale = Theme.new("UIScale", { Parent = button })

		Theme.label({
			Name = "Number",
			Position = UDim2.fromOffset(5, 3),
			Size = UDim2.fromOffset(14, 14),
			Text = tostring(index),
			TextSize = 12,
			TextColor3 = C.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = button,
		})
		local icon = Theme.new("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.7, 0.7),
			Visible = false,
			ZIndex = 2,
			Parent = button,
		})
		local nameLabel = Theme.label({
			Name = "ItemName",
			Position = UDim2.fromOffset(4, 14),
			Size = UDim2.new(1, -8, 1, -18),
			Text = "",
			TextSize = 12,
			TextWrapped = true,
			ZIndex = 2,
			Parent = button,
		})

		slots[index] = { button = button, nameLabel = nameLabel, icon = icon, stroke = stroke, scale = scale }

		-- Klick ohne Inventar: ausrüsten / wegstecken
		button.Activated:Connect(function()
			if not editMode then
				ItemState.toggleSlot(index)
			end
		end)

		-- Bei offenem Inventar: ziehen zum Tauschen / Entfernen
		button.InputBegan:Connect(function(input)
			if not editMode or not Drag.isPointer(input) then
				return
			end
			local name = ItemState.getSlot(index)
			if not name then
				return
			end
			Drag.start(input, name, function(point, moved)
				if not moved then
					ItemState.toggleSlot(index)
					return
				end
				local target = getSlotAt(point)
				if target then
					ItemState.swap(index, target)
				else
					ItemState.clear(index)
				end
			end)
		end)
	end

	local function refresh()
		local equipped = ItemState.getEquipped()
		for index, slot in slots do
			local name = ItemState.getSlot(index)
			local tool = if name then ItemState.findTool(name) else nil
			local isEquipped = tool ~= nil and tool == equipped

			local hasIcon = tool ~= nil and tool.TextureId ~= ""
			slot.icon.Visible = hasIcon
			slot.icon.Image = if tool and hasIcon then tool.TextureId else ""
			slot.nameLabel.Visible = not hasIcon
			slot.nameLabel.Text = name or ""
			-- Waffe gerade nicht vorhanden (z. B. kurz nach Respawn): blass anzeigen
			slot.nameLabel.TextTransparency = if tool then 0 else 0.6
			slot.button.BackgroundTransparency = if name then Theme.PanelTransparency else 0.4

			if isEquipped then
				slot.stroke.Color = C.Accent
				slot.stroke.Thickness = 2.5
				slot.button.BackgroundColor3 = C.PanelLight
			else
				slot.stroke.Color = if editMode then C.StrokeEdit else C.Stroke
				slot.stroke.Thickness = 1.5
				slot.button.BackgroundColor3 = C.Panel
			end
			TweenService:Create(slot.scale, TweenInfo.new(0.12), { Scale = if isEquipped then 1.08 else 1 }):Play()
		end
	end

	ItemState.Changed:Connect(refresh)
	refresh()

	return {
		getSlotAt = getSlotAt,
		setEditMode = function(enabled: boolean)
			editMode = enabled
			refresh()
		end,
	}
end

return Hotbar
