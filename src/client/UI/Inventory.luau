--!strict
-- Inhalt des Inventar-Fensters: alle Waffen des Spielers.
-- Klick = in den ersten freien Hotbar-Slot legen, Ziehen = auf einen bestimmten Slot legen.

local Theme = require(script.Parent.Theme)
local ItemState = require(script.Parent.ItemState)
local Drag = require(script.Parent.Drag)
local Hotbar = require(script.Parent.Hotbar)

local Inventory = {}

function Inventory.create(body: Frame, hotbar: Hotbar.HotbarApi)
	local C = Theme.Colors

	Theme.label({
		Name = "Hint",
		Size = UDim2.new(1, 0, 0, 34),
		Text = "Click a weapon to add it to your hotbar. Drag it onto a slot to place it.\nWhile this window is open, drag a slot out of the hotbar to remove it.",
		TextSize = 13,
		FontFace = Theme.FontMedium,
		TextColor3 = C.TextDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 12,
		Parent = body,
	})

	local grid = Theme.new("ScrollingFrame", {
		Name = "Grid",
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = C.Stroke,
		ZIndex = 12,
		Parent = body,
	})
	Theme.new("UIGridLayout", {
		CellSize = UDim2.fromOffset(88, 88),
		CellPadding = UDim2.fromOffset(10, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})
	Theme.new("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		Parent = grid,
	})

	local emptyLabel = Theme.label({
		Name = "Empty",
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		Text = "No weapons yet",
		TextSize = 18,
		TextColor3 = C.TextDim,
		ZIndex = 12,
		Parent = body,
	})

	local function makeTile(tool: Tool, order: number)
		local name = tool.Name
		local slotIndex = ItemState.slotOf(name)

		local tile = Theme.new("TextButton", {
			Name = name,
			LayoutOrder = order,
			BackgroundColor3 = C.PanelLight,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 13,
			Parent = grid,
		})
		Theme.corner(tile, 10)
		Theme.stroke(tile, if slotIndex then C.Accent else C.Stroke, 1.5, 0.2)

		if tool.TextureId ~= "" then
			Theme.new("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 8),
				Size = UDim2.fromOffset(48, 48),
				Image = tool.TextureId,
				ZIndex = 14,
				Parent = tile,
			})
		end
		Theme.label({
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 4, 1, -6),
			Size = UDim2.new(1, -8, 0, if tool.TextureId ~= "" then 22 else 60),
			Text = name,
			TextSize = 13,
			TextWrapped = true,
			ZIndex = 14,
			Parent = tile,
		})
		if slotIndex then
			local badge = Theme.label({
				Position = UDim2.fromOffset(5, 5),
				Size = UDim2.fromOffset(18, 18),
				BackgroundTransparency = 0,
				BackgroundColor3 = C.Accent,
				Text = tostring(slotIndex),
				TextSize = 11,
				ZIndex = 15,
				Parent = tile,
			})
			Theme.corner(badge, 9)
		end

		tile.MouseEnter:Connect(function()
			tile.BackgroundColor3 = C.PanelHover
		end)
		tile.MouseLeave:Connect(function()
			tile.BackgroundColor3 = C.PanelLight
		end)

		tile.InputBegan:Connect(function(input)
			if not Drag.isPointer(input) then
				return
			end
			Drag.start(input, name, function(point, moved)
				if moved then
					local target = hotbar.getSlotAt(point)
					if target then
						ItemState.assign(target, name)
					end
				else
					ItemState.addToFreeSlot(name)
				end
			end)
		end)
	end

	local function refresh()
		for _, child in grid:GetChildren() do
			if child:IsA("GuiButton") then
				child:Destroy()
			end
		end
		local tools = ItemState.getTools()
		for order, tool in tools do
			makeTile(tool, order)
		end
		emptyLabel.Visible = #tools == 0
	end

	ItemState.Changed:Connect(refresh)
	refresh()
end

return Inventory
