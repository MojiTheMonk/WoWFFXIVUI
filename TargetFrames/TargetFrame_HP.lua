
--print("FFXIV UI Target Frame loaded")

TargetFrame:Hide()
TargetFrame:UnregisterAllEvents()
TargetFrame.Show = function() end  


local SCALE = 103
local function s(x) return x * SCALE / 100 end  


FFTargetFrame = CreateFrame("Frame", "FFTargetFrame", UIParent)
FFTargetFrame:EnableMouse(false)
local f = FFTargetFrame

f:SetSize(s(650), s(650))
f:SetFrameStrata("MEDIUM")

local COLORS = {
    hostile  = {200/255, 50/255, 8/255},       
    friendly = {228/255,255/255,204/255},      
    neutral  = {1.0, 0.87, 0.0},               
    player   = {0.6, 0.8, 1.0},                
    dead     = {0.35, 0.35, 0.35},             
}


local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Background")
bg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 4)
bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, -5 )
bg:SetVertexColor(unpack(COLORS.neutral))


local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", 0, 0)
bar:SetPoint("BOTTOMRIGHT", s(0), -5)
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Health")
bar:EnableMouse(false)
local tex = bar:GetStatusBarTexture()
tex:SetDrawLayer("ARTWORK", 0)
tex:SetTexCoord(0, 1, 0, 1)


local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetAllPoints(f)
outlineFrame:EnableMouse(false)


local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Frame6")
outline:SetDrawLayer("OVERLAY", 3)
outline:SetVertexColor(unpack(COLORS.neutral))
local OUTLINE_PADDING = s(0)
outline:SetPoint("TOPLEFT", f, "TOPLEFT", -OUTLINE_PADDING, OUTLINE_PADDING)
outline:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", OUTLINE_PADDING, -OUTLINE_PADDING)

local LLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
LLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(18))
LLabel:SetPoint("LEFT", outlineFrame, "LEFT", s(5), s(16))
LLabel:SetJustifyH("LEFT")
LLabel:SetDrawLayer("OVERLAY", 7)
LLabel:SetText("L")
LLabel:SetShadowOffset(1, -1)

local vLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
vLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(18))
vLabel:SetPoint("LEFT", LLabel, "LEFT", s(8), 0)
vLabel:SetJustifyH("LEFT")
vLabel:SetDrawLayer("OVERLAY", 7)
vLabel:SetText("v")
vLabel:SetShadowOffset(1, -1)


local levelText = outlineFrame:CreateFontString(nil, "OVERLAY")
levelText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtendedBlack.ttf", s(18))
levelText:SetPoint("LEFT", vLabel, "RIGHT", s(4), s(-1))
levelText:SetJustifyH("RIGHT")
levelText:SetDrawLayer("OVERLAY", 7)
levelText:SetShadowOffset(1, -1)

local nameText = outlineFrame:CreateFontString(nil, "OVERLAY")
nameText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", s(20))
nameText:SetPoint("LEFT", levelText, "RIGHT", s(5), s(2))
nameText:SetJustifyH("LEFT")
nameText:SetDrawLayer("OVERLAY", 7)
nameText:SetShadowOffset(1, -1)


local hpPercentText = outlineFrame:CreateFontString(nil, "OVERLAY")
hpPercentText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", s(16))
hpPercentText:SetPoint("LEFT", outlineFrame, "LEFT", s(5), s(16))
hpPercentText:SetJustifyH("LEFT")
hpPercentText:SetDrawLayer("OVERLAY", 7)
hpPercentText:SetShadowOffset(1, -1)


local raidIcon = outlineFrame:CreateTexture(nil, "OVERLAY")
raidIcon:SetSize(s(28), s(28))
raidIcon:SetPoint("RIGHT", bar, "LEFT", s(-8), 0)
raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
raidIcon:Hide()


local rareIcon = outlineFrame:CreateTexture(nil, "OVERLAY")
rareIcon:SetSize(s(28), s(28))
rareIcon:SetPoint("LEFT", LLabel, "LEFT", s(-28), s(0))
rareIcon:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\RareIcon")
rareIcon:Hide()


local CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT = s(650), s(30)
local clickFrame = CreateFrame("Button", "FFXIV_TargetClick", outlineFrame, "SecureUnitButtonTemplate")
clickFrame:SetFrameStrata(f:GetFrameStrata())
clickFrame:SetFrameLevel(f:GetFrameLevel() - 1)
clickFrame:SetSize(CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT)
clickFrame:SetPoint("CENTER", outlineFrame, "CENTER", 0, s(5))
clickFrame:SetAttribute("unit", "target")
clickFrame:SetAttribute("type1", "target")
clickFrame:SetAttribute("type2", "togglemenu")
clickFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
clickFrame:EnableMouse(true)


local anchor = FFXIV_UI_Anchors.TargetHP
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, -15)

local function ShowFrame() f:SetAlpha(1) end
local function HideFrame() f:SetAlpha(0) end

local function DarkenColor(r, g, b, factor)
    factor = factor or 0.6
    return r * factor, g * factor, b * factor
end

local function SetBarAndTextColor(r, g, b)
    bar:SetStatusBarColor(r, g, b, 1)
    local sr, sg, sb = DarkenColor(r, g, b, 0.6)
    LLabel:SetTextColor(r, g, b); LLabel:SetShadowColor(sr, sg, sb)
    vLabel:SetTextColor(r, g, b); vLabel:SetShadowColor(sr, sg, sb)
    levelText:SetTextColor(r, g, b); levelText:SetShadowColor(sr, sg, sb)
    nameText:SetTextColor(r, g, b); nameText:SetShadowColor(sr, sg, sb)
    hpPercentText:SetTextColor(r, g, b); hpPercentText:SetShadowColor(sr, sg, sb)
end

local function UpdateColors()
    if not UnitExists("target") then return end
   -- rareIcon:Hide()
   rareIcon:Hide()



    if UnitIsUnit("target", "player") or (UnitIsPlayer("target") and (UnitInParty("target") or UnitInRaid("target"))) then
        bg:SetVertexColor(unpack(COLORS.player))
        outline:SetVertexColor(unpack(COLORS.player))
        bar:SetStatusBarColor(1,1,1)
        local r,g,b = unpack(COLORS.player)
        local sr,sg,sb = DarkenColor(r,g,b,0.6)
        LLabel:SetTextColor(r,g,b); LLabel:SetShadowColor(sr,sg,sb)
        vLabel:SetTextColor(r,g,b); vLabel:SetShadowColor(sr,sg,sb)
        levelText:SetTextColor(r,g,b); levelText:SetShadowColor(sr,sg,sb)
        nameText:SetTextColor(r,g,b); nameText:SetShadowColor(sr,sg,sb)
        hpPercentText:SetTextColor(r,g,b); hpPercentText:SetShadowColor(sr,sg,sb)
        return
    end

    local inCombatWithTarget = UnitAffectingCombat("player") and UnitCanAttack("player", "target")

    if UnitIsDeadOrGhost("target") then
        bg:SetVertexColor(unpack(COLORS.dead))
        outline:SetVertexColor(unpack(COLORS.dead))
        SetBarAndTextColor(0.4,0.4,0.4)
        return
    end

    if inCombatWithTarget then
        bg:SetVertexColor(unpack(COLORS.hostile))
        outline:SetVertexColor(unpack(COLORS.hostile))
        SetBarAndTextColor(1.0,0.8,0.8)
        return
    end

    if UnitIsPlayer("target") then
        bg:SetVertexColor(unpack(COLORS.player))
        outline:SetVertexColor(unpack(COLORS.player))
        SetBarAndTextColor(unpack(COLORS.player))
        return
    end

    local reaction = UnitReaction("target","player")
    if reaction then
        if reaction <= 3 then
            bg:SetVertexColor(unpack(COLORS.hostile))
            outline:SetVertexColor(unpack(COLORS.hostile))
            SetBarAndTextColor(1.0,0.8,0.8)
        elseif reaction == 4 then
            bg:SetVertexColor(unpack(COLORS.neutral))
            outline:SetVertexColor(unpack(COLORS.neutral))
            SetBarAndTextColor(235/255,222/255,129/255)
        else
            --bg:SetVertexColor(unpack(COLORS.friendly))
            --outline:SetVertexColor(unpack(COLORS.friendly))
            --SetBarAndTextColor(0.4,1.0,0.4)


             bg:SetVertexColor(113/255, 214/255, 64/255)
             outline:SetVertexColor(113/255, 214/255, 64/255)
             bar:SetStatusBarColor(228/255,255/255,204/255)

             local r,g,b = unpack(COLORS.friendly)
             local sr,sg,sb = DarkenColor(r,g,b,0.6)
             LLabel:SetTextColor(r,g,b); LLabel:SetShadowColor(113/255, 214/255, 64/255)
             vLabel:SetTextColor(r,g,b); vLabel:SetShadowColor(113/255, 214/255, 64/255)
             levelText:SetTextColor(r,g,b); levelText:SetShadowColor(113/255, 214/255, 64/255)
             nameText:SetTextColor(r,g,b); nameText:SetShadowColor(113/255, 214/255, 64/255)
             hpPercentText:SetTextColor(r,g,b); hpPercentText:SetShadowColor(113/255, 214/255, 64/255)



        end


        local classification = UnitClassification("target")

  


    else
        bg:SetVertexColor(unpack(COLORS.neutral))
        outline:SetVertexColor(unpack(COLORS.neutral))
        SetBarAndTextColor(235/255,222/255,129/255)
    end

    
 
end
local function UpdateRareIcon()
    local classification = UnitClassification("target")

    if classification == "rare" or classification == "rareelite" then
        rareIcon:Show()
    else
        rareIcon:Hide()
    end
end

local function Update()
    if UnitExists("target") then
        ShowFrame()

        local hp = UnitHealth("target")
        local maxHp = UnitHealthMax("target")
        local name = UnitName("target") or ""
        local level = UnitLevel("target")

        bar:SetMinMaxValues(0, maxHp)
        bar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)

        nameText:SetText(name)
        levelText:SetText(level == -1 and "??" or level)

        UpdateColors()
        UpdateRareIcon()

        local inCombatWithTarget = UnitAffectingCombat("player") and UnitCanAttack("player","target")

        if inCombatWithTarget then
            hpPercentText:SetText(string.format(
                "%.0f%%",
                UnitHealthPercent("target", true, CurveConstants.ScaleTo100)
            ))
            hpPercentText:Show()
            LLabel:Hide()
            vLabel:Hide()
            levelText:Hide()
        else
            hpPercentText:Hide()
            LLabel:Show()
            vLabel:Show()
            levelText:Show()
        end

  
        local raidIndex = GetRaidTargetIndex("target")
        if raidIndex then
            SetRaidTargetIconTexture(raidIcon, raidIndex)
            raidIcon:Show()
        else
            raidIcon:Hide()
        end

         

    else
        HideFrame()
    end
end

local function targetChanged()
   local hp = UnitHealth("target")
     bar:SetValue(hp)

end



f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_MAXHEALTH")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("RAID_TARGET_UPDATE")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_TARGET_CHANGED"
    or event == "RAID_TARGET_UPDATE"
    or unit == "target" then
        Update()
    end

    if event == "PLAYER_TARGET_CHANGED" then
targetChanged()

    end

 
end)

HideFrame()
