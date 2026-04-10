
local targetFrame = CreateFrame("Frame", nil, UIParent)
local f = targetFrame


local ORIGINAL_WIDTH, ORIGINAL_HEIGHT = 650, 650
local NEW_WIDTH = 650         
local NEW_HEIGHT = 650
f:SetSize(NEW_WIDTH, NEW_HEIGHT)


if _G["FFTargetFrame"] then
    f:SetPoint("LEFT", _G["FFTargetFrame"], "RIGHT", -150 , 0)   
else
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)        
end

f:SetFrameStrata("MEDIUM")


local COLORS = {
    hostile  = {200/255, 50/255, 8/255},
    friendly = {228/255,255/255,204/255},
    neutral  = {1.0, 0.87, 0.0},
    player   = {0.6, 0.8, 1.0},
    dead     = {0.35, 0.35, 0.35},
}


local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", 215, -4)
bg:SetPoint("BOTTOMRIGHT", -215, 0)
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Background")
bg:SetVertexColor(unpack(COLORS.neutral))


local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", 215, -4)
bar:SetPoint("BOTTOMRIGHT", -215, 0)
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Health")
local tex = bar:GetStatusBarTexture()
tex:SetDrawLayer("ARTWORK", 0)
tex:SetTexCoord(0, 1, 0, 1)


local arrow = f:CreateTexture(nil, "ARTWORK")
arrow:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Arrow")  
arrow:SetSize(70, 70)  
arrow:SetPoint("RIGHT", bar, "LEFT", -22, 0)  
arrow:SetDrawLayer("ARTWORK", 5)


local arrow2 = f:CreateTexture(nil, "ARTWORK")
arrow2:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\Arrow2")  
arrow2:SetSize(70, 70)  
arrow2:SetPoint("RIGHT", bar, "LEFT", -18, 0)  
arrow2:SetDrawLayer("ARTWORK", 5)

local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetAllPoints(f)
outlineFrame:EnableMouse(false)


local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\TargetFrame\\TargetTarget")
outline:SetDrawLayer("OVERLAY", 3)
outline:SetVertexColor(unpack(COLORS.neutral))


local nameText = outlineFrame:CreateFontString(nil, "OVERLAY")
nameText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", 20)
nameText:SetPoint("LEFT", outlineFrame, "LEFT", 220, 16)
nameText:SetJustifyH("LEFT")
nameText:SetDrawLayer("OVERLAY", 7)
nameText:SetShadowOffset(1, -1)


local CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT = 700 / 3, 68
local clickFrame = CreateFrame("Button", nil, outlineFrame, "SecureUnitButtonTemplate")
clickFrame:SetFrameStrata(f:GetFrameStrata())
clickFrame:SetFrameLevel(f:GetFrameLevel() - 1)
clickFrame:SetSize(CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT)
clickFrame:SetPoint("CENTER", outlineFrame, "CENTER", 0, 5)
clickFrame:EnableMouse(true)
clickFrame:RegisterForClicks("AnyUp")
clickFrame:SetAttribute("unit", "targettarget")
clickFrame:SetAttribute("type1", "target")
clickFrame:SetAttribute("type2", "togglemenu")


local function ShowFrame() f:SetAlpha(1) end
local function HideFrame() f:SetAlpha(0) end

local function DarkenColor(r, g, b, factor)
    factor = factor or 0.6
    return r * factor, g * factor, b * factor
end

local function SetBarAndTextColor(r, g, b)
    bar:SetStatusBarColor(r, g, b, 1)
    local sr, sg, sb = DarkenColor(r, g, b, 0.6)
    nameText:SetTextColor(r, g, b)
    nameText:SetShadowColor(sr, sg, sb)
end


local function UpdateColors()
    if not UnitExists("targettarget") then return end

    local unit = "targettarget"
    local reaction = UnitReaction(unit, "player")
    local isPlayer = UnitIsPlayer(unit)

    local inCombatWithTargetTarget = UnitAffectingCombat("player") and UnitCanAttack("player", unit)

    if UnitIsDeadOrGhost(unit) then
        bg:SetVertexColor(unpack(COLORS.dead))
        outline:SetVertexColor(unpack(COLORS.dead))
        SetBarAndTextColor(0.4, 0.4, 0.4)
        return
    end

    if inCombatWithTargetTarget then
        bg:SetVertexColor(unpack(COLORS.hostile))
        outline:SetVertexColor(unpack(COLORS.hostile))
        SetBarAndTextColor(1.0, 0.8, 0.8)
        return
    end

    if reaction then
        if reaction <= 3 then
         
            bg:SetVertexColor(unpack(COLORS.hostile))
            outline:SetVertexColor(unpack(COLORS.hostile))
            SetBarAndTextColor(1.0, 0.8, 0.8)

        elseif reaction == 4 then
      
            bg:SetVertexColor(unpack(COLORS.neutral))
            outline:SetVertexColor(unpack(COLORS.neutral))
            SetBarAndTextColor(235/255, 222/255, 129/255)

        else
     
            if isPlayer then
                bg:SetVertexColor(unpack(COLORS.player))
                outline:SetVertexColor(unpack(COLORS.player))
                SetBarAndTextColor(unpack(COLORS.player))
            else
              
                nameText:SetTextColor(228/255,255/255,204/255)
                nameText:SetShadowColor(113/255, 214/255, 64/255)

                bg:SetVertexColor(113/255, 214/255, 64/255)
                outline:SetVertexColor(113/255, 214/255, 64/255)
                bar:SetStatusBarColor(228/255,255/255,204/255)
            end
        end
    else
        bg:SetVertexColor(unpack(COLORS.neutral))
        outline:SetVertexColor(unpack(COLORS.neutral))
        SetBarAndTextColor(235/255, 222/255, 129/255)
    end
end

local function AnimateArrow(arrow, stagger)
    local origPoint, relTo, relPoint, origX, origY = arrow:GetPoint()
    if not origX then
        arrow:SetPoint("RIGHT", bar, "LEFT", 4, 0)
        origPoint, relTo, relPoint, origX, origY = arrow:GetPoint()
    end

    local ag = arrow:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local slide = ag:CreateAnimation("Translation")
    slide:SetDuration(0.5)
    slide:SetSmoothing("OUT")
    slide:SetOffset(25, 0)
    slide:SetOrder(1)

    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetDuration(0.5)
    fade:SetOrder(1)

    local pause = ag:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(1)
    pause:SetOrder(2)

    local reset = ag:CreateAnimation("Translation")
    reset:SetOffset(-25, 0)
    reset:SetDuration(0)
    reset:SetOrder(3)

    if stagger and stagger > 0 then
        C_Timer.After(stagger, function() ag:Play() end)
    else
        ag:Play()
    end
end

local function AnimateArrow2(arrow, stagger)
    local origPoint, relTo, relPoint, origX, origY = arrow:GetPoint()
    if not origX then
        arrow:SetPoint("RIGHT", bar, "LEFT", 4, 0)
        origPoint, relTo, relPoint, origX, origY = arrow:GetPoint()
    end

    local ag = arrow:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local slide = ag:CreateAnimation("Translation")
    slide:SetDuration(0.5)
    slide:SetSmoothing("OUT")
    slide:SetOffset(25, 0)
    slide:SetOrder(1)

    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(1)
    fade:SetDuration(0.5)
    fade:SetOrder(1)

    local pause = ag:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(1)
    pause:SetOrder(2)

    local reset = ag:CreateAnimation("Translation")
    reset:SetOffset(-25, 0)
    reset:SetDuration(0)
    reset:SetOrder(3)

    if stagger and stagger > 0 then
        C_Timer.After(stagger, function() ag:Play() end)
    else
        ag:Play()
    end
end


AnimateArrow2(arrow, 0)
AnimateArrow(arrow2, 0)


 

local function Update()
    if UnitExists("target") and UnitExists("targettarget") then
   
        ShowFrame()

        local hp = UnitHealth("targettarget")
        local maxHp = UnitHealthMax("targettarget")
        local name = UnitName("targettarget") or ""

        bar:SetMinMaxValues(0, maxHp)
        bar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)

        nameText:SetText(name)

        UpdateColors()
    else
     
        HideFrame()
    end
end


f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_MAXHEALTH")
f:RegisterEvent("UNIT_TARGET")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGET"
        or unit == "target" or unit == "targettarget" then
        Update()
    end
end)

HideFrame()
 

local anchor = FFXIV_UI_Anchors.TargetOfTarget
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, -15)
