include("shared.lua")

ENT.PopulateEntityInfo = true

local COLOR_UNLOCKED = Color(135, 211, 124, 200)

function ENT:OnPopulateEntityInfo(tooltip)
	surface.SetFont("ixIconsSmall")

	if (tooltip:IsMinimal()) then
		local icon = tooltip:AddRow("icon")
		icon:SetFont("ixIconsSmall")
		icon:SetTextColor(COLOR_UNLOCKED)
		icon:SetText("L")
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
end
