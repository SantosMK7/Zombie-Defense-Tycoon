--!strict
-- Ziehen & Ablegen (Maus und Touch) für Inventar und Hotbar.
-- Der "Geist" (das gezogene Bild) liegt in einer eigenen ScreenGui ohne UIScale,
-- damit er genau unter dem Finger/Mauszeiger bleibt.

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)

local Drag = {}

local DRAG_THRESHOLD = 6 -- Pixel, ab denen ein Klick als Ziehen zählt

local dragRoot: Frame? = nil
local active = false

-- root = Vollbild-Frame in einer ScreenGui mit IgnoreGuiInset und ScreenInsets None
function Drag.init(root: Frame)
	dragRoot = root
end

local function screenPosition(input: InputObject): Vector2
	local t = input.UserInputType
	if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.MouseButton1 then
		return UserInputService:GetMouseLocation()
	end
	return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
end

local function isPointer(input: InputObject): boolean
	local t = input.UserInputType
	return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end

-- Liegt der Bildschirmpunkt über dem GUI-Element?
function Drag.isOver(gui: GuiObject, point: Vector2): boolean
	local root = dragRoot
	if not root or not gui.Visible then
		return false
	end
	local topLeft = gui.AbsolutePosition - root.AbsolutePosition
	local size = gui.AbsoluteSize
	return point.X >= topLeft.X
		and point.X <= topLeft.X + size.X
		and point.Y >= topLeft.Y
		and point.Y <= topLeft.Y + size.Y
end

function Drag.isPointer(input: InputObject): boolean
	return isPointer(input)
end

-- Startet einen möglichen Zieh-Vorgang. onDrop(punkt, wurdeGezogen) wird beim
-- Loslassen aufgerufen; wurdeGezogen = false bedeutet: es war nur ein Klick.
function Drag.start(input: InputObject, text: string, onDrop: (Vector2, boolean) -> ())
	local root = dragRoot
	if active or not root or not isPointer(input) then
		return
	end
	active = true

	local startPoint = screenPosition(input)
	local point = startPoint
	local moved = false
	local ghost: Frame? = nil

	local moveConn: RBXScriptConnection? = nil
	local endConn: RBXScriptConnection? = nil

	moveConn = UserInputService.InputChanged:Connect(function(changed)
		local t = changed.UserInputType
		if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then
			return
		end
		point = screenPosition(changed)
		if not moved and (point - startPoint).Magnitude > DRAG_THRESHOLD then
			moved = true
			local g = Theme.new("Frame", {
				Name = "DragGhost",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(64, 64),
				BackgroundColor3 = Theme.Colors.PanelLight,
				BackgroundTransparency = 0.15,
				ZIndex = 50,
				Parent = root,
			})
			Theme.corner(g, 10)
			Theme.stroke(g, Theme.Colors.Accent, 2, 0)
			Theme.label({
				Size = UDim2.new(1, -8, 1, -8),
				Position = UDim2.fromOffset(4, 4),
				Text = text,
				TextSize = 13,
				TextWrapped = true,
				ZIndex = 51,
				Parent = g,
			})
			ghost = g
		end
		if ghost then
			ghost.Position = UDim2.fromOffset(point.X, point.Y)
		end
	end)

	endConn = UserInputService.InputEnded:Connect(function(ended)
		if not isPointer(ended) then
			return
		end
		if moveConn then
			moveConn:Disconnect()
		end
		if endConn then
			endConn:Disconnect()
		end
		if ghost then
			ghost:Destroy()
		end
		active = false
		onDrop(point, moved)
	end)
end

return Drag
