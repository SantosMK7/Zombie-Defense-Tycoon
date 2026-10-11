--!strict
-- Geldanzeige oben rechts. Liest das Attribut "Money" am Spieler,
-- das nur der Server setzt (Server = Autorität über Geld).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local MoneyDisplay = {}

function MoneyDisplay.create(parent: Instance)
	local C = Theme.Colors
	local player = Players.LocalPlayer

	local frame = Theme.new("Frame", {
		Name = "Money",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 70),
		Size = UDim2.fromOffset(210, 46),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = Theme.PanelTransparency,
		Parent = parent,
	})
	Theme.corner(frame, 10)
	Theme.stroke(frame)

	local coin = Theme.new("Frame", {
		Name = "Coin",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = C.Money,
		Parent = frame,
	})
	Theme.corner(coin, 15)
	Theme.stroke(coin, Color3.fromRGB(170, 120, 20), 2, 0)
	Theme.label({
		Size = UDim2.fromScale(1, 1),
		Text = "$",
		TextSize = 18,
		TextColor3 = Color3.fromRGB(90, 60, 10),
		Parent = coin,
	})

	local amountLabel = Theme.label({
		Name = "Amount",
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(1, -58, 1, 0),
		Text = "0",
		TextSize = 24,
		TextColor3 = C.Money,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	-- Zahl zählt sichtbar hoch/runter
	local shown = Instance.new("NumberValue")
	shown:GetPropertyChangedSignal("Value"):Connect(function()
		amountLabel.Text = Theme.formatNumber(shown.Value)
	end)

	local function popup(diff: number)
		local label = Theme.label({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 1, 4),
			Size = UDim2.fromOffset(160, 22),
			Text = (if diff > 0 then "+" else "-") .. Theme.formatNumber(math.abs(diff)),
			TextSize = 18,
			TextColor3 = if diff > 0 then C.Positive else C.Negative,
			TextStrokeTransparency = 0.4,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = frame,
		})
		local tween = TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -12, 1, 26),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		})
		tween.Completed:Connect(function()
			label:Destroy()
		end)
		tween:Play()
	end

	local current: number? = nil

	local function refresh()
		local value = player:GetAttribute("Money")
		local amount = if typeof(value) == "number" then value else 0
		if current == nil then
			shown.Value = amount
		else
			local diff = amount - (current :: number)
			if diff ~= 0 then
				popup(diff)
				TweenService:Create(shown, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { Value = amount }):Play()
			end
		end
		current = amount
	end

	player:GetAttributeChangedSignal("Money"):Connect(refresh)
	refresh()
end

return MoneyDisplay
