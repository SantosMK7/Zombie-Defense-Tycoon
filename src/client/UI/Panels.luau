--!strict
-- Fenster in der Bildschirmmitte (Shop, Build, Inventory).
-- Es ist immer höchstens ein Fenster offen.
--
-- Für spätere Etappen: Panels.getBody("Shop") liefert den Inhaltsbereich
-- eines Fensters, dort können neue Inhalte eingebaut werden.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local Panels = {}

local changedEvent = Instance.new("BindableEvent")
Panels.Changed = changedEvent.Event -- feuert mit dem Namen des offenen Fensters (oder nil)

type Window = {
	frame: Frame,
	body: Frame,
	scale: UIScale,
}

local windows: { [string]: Window } = {}
local openName: string? = nil
local container: Instance? = nil

function Panels.init(parent: Instance)
	container = parent
end

function Panels.register(name: string, title: string): Frame
	assert(container, "Panels.init zuerst aufrufen")
	local C = Theme.Colors

	local frame = Theme.new("Frame", {
		Name = name .. "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.44),
		Size = UDim2.fromOffset(560, 360),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.06,
		Visible = false,
		ZIndex = 10,
		Parent = container,
	})
	Theme.corner(frame, 14)
	Theme.stroke(frame, C.Stroke, 2, 0.1)
	local scale = Theme.new("UIScale", { Parent = frame })

	Theme.label({
		Name = "Title",
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -80, 0, 50),
		Text = title,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
		Parent = frame,
	})
	Theme.new("Frame", {
		Name = "TitleLine",
		Position = UDim2.fromOffset(20, 48),
		Size = UDim2.new(1, -40, 0, 2),
		BackgroundColor3 = C.Accent,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = frame,
	})

	local close = Theme.new("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = C.PanelLight,
		FontFace = Theme.FontBold,
		Text = "X",
		TextSize = 16,
		TextColor3 = C.Text,
		AutoButtonColor = true,
		Modal = true, -- gibt die Maus frei (z. B. bei Shift-Lock), solange das Fenster offen ist
		ZIndex = 12,
		Parent = frame,
	})
	Theme.corner(close, 8)
	close.Activated:Connect(function()
		Panels.close()
	end)

	local body = Theme.new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 62),
		Size = UDim2.new(1, -40, 1, -78),
		ZIndex = 11,
		Parent = frame,
	})

	windows[name] = { frame = frame, body = body, scale = scale }
	return body
end

function Panels.getBody(name: string): Frame?
	local window = windows[name]
	return if window then window.body else nil
end

function Panels.getOpen(): string?
	return openName
end

function Panels.close()
	if openName == nil then
		return
	end
	local window = windows[openName :: string]
	if window then
		window.frame.Visible = false
	end
	openName = nil
	changedEvent:Fire(nil)
end

function Panels.open(name: string)
	local window = windows[name]
	if not window or openName == name then
		return
	end
	if openName then
		local previous = windows[openName :: string]
		if previous then
			previous.frame.Visible = false
		end
	end
	openName = name
	window.scale.Scale = 0.92
	window.frame.Visible = true
	TweenService:Create(window.scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
	changedEvent:Fire(name)
end

function Panels.toggle(name: string)
	if openName == name then
		Panels.close()
	else
		Panels.open(name)
	end
end

return Panels
