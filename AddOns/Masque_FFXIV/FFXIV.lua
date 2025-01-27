	--[[ FFXIV skin for Masque ]]

local MSQ = LibStub("Masque", true)
if not MSQ then return end

MSQ:AddSkin("FFXIV", {
	Author = "MojiTheMonk",
	Version = "1.0",
	Shape = "Square",
	Masque_Version = 40200,
	Backdrop = {
		Width = 36,
		Height = 36,
		Color = {0.3, 0.3, 0.3, 1},
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Backdrop]],
	},
	Icon = {
		TexCoords = {.09, .9, .09, .9},
		DrawLayer = "BACKGROUND",
		DrawLevel = 0,
		Width = 40,
		Height = 40,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = -1,
		Mask = [[Interface\AddOns\Masque_FFXIV\Textures\Mask.tga]],
	},
	Flash = {
		Width = 40,
		Height = 40,
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Mask]],
	},
	Cooldown = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Swipe-Circle]],
	},
	Pushed = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		OffsetX = 0,
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Highlight]],
	},
	Normal = {
		Width = 40,
		Height = 40,
		Color = {0.2, 0.2, 0.2, 1},
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Normal_clean]],
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Highlight]],
	},
	Border = {
		Width = 40,
		Height = 40,
		BlendMode = "DISABLE",
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Border]],
	},
	Gloss = {
		Width = 40,
		Height = 40,
		OffsetY = -1,
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Gloss_clean]],
	},
	AutoCastable = {
		Width = 34,
		Height = 34,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Texture = [[Interface\AddOns\Masque_FFXIV\Textures\Highlight]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetX = 0,
		OffsetY = 5,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -4,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = -27,
		OffsetY = 1,
			DrawLayer = "OVERLAY",
			DrawLevel = -500,
	},
	Duration = {
		Width = 32,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 26,
		Height = 26,
		OffsetX = 1,
		OffsetY = -1,
	},
}, true)