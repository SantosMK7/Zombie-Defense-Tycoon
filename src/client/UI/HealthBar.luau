--!strict
-- Lebensanzeige unten in der Mitte. Folgt automatisch dem aktuellen Character.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local HealthBar = {}

local WIDTH = 360
local HEIGHT = 26

function HealthBar.create(parent: Instance)
	local C = Theme.Colors

	local frame = Theme.new("Frame", {
		Name = "HealthBar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.fromOffset(WIDTH, HEIGHT),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = Theme.PanelTransparency,
		Parent = parent,
	})
	Theme.corner(frame, 8)
	local outline = Theme.stroke(frame)

	local inner = Theme.new("Frame", {
		Name = "Inner",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		Parent = frame,
	})

	-- Helle Spur, die bei Schaden verzögert nachzieht
	local trail = Theme.new("Frame", {
		Name = "Trail",
		BackgroundColor3 = Color3.fromRGB(255, 240, 240),
		BackgroundTransparency = 0.3,
		Size = UDim2.fromScale(1, 1),
		Parent = inner,
	})
	Theme.corner(trail, 6)

	local fill = Theme.new("Frame", {
		Name = "Fill",
		BackgroundColor3 = C.HealthHigh,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = inner,
	})
	Theme.corner(fill, 6)
	Theme.new("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(175, 175, 175)),
		Parent = fill,
	})

	Theme.label({
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		Text = "♥",
		TextSize = 18,
		TextStrokeTransparency = 0.4,
		ZIndex = 4,
		Parent = frame,
	})

	local valueLabel = Theme.label({
		Name = "Value",
		Size = UDim2.fromScale(1, 1),
		Text = "100 / 100",
		TextSize = 15,
		TextStrokeTransparency = 0.4,
		ZIndex = 4,
		Parent = frame,
	})

	local function colorFor(ratio: number): Color3
		if ratio > 0.5 then
			return C.HealthMid:Lerp(C.HealthHigh, (ratio - 0.5) * 2)
		end
		return C.HealthLow:Lerp(C.HealthMid, ratio * 2)
	end

	local lastRatio = 1
	local trailTween: Tween? = nil

	local function update(humanoid: Humanoid, instant: boolean)
		local maxHealth = math.max(humanoid.MaxHealth, 1)
		local health = math.clamp(humanoid.Health, 0, maxHealth)
		local ratio = health / maxHealth
		local size = UDim2.fromScale(ratio, 1)

		valueLabel.Text = `{math.ceil(health)} / {math.floor(maxHealth)}`
		outline.Color = if ratio <= 0.25 then C.HealthLow else C.Stroke

		if trailTween then
			trailTween:Cancel()
			trailTween = nil
		end

		if instant then
			fill.Size = size
			fill.BackgroundColor3 = colorFor(ratio)
			trail.Size = size
		else
			TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = size,
				BackgroundColor3 = colorFor(ratio),
			}):Play()
			if ratio < lastRatio then
				local tween = TweenService:Create(
					trail,
					TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.35),
					{ Size = size }
				)
				trailTween = tween
				tween:Play()
			else
				trail.Size = size
			end
		end
		lastRatio = ratio
	end

	local connections: { RBXScriptConnection } = {}

	local function bind(character: Model)
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)

		local found = character:WaitForChild("Humanoid", 10) :: Humanoid?
		if not found then
			return
		end
		local humanoid = found :: Humanoid
		update(humanoid, true)
		table.insert(
			connections,
			humanoid.HealthChanged:Connect(function()
				update(humanoid, false)
			end)
		)
		table.insert(
			connections,
			humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
				update(humanoid, false)
			end)
		)
	end

	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(bind)
	if player.Character then
		task.spawn(bind, player.Character)
	end
end

return HealthBar
