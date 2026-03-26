 

local addonID, addonEnv = ...

--print("FFXIV UI Target Buffs loaded")

local SCALE = 100
local function s(x) return x * SCALE / 100 end  

local rootFrame = CreateFrame("Frame", addonID, UIParent)
rootFrame:SetSize(1, 1)

rootFrame.bg = rootFrame:CreateTexture(nil, "BACKGROUND", nil, -8)



local Masque = LibStub and LibStub("Masque", true)
local MasqueGroup
if Masque then
	MasqueGroup = Masque:Group("FFXIV Target Buffs", "Target Buffs")
end


local AURA_ICON_SIZE, AURA_GAP, AURA_LIMIT, REFRESH_INTERVAL, WIDTH_EXTENSION =
	s(38), s(0), 20, 0.5, 1.10

rootFrame.slots = {}


local function ClearCooldown(cd)
	cd:Clear()
end

local function SetCooldown(cd, unit, auraInstanceID)
	local durationObject = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)

	if durationObject then
		cd:SetDrawEdge(false)
		cd:SetCooldownFromDurationObject(durationObject)
	else
		cd:Clear()
	end
end



local function CreateAuraSlot(parent, index)
	local slot = CreateFrame("Button", nil, parent)
	slot:SetSize(AURA_ICON_SIZE, AURA_ICON_SIZE)

	if index == 1 then
		slot:SetPoint("LEFT", parent, "LEFT", 0, 0)
	else
		slot:SetPoint("LEFT", parent.slots[index - 1], "RIGHT", AURA_GAP, 0)
	end


	slot.texture = slot:CreateTexture(nil, "BACKGROUND")
	slot.texture:SetAllPoints()
	slot.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	slot.cooldown = CreateFrame("Cooldown", nil, slot, "CooldownFrameTemplate")
	slot.cooldown:SetAllPoints()
	slot.cooldown:SetDrawSwipe(true)


	slot.stackText = slot:CreateFontString(nil, "OVERLAY")
	slot.stackText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(12), "OUTLINE")
	slot.stackText:SetPoint("BOTTOMRIGHT", 0, 0)

	slot:SetScript("OnEnter", function(self)
		if self.instanceID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetUnitBuffByAuraInstanceID("target", self.instanceID)
		end
	end)
	slot:SetScript("OnLeave", GameTooltip_Hide)


	if MasqueGroup then
		MasqueGroup:AddButton(slot, { Icon = slot.texture, Cooldown = slot.cooldown, Count = slot.stackText })
	end

	slot:Hide()
	return slot
end


local function AnchorToFFTargetFrame()
	assert(FFTargetFrame, "FFTargetFrame not found")
	rootFrame:ClearAllPoints()
	rootFrame:SetPoint("TOPLEFT", FFTargetFrame, "BOTTOMLEFT", s(5), s(310))
end

local function UpdateRootSize()
	local baseWidth = (AURA_ICON_SIZE * AURA_LIMIT) + (AURA_GAP * (AURA_LIMIT - 1))
	rootFrame:SetSize(baseWidth * WIDTH_EXTENSION, AURA_ICON_SIZE)
end


local function RefreshTargetAuras()
	if not UnitExists("target") then
		for _, slot in ipairs(rootFrame.slots) do slot:Hide() end
		return
	end

	local filter = AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful)
	local auras = C_UnitAuras.GetUnitAuras("target", filter, AURA_LIMIT)

for i = 1, AURA_LIMIT do
    local slot = rootFrame.slots[i]
    local aura = auras and auras[i]

if aura then
    slot.texture:SetTexture(aura.icon)

    local stacks = aura.applications
			 local stackString = C_StringUtil.TruncateWhenZero(stacks)

		 
				 slot.stackText:SetText(stackString)

    SetCooldown(slot.cooldown, "target", aura.auraInstanceID)

    slot.instanceID = aura.auraInstanceID
    slot:Show()

    for _, region in ipairs({ slot.cooldown:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            region:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", s(14))
            region:ClearAllPoints()
            region:SetPoint("CENTER", slot.cooldown, "CENTER", 0, s(-20))
            break
        end
    end
else
    slot:Hide()
end
 

	end
end


rootFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_AURA" then
		RefreshTargetAuras()
	end
end)

rootFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
rootFrame:RegisterUnitEvent("UNIT_AURA", "target")


for i = 1, AURA_LIMIT do
	rootFrame.slots[i] = CreateAuraSlot(rootFrame, i)
end

UpdateRootSize()
AnchorToFFTargetFrame()
 


local anchor = FFXIV_UI_Anchors.TargetAuras
rootFrame:SetParent(anchor)
rootFrame:ClearAllPoints()
rootFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)


 