include("shared.lua")

ENT.PopulateEntityInfo = true

local COLOR_UNLOCKED = Color(135, 211, 124, 200)

function ENT:OnPopulateEntityInfo(tooltip)
	surface.SetFont("ixIconsSmall")

	-- minimal tooltips have centered text so we'll draw the icon above the name instead
	if (tooltip:IsMinimal()) then
		icon:SetFont("ixIconsSmall")
		icon:SetTextColor(COLOR_UNLOCKED)
		icon:SetText(iconText)
		icon:SizeToContents()
	end

	local title = tooltip:AddRow("name")
	title:SetImportant()
	title:SetText("Loot")
	title:SetBackgroundColor(ix.config.Get("color"))
	title:SizeToContents()

	if (!tooltip:IsMinimal()) then
		title.Paint = function(panel, width, height)
			panel:PaintBackground(width, height)

			surface.SetFont("ixIconsSmall")
			surface.SetTextColor(COLOR_UNLOCKED)
			surface.SetTextPos(4, height * 0.5)
		end
	end

	--local description = tooltip:AddRow("description")
	--description:SetText("A container with some random stuff in it")
	--description:SizeToContents()
end
