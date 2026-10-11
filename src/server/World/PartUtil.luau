--!strict
-- Kleine Hilfsfunktion zum Erzeugen verankerter Bau-Teile.

local PartUtil = {}

export type PartProps = {
	Name: string?,
	Shape: Enum.PartType?,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	CanCollide: boolean?,
	CastShadow: boolean?,
	Transparency: number?,
}

function PartUtil.part(parent: Instance, props: PartProps): Part
	local p = Instance.new("Part")
	p.Name = props.Name or "Part"
	p.Anchored = true
	p.Shape = props.Shape or Enum.PartType.Block
	p.Size = props.Size
	p.CFrame = props.CFrame
	p.Color = props.Color
	p.Material = props.Material or Enum.Material.SmoothPlastic
	p.CanCollide = if props.CanCollide == nil then true else props.CanCollide
	p.CastShadow = if props.CastShadow == nil then true else props.CastShadow
	p.Transparency = props.Transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function PartUtil.wedge(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material): WedgePart
	local w = Instance.new("WedgePart")
	w.Name = name
	w.Anchored = true
	w.Size = size
	w.CFrame = cf
	w.Color = color
	w.Material = material
	w.Parent = parent
	return w
end

-- Zylinder liegen in Roblox entlang der X-Achse – damit steht er aufrecht.
PartUtil.UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

return PartUtil
