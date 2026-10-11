--!strict
-- Farben, Schriften und kleine Helfer für alle HUD-Elemente.

local Theme = {}

Theme.Colors = {
	Panel = Color3.fromRGB(20, 17, 24),
	PanelLight = Color3.fromRGB(38, 33, 44),
	PanelHover = Color3.fromRGB(56, 47, 64),
	Stroke = Color3.fromRGB(85, 70, 92),
	StrokeEdit = Color3.fromRGB(150, 130, 160),
	Accent = Color3.fromRGB(210, 50, 50),
	Text = Color3.fromRGB(242, 236, 236),
	TextDim = Color3.fromRGB(165, 152, 168),
	Money = Color3.fromRGB(255, 206, 72),
	Positive = Color3.fromRGB(110, 220, 110),
	Negative = Color3.fromRGB(235, 80, 80),
	HealthHigh = Color3.fromRGB(85, 200, 95),
	HealthMid = Color3.fromRGB(235, 190, 55),
	HealthLow = Color3.fromRGB(215, 45, 45),
}

Theme.PanelTransparency = 0.12

Theme.FontBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
Theme.FontMedium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

-- Erzeugt ein Instance mit Eigenschaften; Parent wird zuletzt gesetzt.
function Theme.new(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst: any = (Instance.new :: any)(className)
	local parent: Instance? = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Theme.corner(parent: Instance, radius: number?): UICorner
	return Theme.new("UICorner", { CornerRadius = UDim.new(0, radius or 10), Parent = parent })
end

function Theme.stroke(parent: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
	return Theme.new("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or Theme.Colors.Stroke,
		Thickness = thickness or 1.5,
		Transparency = transparency or 0.2,
		Parent = parent,
	})
end

function Theme.label(props: { [string]: any }): TextLabel
	local defaults: { [string]: any } = {
		BackgroundTransparency = 1,
		FontFace = Theme.FontBold,
		TextColor3 = Theme.Colors.Text,
		TextSize = 16,
	}
	for key, value in props do
		defaults[key] = value
	end
	return Theme.new("TextLabel", defaults)
end

-- 1234567 -> "1,234,567"
function Theme.formatNumber(n: number): string
	local digits = tostring(math.floor(math.abs(n) + 0.5))
	local formatted = digits:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return (if n < 0 then "-" else "") .. formatted
end

-- Nur Touch (Handy/Tablet) -> Tastenhinweise ausblenden
function Theme.isTouchOnly(): boolean
	local UserInputService = game:GetService("UserInputService")
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

return Theme
