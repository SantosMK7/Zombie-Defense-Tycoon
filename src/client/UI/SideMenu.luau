--!strict
-- Buttons am linken Bildschirmrand (Shop, Build, Inventory).

local Theme = require(script.Parent.Theme)

local SideMenu = {}

export type ButtonDef = {
	name: string,
	label: string,
	icon: string,
	key: Enum.KeyCode?,
}

local SIZE = 76

function SideMenu.create(parent: Instance, defs: { ButtonDef }, onPressed: (string) -> ())
	local C = Theme.Colors

	local frame = Theme.new("Frame", {
		Name = "SideMenu",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(SIZE, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})
	Theme.new("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = frame,
	})

	local strokes: { [string]: UIStroke } = {}
	local showKeys = not Theme.isTouchOnly()

	for index, def in defs do
		local button = Theme.new("TextButton", {
			Name = def.name,
			LayoutOrder = index,
			Size = UDim2.fromOffset(SIZE, SIZE),
			BackgroundColor3 = C.Panel,
			BackgroundTransparency = Theme.PanelTransparency,
			AutoButtonColor = false,
			Text = "",
			Parent = frame,
		})
		Theme.corner(button, 12)
		strokes[def.name] = Theme.stroke(button)

		Theme.label({
			Name = "Icon",
			Position = UDim2.fromOffset(0, 8),
			Size = UDim2.new(1, 0, 0, 36),
			Text = def.icon,
			TextSize = 30,
			Parent = button,
		})
		Theme.label({
			Name = "Label",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, -6),
			Size = UDim2.new(1, 0, 0, 18),
			Text = def.label,
			TextSize = 12,
			Parent = button,
		})
		if showKeys and def.key then
			local keyLabel = Theme.label({
				Name = "KeyHint",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -4, 0, 4),
				Size = UDim2.fromOffset(18, 18),
				BackgroundTransparency = 0.2,
				BackgroundColor3 = C.PanelLight,
				Text = (def.key :: Enum.KeyCode).Name,
				TextSize = 11,
				TextColor3 = C.TextDim,
				Parent = button,
			})
			Theme.corner(keyLabel, 5)
		end

		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = C.PanelHover
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = C.Panel
		end)
		button.Activated:Connect(function()
			onPressed(def.name)
		end)
	end

	-- Markiert den Button des gerade offenen Fensters rot
	local function setActive(name: string?)
		for buttonName, stroke in strokes do
			local active = buttonName == name
			stroke.Color = if active then C.Accent else C.Stroke
			stroke.Thickness = if active then 2.5 else 1.5
		end
	end

	return { setActive = setActive }
end

return SideMenu
